"""
This file contains the logic for combining oracles for complex expressions.
It uses multiple dispatch to handle different expression types and oracle types.
"""

# Registry for special combination handlers
# The key is (operation_type, [function_symbols], oracle_type)
# Example: (Addition, [:l1norm, :l1norm], ProximalOracle) => handler_function
const special_combination_registry =
    Dict{Tuple{DataType,Vector{Symbol},DataType},Function}()

"""
    register_special_combination(op_type::DataType, funcs::Vector{Symbol},
                               oracle_type::Type{<:Oracle}, handler::Function)

Register a special combination handler for specific functions and oracle types.

# Arguments
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the combination
- `oracle_type::Type{<:Oracle}`: The type of oracle being combined
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
    oracle_type::Type{<:Oracle},
    handler::Function,
)
    special_combination_registry[(op_type, funcs, oracle_type)] = handler
    return handler
end

"""
    has_special_combination(op_type::DataType, funcs::Vector{Symbol},
                          oracle_type::Type{<:Oracle})

Check if a special combination handler exists for the given operation, functions, and oracle type.

# Arguments
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the combination
- `oracle_type::Type{<:Oracle}`: The type of oracle being combined

# Returns
- `true` if a special handler exists, `false` otherwise
"""
function has_special_combination(
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type::Type{<:Oracle},
)
    return haskey(special_combination_registry, (op_type, funcs, oracle_type))
end

"""
    get_special_combination(op_type::DataType, funcs::Vector{Symbol},
                          oracle_type::Type{<:Oracle})

Get the special combination handler for the given operation, functions, and oracle type.

# Arguments
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the combination
- `oracle_type::Type{<:Oracle}`: The type of oracle being combined

# Returns
- The special handler function if it exists, otherwise nothing
"""
function get_special_combination(
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type::Type{<:Oracle},
)
    if has_special_combination(op_type, funcs, oracle_type)
        return special_combination_registry[(op_type, funcs, oracle_type)]
    end
    return nothing
end

"""
    check_for_special_combination(expr::Expression, oracle_type::Type{<:Oracle})

Check if the expression matches any registered special combination pattern.

# Arguments
- `expr::Expression`: The expression to check
- `oracle_type::Type{<:Oracle}`: The type of oracle being combined

# Returns
- The result of the special handler if a match is found, otherwise nothing
"""
function check_for_special_combination(expr::Expression, oracle_type::Type{<:Oracle})
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

    # Check if we have a special handler for this combination
    handler = get_special_combination(op_type, funcs, oracle_type)
    if handler !== nothing
        return handler(expr)
    end

    return nothing
end

"""
    get_oracle_for_expression(expr::Expression, oracle_type::Type{<:Oracle})

Get an oracle for any expression, either from the registry (for function calls)
or by combining oracles (for composite expressions).

# Arguments
- `expr::Expression`: The expression to get an oracle for
- `oracle_type::Type{<:Oracle}`: The type of oracle to get

# Returns
- A function implementing the oracle if possible, otherwise nothing
"""

"""
  get_oracle_for_expression(fc::FunctionCall, OracleType)

Detect nested f(g(x)) and inline compose oracles for Eval/Deriv.
Otherwise fall back to the plain function‐call registry.
"""
function get_oracle_for_expression(fc::Language.FunctionCall, ::Type{T}) where {T<:Oracle}
    # composition case: single‐arg call whose arg is itself a FunctionCall
    if length(fc.args) == 1 && fc.args[1] isa Language.FunctionCall
        inner = fc.args[1]
        name = fc.name
        if T === EvaluationOracle
            ie = get_oracle_for_expression(inner, EvaluationOracle)
            oe = get_oracle(name, EvaluationOracle)
            (ie === nothing || oe === nothing) && return nothing
            return x -> oe(ie(x))
        elseif T === DerivativeOracle
            ie_eval = get_oracle_for_expression(inner, EvaluationOracle)
            oe_deriv = get_oracle(name, DerivativeOracle)
            ie_deriv = get_oracle_for_expression(inner, DerivativeOracle)
            (ie_eval === nothing || oe_deriv === nothing || ie_deriv === nothing) &&
                return nothing
            return x -> oe_deriv(ie_eval(x)) * ie_deriv(x)
        else
            # no default composition logic for other oracle types
            return nothing
        end
    end
    # plain function‐call
    return get_oracle(fc.name, T)
end

# Fallback: composite expressions (Addition, Composition AST, etc.)
function get_oracle_for_expression(expr::Language.Expression, ::Type{T}) where {T<:Oracle}
    return combine_oracles(expr, T)
end

"""
    combine_oracles(expr::Expression, oracle_type::Type{<:Oracle})

Main entry point for combining oracles for complex expressions.
This function attempts to create a composed oracle for a complex expression
based on the oracles of its components.

# Arguments
- `expr::Expression`: The expression to combine oracles for
- `oracle_type::Type{<:Oracle}`: The type of oracle to combine

# Returns
- A function implementing the combined oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Expression, oracle_type::Type{<:Oracle})
    # Default fallback returns nothing
    return nothing
end

# === ADDITION === #

