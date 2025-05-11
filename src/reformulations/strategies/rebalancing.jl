"""
    Expression rebalancing strategies.

    This file provides strategies for rebalancing expressions, which involves
    changing how terms are grouped without altering their mathematical meaning.
"""

"""
    RebalancingStrategy <: Strategy

Strategy for rebalancing expressions by changing grouping of terms.
"""
struct RebalancingStrategy <: Strategy end

"""
    (strategy::RebalancingStrategy)(expr::Expression) -> Vector{Reformulation}

Apply rebalancing to an expression.

# Arguments
- `expr::Expression`: The expression to rebalance

# Returns
- `Vector{Reformulation}`: The rebalanced expressions
"""
function (strategy::RebalancingStrategy)(expr::Expression)
    rebalanced = rebalance_expression(expr)
    return [create_reformulation(r) for r in rebalanced]
end

"""
    rebalance_expression(expr::Expression) -> Vector{Expression}

Generate alternative groupings of an expression.
Default method returns an empty list for expression types that can't be rebalanced.

# Arguments
- `expr::Expression`: The expression to rebalance

# Returns
- `Vector{Expression}`: The rebalanced expressions
"""
function rebalance_expression(expr::Expression)
    return Expression[]
end

"""
    rebalance_expression(expr::Addition) -> Vector{Expression}

Generate alternative groupings of an addition expression.

# Arguments
- `expr::Addition`: The addition expression to rebalance

# Returns
- `Vector{Expression}`: The rebalanced expressions
"""
function rebalance_expression(expr::Addition)
    # If not enough terms, return empty list
    if length(expr.terms) < 3
        return Expression[]
    end

    # Flatten nested additions
    flat_terms = flatten_addition_terms(expr)
    if length(flat_terms) <= 2
        return Expression[]
    end

    result = Expression[]

    # Generate all binary regroupings
    for i = 1:length(flat_terms)-1
        for j = i+1:length(flat_terms)
            # Group terms i through j
            left_terms = flat_terms[i:j]

            # Only proceed if we have at least one term on each side
            if length(left_terms) >= 1 && length(flat_terms) - length(left_terms) >= 1
                right_terms = vcat(flat_terms[1:i-1], flat_terms[j+1:end])

                # Create the left group
                left_expr = if length(left_terms) == 1
                    left_terms[1]
                else
                    Addition(left_terms, expr.space)
                end

                # Create the right group
                right_expr = if length(right_terms) == 1
                    right_terms[1]
                else
                    Addition(right_terms, expr.space)
                end

                # Create the new expression
                new_expr = Addition([left_expr, right_expr], expr.space)
                push!(result, new_expr)
            end
        end
    end

    # Generate all ternary regroupings if enough terms
    if length(flat_terms) >= 6
        for i = 1:length(flat_terms)-5
            for j = i+2:length(flat_terms)-3
                for k = j+2:length(flat_terms)-1
                    # Group terms into three parts
                    first_terms = flat_terms[i:j-1]
                    second_terms = flat_terms[j:k-1]
                    third_terms = flat_terms[k:end]

                    # Create the groups
                    first_expr = if length(first_terms) == 1
                        first_terms[1]
                    else
                        Addition(first_terms, expr.space)
                    end

                    second_expr = if length(second_terms) == 1
                        second_terms[1]
                    else
                        Addition(second_terms, expr.space)
                    end

                    third_expr = if length(third_terms) == 1
                        third_terms[1]
                    else
                        Addition(third_terms, expr.space)
                    end

                    # Create the new expression
                    new_expr = Addition([first_expr, second_expr, third_expr], expr.space)
                    push!(result, new_expr)
                end
            end
        end
    end

    return result
end

"""
    flatten_addition_terms(expr::Addition) -> Vector{Expression}

Flatten nested additions into a single list of terms.

# Arguments
- `expr::Addition`: The addition expression to flatten

# Returns
- `Vector{Expression}`: The flattened terms
"""
function flatten_addition_terms(expr::Addition)
    result = Expression[]

    for term in expr.terms
        if term isa Addition
            # Recursively flatten nested additions
            append!(result, flatten_addition_terms(term))
        else
            push!(result, term)
        end
    end

    return result
end

"""
    rebalance_expression(expr::Subtraction) -> Vector{Expression}

Generate alternative groupings of a subtraction expression.

# Arguments
- `expr::Subtraction`: The subtraction expression to rebalance

# Returns
- `Vector{Expression}`: The rebalanced expressions
"""
function rebalance_expression(expr::Subtraction)
    # Rebalancing subtraction is more complex due to sign changes
    # For now, we'll implement a simple version

    # If not enough terms, return empty list
    if length(expr.terms) <= 2
        return Expression[]
    end

    result = Expression[]

    # For a - b - c - d, we can regroup as (a - b) - (c - d)
    if length(expr.terms) == 4
        left = Subtraction([expr.terms[1], expr.terms[2]], expr.space)
        right = Subtraction([expr.terms[3], expr.terms[4]], expr.space)
        new_expr = Subtraction([left, right], expr.space)
        push!(result, new_expr)
    end

    return result
end

"""
    rebalance_expression(expr::Composition) -> Vector{Expression}

Generate alternative groupings of a composition expression.

# Arguments
- `expr::Composition`: The composition expression to rebalance

# Returns
- `Vector{Expression}`: The rebalanced expressions
"""
function rebalance_expression(expr::Composition)
    # Rebalancing composition is generally about associativity
    # Like f ∘ (g ∘ h) vs (f ∘ g) ∘ h

    result = Expression[]

    # Check if the inner expression is a composition
    if expr.inner isa Composition
        # (f ∘ g) ∘ h
        f = expr.outer
        g = expr.inner.outer
        h = expr.inner.inner

        # Create f ∘ (g ∘ h)
        g_h = Composition(g, h, g.space)
        f_g_h = Composition(f, g_h, f.space)

        push!(result, f_g_h)
    end

    return result
end

# Register the rebalancing strategy
register_strategy(:rebalancing, RebalancingStrategy())
