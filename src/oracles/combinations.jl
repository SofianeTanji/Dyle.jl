"""
This file contains the logic for combining oracles for complex expressions.
It uses multiple dispatch to handle different expression types and oracle types.
"""

# Registry for special combination handlers
# The key is (operation_type, [function_symbols], DataType)
# Example: (Addition, [:l1norm, :l1norm], ProximalOracle) => handler_function
const special_combination_registry =
    Dict{Tuple{DataType,Vector{Symbol},DataType},Function}()

"""
    register_special_combination(op_type::DataType, funcs::Vector{Symbol}, oracle_type, handler::Function)

Register a special combination handler for specific functions and oracle types.

# Arguments
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the combination
- `oracle_type`: The type of oracle being combined (can be parameterized, type alias, or instance)
- `handler::Function`: The function that implements the special combination

# Returns
- The registered handler function

# Example
```julia
register_special_combination(Addition, [:l1norm, :l1norm], ProximalOracle,
                          expr -> special_l1_proximal_handler(expr))
```
"""
function register_special_combination(
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type,
    handler::Function,
)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle_type)

    special_combination_registry[(op_type, funcs, base_type)] = handler
    return handler
end

"""
    has_special_combination(op_type::DataType, funcs::Vector{Symbol}, oracle_type)

Check if a special combination handler exists for the given operation, functions, and oracle type.

# Arguments
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the combination
- `oracle_type`: The type of oracle being combined (can be parameterized, type alias, or instance)

# Returns
- `true` if a special handler exists, `false` otherwise
"""
function has_special_combination(op_type::DataType, funcs::Vector{Symbol}, oracle_type)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle_type)

    return haskey(special_combination_registry, (op_type, funcs, base_type))
end

"""
    get_special_combination(op_type::DataType, funcs::Vector{Symbol}, oracle_type)

Get the special combination handler for the given operation, functions, and oracle type.

# Arguments
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the combination
- `oracle_type`: The type of oracle being combined (can be parameterized, type alias, or instance)

# Returns
- The special handler function if it exists, otherwise nothing
"""
function get_special_combination(op_type::DataType, funcs::Vector{Symbol}, oracle_type)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle_type)

    if haskey(special_combination_registry, (op_type, funcs, base_type))
        return special_combination_registry[(op_type, funcs, base_type)]
    end
    return nothing
end

"""
    check_for_special_combination(expr::Expression, oracle_type)

Check if the expression matches any registered special combination pattern.

# Arguments
- `expr::Expression`: The expression to check
- `oracle_type`: The type of oracle being combined (can be parameterized, type alias, or instance)

# Returns
- The result of the special handler if a match is found, otherwise nothing
"""
function check_for_special_combination(expr::Expression, oracle_type)
    # Get the operation type
    op_type = typeof(expr)

    # Extract function symbols if they exist
    funcs = Symbol[]

    # For operations with terms (Addition, Subtraction, Maximum, Minimum)
    if hasfield(op_type, :terms) &&
       all(term -> term isa FunctionCall, getfield(expr, :terms))
        funcs = [term.name for term in getfield(expr, :terms)]
        # For Composition
    elseif op_type == Composition &&
           expr.outer isa FunctionCall &&
           expr.inner isa FunctionCall
        funcs = [expr.outer.name, expr.inner.name]
        # If we can't extract function symbols, return nothing
    else
        return nothing
    end

    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle_type)

    # Check if we have a special handler for this combination
    handler = get_special_combination(op_type, funcs, base_type)
    if handler !== nothing
        return handler(expr)
    end

    return nothing
end

"""
    get_oracle_for_expression(expr::Expression, oracle)

Get an oracle for any expression, handling exactness properly.

# Arguments
- `expr::Expression`: The expression to get an oracle for
- `oracle`: An instance or type of the oracle to get

# Returns
- A function implementing the oracle if possible, otherwise nothing
"""
function get_oracle_for_expression(expr::Expression, oracle)
    # Check for special combinations first
    special_oracle = check_for_special_combination(expr, oracle)
    if special_oracle !== nothing
        return special_oracle
    end

    # Fall back to regular combination logic
    return combine_oracles(expr, oracle)
end

"""
  get_oracle_for_expression(fc::FunctionCall, oracle)

Detect nested f(g(x)) and inline compose oracles for Eval/Deriv.
Otherwise fall back to the plain function-call registry.

# Arguments
- `fc::FunctionCall`: The function call expression
- `oracle`: An instance or type of the oracle to get

# Returns
- A function implementing the oracle if possible, otherwise nothing
"""
function get_oracle_for_expression(fc::Language.FunctionCall, oracle)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle)

    # Composition case: single-arg call whose arg is itself a FunctionCall
    if length(fc.args) == 1 && fc.args[1] isa Language.FunctionCall
        inner = fc.args[1]
        name = fc.name

        if base_type == EvaluationOracle
            # Try to get inner and outer oracles
            ie = get_oracle_for_expression(inner, oracle)
            oe = get_oracle(name, oracle)

            if ie === nothing || oe === nothing
                return nothing
            end

            # Composed oracle for evaluation
            return x -> oe(ie(x))

        elseif base_type == DerivativeOracle
            # Need evaluation oracle for inner and derivative oracles for both
            ie_eval = get_oracle_for_expression(inner, EvaluationOracle())
            oe_deriv = get_oracle(name, oracle)
            ie_deriv = get_oracle_for_expression(inner, oracle)

            if ie_eval === nothing || oe_deriv === nothing || ie_deriv === nothing
                return nothing
            end

            # Composed derivative oracle (chain rule)
            return x -> oe_deriv(ie_eval(x)) * ie_deriv(x)
        end
    end

    # Plain function call
    return get_oracle(fc.name, oracle)