"""
    combine_oracles(expr::Addition, ::Type{EvaluationOracle})

Combine evaluation oracles for an addition expression.
The result is the sum of evaluating each term.

# Arguments
- `expr::Addition`: The addition expression
- `::Type{EvaluationOracle}`: The evaluation oracle type

# Returns
- A function implementing the combined evaluation oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Addition, ::Type{EvaluationOracle})
    # Get oracles for all terms
    oracles = []
    for term in expr.terms
        oracle = get_oracle_for_expression(term, EvaluationOracle)
        if oracle === nothing
            return nothing  # If any term is missing an oracle, we can't combine
        end
        push!(oracles, oracle)
    end

    # Return the combined oracle
    return x -> sum(oracle(x) for oracle in oracles)
end

"""
    combine_oracles(expr::Addition, ::Type{DerivativeOracle})

Combine derivative oracles for an addition expression.
The result is the sum of the derivatives of each term.

# Arguments
- `expr::Addition`: The addition expression
- `::Type{DerivativeOracle}`: The derivative oracle type

# Returns
- A function implementing the combined derivative oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Addition, ::Type{DerivativeOracle})
    # Get oracles for all terms
    oracles = []
    for term in expr.terms
        oracle = get_oracle_for_expression(term, DerivativeOracle)
        if oracle === nothing
            return nothing  # If any term is missing an oracle, we can't combine
        end
        push!(oracles, oracle)
    end

    # Return the combined oracle
    return x -> sum(oracle(x) for oracle in oracles)
end

"""
    combine_oracles(expr::Addition, ::Type{ProximalOracle})

Combine proximal oracles for an addition expression.
Note: In general, the proximal operator of a sum is not the sum of proximal operators.
This function returns nothing because we can't directly combine proximal operators for sums.

# Arguments
- `expr::Addition`: The addition expression
- `::Type{ProximalOracle}`: The proximal oracle type

# Returns
- Nothing, as we can't directly combine proximal operators for sums in the general case.
  Special cases are handled through the special combination registry.
"""
function combine_oracles(expr::Addition, ::Type{ProximalOracle})
    # In general, the proximal operator of a sum is not the sum of proximal operators
    # Special cases are handled through the special combination registry
    return nothing
end

# === SUBTRACTION === #

"""
    combine_oracles(expr::Subtraction, ::Type{EvaluationOracle})

Combine evaluation oracles for a subtraction expression.
The result is the first term minus all subsequent terms.

# Arguments
- `expr::Subtraction`: The subtraction expression
- `::Type{EvaluationOracle}`: The evaluation oracle type

# Returns
- A function implementing the combined evaluation oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Subtraction, ::Type{EvaluationOracle})
    if isempty(expr.terms)
        return nothing
    end

    oracles = []
    for term in expr.terms
        oracle = get_oracle_for_expression(term, EvaluationOracle)
        if oracle === nothing
            return nothing
        end
        push!(oracles, oracle)
    end

    return function (x)
        result = oracles[1](x)
        for i = 2:length(oracles)
            result -= oracles[i](x)
        end
        return result
    end
end

"""
    combine_oracles(expr::Subtraction, ::Type{DerivativeOracle})

Combine derivative oracles for a subtraction expression.
The result is the derivative of the first term minus the derivatives of all subsequent terms.

# Arguments
- `expr::Subtraction`: The subtraction expression
- `::Type{DerivativeOracle}`: The derivative oracle type

# Returns
- A function implementing the combined derivative oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Subtraction, ::Type{DerivativeOracle})
    if isempty(expr.terms)
        return nothing
    end

    oracles = []
    for term in expr.terms
        oracle = get_oracle_for_expression(term, DerivativeOracle)
        if oracle === nothing
            return nothing
        end
        push!(oracles, oracle)
    end

    return function (x)
        result = oracles[1](x)
        for i = 2:length(oracles)
            result -= oracles[i](x)
        end
        return result
    end
end

"""
    combine_oracles(expr::Subtraction, ::Type{ProximalOracle})

Combine proximal oracles for a subtraction expression.
Like with addition, we can't directly combine proximal operators for differences.

# Arguments
- `expr::Subtraction`: The subtraction expression
- `::Type{ProximalOracle}`: The proximal oracle type

# Returns
- Nothing, as we can't directly combine proximal operators for differences in the general case.
  Special cases are handled through the special combination registry.
"""
function combine_oracles(expr::Subtraction, ::Type{ProximalOracle})
    # Similar to addition, we can't directly combine proximal operators for differences
    # Special cases are handled through the special combination registry
    return nothing
end

# === COMPOSITION === #

"""
    combine_oracles(expr::Composition, ::Type{EvaluationOracle})

Combine evaluation oracles for a composition expression (f ∘ g).
The result is f(g(x)).

# Arguments
- `expr::Composition`: The composition expression
- `::Type{EvaluationOracle}`: The evaluation oracle type

# Returns
- A function implementing the combined evaluation oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Composition, ::Type{EvaluationOracle})
    outer_oracle = get_oracle_for_expression(expr.outer, EvaluationOracle)
    inner_oracle = get_oracle_for_expression(expr.inner, EvaluationOracle)

    if outer_oracle === nothing || inner_oracle === nothing
        return nothing
    end

    return x -> outer_oracle(inner_oracle(x))
end

"""
    combine_oracles(expr::Composition, ::Type{DerivativeOracle})

