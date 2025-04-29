"""
Oracle combination logic.
This file contains functions for combining oracles for different expression types.
"""

"""
    get_oracle_for_expression(expr::Expression, oracle_type::DataType)

Get an oracle for an expression by combining the oracles of its components.
"""
function get_oracle_for_expression(expr::Expression, oracle_type::DataType)
    # First check for special combinations
    special_oracle = check_for_special_combination(expr, oracle_type)
    if special_oracle !== nothing
        return special_oracle
    end

    # Standard combinations
    return combine_oracles(expr, oracle_type)
end

"""
    check_for_special_combination(expr::Expression, oracle_type::DataType)

Check if an expression matches a registered special combination.
"""
function check_for_special_combination(expr::Expression, oracle_type::DataType)
    # Extract operation type and function symbols
    op_type = typeof(expr)
    funcs = Symbol[]

    # Operations with terms (Addition, Subtraction, Maximum, Minimum)
    if hasfield(op_type, :terms) &&
       all(term -> term isa FunctionCall, getfield(expr, :terms))
        funcs = [term.name for term in getfield(expr, :terms)]

        # Composition
    elseif op_type == Composition &&
           expr.outer isa FunctionCall &&
           expr.inner isa FunctionCall
        funcs = [expr.outer.name, expr.inner.name]
    else
        return nothing
    end

    # Check for a special handler
    handler = get_special_combination(op_type, funcs, oracle_type)
    if handler !== nothing
        return handler(expr)
    end

    return nothing
end

"""
    combine_oracles(expr::Expression, oracle_type::DataType)

Combine oracles for an expression based on its structure.
"""
function combine_oracles(expr::Expression, oracle_type::DataType)
    # Default implementation - can be specialized for different expression types
    return nothing
end

# Standard combination rules

"""
    combine_oracles(expr::FunctionCall, oracle_type::DataType)

Get oracle for a function call. Handles direct function calls and compositions like f(g(x)).
"""
function combine_oracles(expr::FunctionCall, oracle_type::DataType)
    # Basic function call
    if length(expr.args) == 0
        return get_oracle(expr.name, oracle_type)

        # Function call with arguments - check for nested function calls
    elseif length(expr.args) == 1 && expr.args[1] isa FunctionCall
        inner = expr.args[1]

        # Handle different oracle types
        if oracle_type == EvaluationOracle
            # For evaluation: f(g(x)) = f(g(x))
            inner_oracle = get_oracle_for_expression(inner, oracle_type)
            outer_oracle = get_oracle(expr.name, oracle_type)

            if inner_oracle === nothing || outer_oracle === nothing
                return nothing
            end

            # Compose the oracles
            return EvaluationOracle(x -> outer_oracle(inner_oracle(x)))

        elseif oracle_type == DerivativeOracle
            # For derivatives: (f∘g)'(x) = f'(g(x))·g'(x)
            inner_eval = get_oracle_for_expression(inner, EvaluationOracle)
            outer_deriv = get_oracle(expr.name, oracle_type)
            inner_deriv = get_oracle_for_expression(inner, oracle_type)

            if inner_eval === nothing || outer_deriv === nothing || inner_deriv === nothing
                return nothing
            end

            # Chain rule
            return DerivativeOracle(x -> outer_deriv(inner_eval(x)) * inner_deriv(x))
        end
    end

    # Simple function call
    return get_oracle(expr.name, oracle_type)
end

"""
    combine_oracles(expr::Addition, oracle_type::DataType)

Combine oracles for an addition expression.
"""
function combine_oracles(expr::Addition, oracle_type::DataType)
    if oracle_type == EvaluationOracle || oracle_type == DerivativeOracle
        # Get oracles for all terms
        term_oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle_type)
            if term_oracle === nothing
                return nothing
            end
            push!(term_oracles, term_oracle)
        end

        # Create combined oracle
        implementation = x -> sum(oracle(x) for oracle in term_oracles)

        if oracle_type == EvaluationOracle
            return EvaluationOracle(implementation)
        else
            return DerivativeOracle(implementation)
        end
    end

    return nothing
end

"""
    combine_oracles(expr::Subtraction, oracle_type::DataType)

Combine oracles for a subtraction expression.
"""
function combine_oracles(expr::Subtraction, oracle_type::DataType)
    if oracle_type == EvaluationOracle || oracle_type == DerivativeOracle
        if isempty(expr.terms)
            return nothing
        end

        # Get oracles for all terms
        term_oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle_type)
            if term_oracle === nothing
                return nothing
            end
            push!(term_oracles, term_oracle)
        end

        # Create combined oracle
        implementation = function (x)
            result = term_oracles[1](x)
            for i = 2:length(term_oracles)
                result -= term_oracles[i](x)
            end
            return result
        end

        if oracle_type == EvaluationOracle
            return EvaluationOracle(implementation)
        else
            return DerivativeOracle(implementation)
        end
    end

    return nothing
end

"""
    combine_oracles(expr::Composition, oracle_type::DataType)

Combine oracles for a composition expression.
"""
function combine_oracles(expr::Composition, oracle_type::DataType)
    if oracle_type == EvaluationOracle
        # For evaluation: (f∘g)(x) = f(g(x))
        outer_oracle = get_oracle_for_expression(expr.outer, oracle_type)
        inner_oracle = get_oracle_for_expression(expr.inner, oracle_type)

        if outer_oracle === nothing || inner_oracle === nothing
            return nothing
        end

        return EvaluationOracle(x -> outer_oracle(inner_oracle(x)))

    elseif oracle_type == DerivativeOracle
        # For derivatives: (f∘g)'(x) = f'(g(x))·g'(x)
        outer_eval = get_oracle_for_expression(expr.outer, EvaluationOracle)
        inner_eval = get_oracle_for_expression(expr.inner, EvaluationOracle)
        outer_deriv = get_oracle_for_expression(expr.outer, oracle_type)
        inner_deriv = get_oracle_for_expression(expr.inner, oracle_type)

        if outer_eval === nothing ||
           inner_eval === nothing ||
           outer_deriv === nothing ||
           inner_deriv === nothing
            return nothing
        end

        # Chain rule
        return DerivativeOracle(x -> outer_deriv(inner_eval(x)) * inner_deriv(x))
    end

    return nothing
end

"""
    combine_oracles(expr::Maximum, oracle_type::DataType)

Combine oracles for a maximum expression.
"""
function combine_oracles(expr::Maximum, oracle_type::DataType)
    if oracle_type == EvaluationOracle
        # Get oracles for all terms
        term_oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle_type)
            if term_oracle === nothing
                return nothing
            end
            push!(term_oracles, term_oracle)
        end

        # Create combined oracle
        return EvaluationOracle(x -> maximum(oracle(x) for oracle in term_oracles))
    end

    return nothing
end

"""
    combine_oracles(expr::Minimum, oracle_type::DataType)

Combine oracles for a minimum expression.
"""
function combine_oracles(expr::Minimum, oracle_type::DataType)
    if oracle_type == EvaluationOracle
        # Get oracles for all terms
        term_oracles = []
        for term in expr.terms
            term_oracle = get_oracle_for_expression(term, oracle_type)
            if term_oracle === nothing
                return nothing
            end
            push!(term_oracles, term_oracle)
        end

        # Create combined oracle
        return EvaluationOracle(x -> minimum(oracle(x) for oracle in term_oracles))
    end

    return nothing
end