end

"""
    combine_oracles(expr::Expression, oracle)

Main entry point for combining oracles for complex expressions.
This function attempts to create a composed oracle for a complex expression
based on the oracles of its components.

# Arguments
- `expr::Expression`: The expression to combine oracles for
- `oracle`: An instance or type of the oracle to combine

# Returns
- A function implementing the combined oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Expression, oracle)
    # Default fallback returns nothing
    return nothing
end

# === ADDITION === #

"""
    combine_oracles(expr::Addition, oracle)

Combine evaluation oracles for an addition expression.
The result is the sum of evaluating each term.

# Arguments
- `expr::Addition`: The addition expression
- `oracle`: The oracle instance or type

# Returns
- A function implementing the combined evaluation oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Addition, oracle)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle)

    # Different handling based on oracle type
    if base_type == EvaluationOracle
        # Get oracles for all terms
        oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle)
            if term_oracle === nothing
                return nothing  # If any term is missing an oracle, we can't combine
            end
            push!(oracles, term_oracle)
        end

        # Return the combined oracle
        return x -> sum(oracle(x) for oracle in oracles)
    elseif base_type == DerivativeOracle
        # Get oracles for all terms
        oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle)
            if term_oracle === nothing
                return nothing  # If any term is missing an oracle, we can't combine
            end
            push!(oracles, term_oracle)
        end

        # Return the combined oracle
        return x -> sum(oracle(x) for oracle in oracles)
    else
        # For other oracle types, the combination may not be straightforward
        # Special cases should be handled through the special combination registry
        return nothing
    end
end

# === SUBTRACTION === #

"""
    combine_oracles(expr::Subtraction, oracle)

Combine oracles for a subtraction expression.
The result depends on the oracle type.

# Arguments
- `expr::Subtraction`: The subtraction expression
- `oracle`: The oracle instance or type

# Returns
- A function implementing the combined oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Subtraction, oracle)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle)

    # Different handling based on oracle type
    if base_type == EvaluationOracle || base_type == DerivativeOracle
        if isempty(expr.terms)
            return nothing
        end

        oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle)
            if term_oracle === nothing
                return nothing
            end
            push!(oracles, term_oracle)
        end

        return function (x)
            result = oracles[1](x)
            for i = 2:length(oracles)
                result -= oracles[i](x)
            end
            return result
        end
    else
        # For other oracle types, the combination may not be straightforward
        # Special cases should be handled through the special combination registry
        return nothing
    end
end

# === COMPOSITION === #

"""
    combine_oracles(expr::Composition, oracle)

Combine oracles for a composition expression (f ∘ g).
The result depends on the oracle type.

# Arguments
- `expr::Composition`: The composition expression
- `oracle`: The oracle instance or type

# Returns
- A function implementing the combined oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Composition, oracle)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle)

    # Different handling based on oracle type
    if base_type == EvaluationOracle
        outer_oracle = get_oracle_for_expression(expr.outer, oracle)
        inner_oracle = get_oracle_for_expression(expr.inner, oracle)

        if outer_oracle === nothing || inner_oracle === nothing
            return nothing
        end

        return x -> outer_oracle(inner_oracle(x))
    elseif base_type == DerivativeOracle
        # We need both evaluation and derivative oracles for the chain rule
        outer_eval = get_oracle_for_expression(expr.outer, EvaluationOracle())
        inner_eval = get_oracle_for_expression(expr.inner, EvaluationOracle())
        outer_deriv = get_oracle_for_expression(expr.outer, oracle)
        inner_deriv = get_oracle_for_expression(expr.inner, oracle)

        if any(o === nothing for o in [outer_eval, inner_eval, outer_deriv, inner_deriv])
            return nothing
        end

        # Chain rule: (f ∘ g)'(x) = f'(g(x)) * g'(x)
        return x -> outer_deriv(inner_eval(x)) * inner_deriv(x)
    else
        # For other oracle types, the combination may not be straightforward
        # Special cases should be handled through the special combination registry
        return nothing
    end
end

# === MAXIMUM === #

"""
    combine_oracles(expr::Maximum, oracle)

Combine oracles for a maximum expression.
The result depends on the oracle type.

# Arguments
- `expr::Maximum`: The maximum expression
- `oracle`: The oracle instance or type

# Returns
- A function implementing the combined oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Maximum, oracle)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle)

    # Different handling based on oracle type
    if base_type == EvaluationOracle
        if isempty(expr.terms)
            return nothing
        end

        oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle)
            if term_oracle === nothing
                return nothing
            end
            push!(oracles, term_oracle)
        end

        return function (x)
            values = [oracle(x) for oracle in oracles]
            return maximum(values)
        end
    else
        # For other oracle types (like derivatives), the combination is more complex
        # Special cases should be handled through the special combination registry
        return nothing
    end
end

# === MINIMUM === #

"""
    combine_oracles(expr::Minimum, oracle)

Combine oracles for a minimum expression.
The result depends on the oracle type.

# Arguments
- `expr::Minimum`: The minimum expression
- `oracle`: The oracle instance or type

# Returns
- A function implementing the combined oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Minimum, oracle)
    # Extract the base oracle type for consistent handling
    base_type = extract_oracle_type(oracle)

    # Different handling based on oracle type
    if base_type == EvaluationOracle
        if isempty(expr.terms)
            return nothing
        end

        oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle)
            if term_oracle === nothing
                return nothing
            end
            push!(oracles, term_oracle)
        end

        return function (x)
            values = [oracle(x) for oracle in oracles]
            return minimum(values)
        end
    else
        # For other oracle types (like derivatives), the combination is more complex
        # Special cases should be handled through the special combination registry
        return nothing
    end
end