Combine derivative oracles for a composition expression (f ∘ g).
The result uses the chain rule: (f ∘ g)'(x) = f'(g(x)) * g'(x)

# Arguments
- `expr::Composition`: The composition expression
- `::Type{DerivativeOracle}`: The derivative oracle type

# Returns
- A function implementing the combined derivative oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Composition, ::Type{DerivativeOracle})
    # We need both evaluation and derivative oracles for both functions
    outer_eval = get_oracle_for_expression(expr.outer, EvaluationOracle)
    inner_eval = get_oracle_for_expression(expr.inner, EvaluationOracle)
    outer_deriv = get_oracle_for_expression(expr.outer, DerivativeOracle)
    inner_deriv = get_oracle_for_expression(expr.inner, DerivativeOracle)

    if any(
        oracle === nothing for oracle in [outer_eval, inner_eval, outer_deriv, inner_deriv]
    )
        return nothing
    end

    # Chain rule: (f ∘ g)'(x) = f'(g(x)) * g'(x)
    return x -> outer_deriv(inner_eval(x)) * inner_deriv(x)
end

"""
    combine_oracles(expr::Composition, ::Type{ProximalOracle})

Combine proximal oracles for a composition expression.
In general, we can't directly compute the proximal operator of a composition.

# Arguments
- `expr::Composition`: The composition expression
- `::Type{ProximalOracle}`: The proximal oracle type

# Returns
- Nothing, as we can't directly compute the proximal operator of a composition in general.
  Special cases are handled through the special combination registry.
"""
function combine_oracles(expr::Composition, ::Type{ProximalOracle})
    # In general, we can't directly compute the proximal operator of a composition
    # Special cases are handled through the special combination registry
    return nothing
end

# === MAXIMUM === #

"""
    combine_oracles(expr::Maximum, ::Type{EvaluationOracle})

Combine evaluation oracles for a maximum expression.
The result is the maximum of evaluating each term.

# Arguments
- `expr::Maximum`: The maximum expression
- `::Type{EvaluationOracle}`: The evaluation oracle type

# Returns
- A function implementing the combined evaluation oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Maximum, ::Type{EvaluationOracle})
    if isempty(expr.terms)
        return nothing
    end

    oracles = []
    for term in expr.terms
        oracle = get_oracle_for_expression(term, EvaluationOracle)
        if oracle === nothing
            return nothing
        end
        push!(oracles, oracle)
    end

    return function (x)
        values = [oracle(x) for oracle in oracles]
        return maximum(values)
    end
end

"""
    combine_oracles(expr::Maximum, ::Type{DerivativeOracle})

Combine derivative oracles for a maximum expression.
The subdifferential of a maximum of functions is complex (involving the convex hull
of gradients at points where multiple terms achieve the maximum).

# Arguments
- `expr::Maximum`: The maximum expression
- `::Type{DerivativeOracle}`: The derivative oracle type

# Returns
- Nothing in the general case. Special cases can be handled through the special combination registry.
"""
function combine_oracles(expr::Maximum, ::Type{DerivativeOracle})
    # The subdifferential of max(f₁(x), f₂(x), ...) is complex and depends on which functions
    # attain the maximum at the point x.
    # Special cases should be handled through the special combination registry.
    return nothing
end

# === MINIMUM === #

"""
    combine_oracles(expr::Minimum, ::Type{EvaluationOracle})

Combine evaluation oracles for a minimum expression.
The result is the minimum of evaluating each term.

# Arguments
- `expr::Minimum`: The minimum expression
- `::Type{EvaluationOracle}`: The evaluation oracle type

# Returns
- A function implementing the combined evaluation oracle if possible, otherwise nothing
"""
function combine_oracles(expr::Minimum, ::Type{EvaluationOracle})
    if isempty(expr.terms)
        return nothing
    end

    oracles = []
    for term in expr.terms
        oracle = get_oracle_for_expression(term, EvaluationOracle)
        if oracle === nothing
            return nothing
        end
        push!(oracles, oracle)
    end

    return function (x)
        values = [oracle(x) for oracle in oracles]
        return minimum(values)
    end
end

"""
    combine_oracles(expr::Minimum, ::Type{DerivativeOracle})

Combine derivative oracles for a minimum expression.
The subdifferential of a minimum of functions is complex (involving the convex hull
of gradients at points where multiple terms achieve the minimum).

# Arguments
- `expr::Minimum`: The minimum expression
- `::Type{DerivativeOracle}`: The derivative oracle type

# Returns
- Nothing in the general case. Special cases can be handled through the special combination registry.
"""
function combine_oracles(expr::Minimum, ::Type{DerivativeOracle})
    # The subdifferential of min(f₁(x), f₂(x), ...) is complex and depends on which functions
    # attain the minimum at the point x.
    # Special cases should be handled through the special combination registry.
    return nothing
end
