using ..Reformulations: Reformulation, create_reformulation
using ..Language: Expression, FunctionCall
using ..Reformulations: register_strategy, Strategy, push_unique!
using ..Properties: infer_property, Convexity, Convex, Concave, Monotonicity, Increasing

"""
    MonotoneTransformStrategy <: Strategy

Apply a strictly increasing scalar function to the objective without changing minimizers:
  min_x f(x) -> min_x h(f(x)), e.g. h(u)=sqrt(u) or h(u)=log(1+u).
"""
struct MonotoneTransformStrategy <: Strategy end

"""
    (s::MonotoneTransformStrategy)(expr::Expression) -> Vector{Reformulation}

Apply monotone transformations to an expression.
"""
function (s::MonotoneTransformStrategy)(expr::Expression)
    reformulations = Reformulation[]
    seen = Set{String}()

    # Only apply to expressions that are convex/concave and have certain properties
    convexity = infer_property(expr, Convexity)

    # For minimization problems, concave transforms of convex functions preserve minimizers
    # and convex transforms of concave functions preserve minimizers
    if convexity isa Convex
        # Apply sqrt transformation - preserves minimizers for convex f(x) >= 0
        sqrt_expr = sqrt_function(expr)
        push_unique!(reformulations, seen, sqrt_expr)

        # Apply log(1+x) transformation - preserves minimizers for convex f(x) >= 0
        log_expr = log_plus_one(expr)
        push_unique!(reformulations, seen, log_expr)
    elseif convexity isa Concave
        # For concave functions, we could apply increasing convex functions
        # but we don't have any registered currently
    end

    return reformulations
end

# Register the strategy
register_strategy(:monotone_transform, MonotoneTransformStrategy())