# src/special_functions/norms.jl
using ..Language
using ..Oracles
using ..Properties

# Registry of all norms
const norm_functions = Symbol[:l1_norm, :l2_norm]

"""
    register_norm_functions()

Register all norm functions.
"""
function register_norm_functions()
    # Register L1 norm
    l1_info = register_special_function(:l1_norm, "L1 norm (sum of absolute values)")

    # Register evaluation oracle for L1 norm
    register_oracle_handler(:l1_norm, Oracles.EvaluationOracle, x -> sum(abs.(x)))

    # Register derivative oracle for L1 norm
    register_oracle_handler(:l1_norm, Oracles.DerivativeOracle, x -> sign.(x))

    # Register proximal oracle for L1 norm
    register_oracle_handler(
        :l1_norm, Oracles.ProximalOracle, (x, t) -> sign.(x) .* max.(abs.(x) .- t, 0)
    )

    # Register property handlers for L1 norm
    register_property_handler(
        :l1_norm, Properties.Convexity, (expr, context) -> Properties.Convex()
    )

    register_property_handler(
        :l1_norm, Properties.Monotonicity, (expr, context) -> Properties.NonMonotone()
    )

    # Register actual properties
    Properties.register_property!(:l1_norm, Properties.Convex())

    # Register L2 norm
    l2_info = register_special_function(:l2_norm, "L2 norm (Euclidean norm)")

    # Register evaluation oracle for L2 norm
    register_oracle_handler(:l2_norm, Oracles.EvaluationOracle, x -> sqrt(sum(x .^ 2)))

    # Register derivative oracle for L2 norm
    register_oracle_handler(
        :l2_norm, Oracles.DerivativeOracle, x -> begin
            norm_x = sqrt(sum(x .^ 2))
            # Guard against division by zero
            if norm_x < eps()
                return zeros(size(x))
            else
                return x ./ norm_x
            end
        end
    )

    # Register proximal oracle for L2 norm
    register_oracle_handler(
        :l2_norm, Oracles.ProximalOracle, (x, t) -> begin
            norm_x = sqrt(sum(x .^ 2))
            # Block soft thresholding
            if norm_x <= t
                return zeros(size(x))
            else
                return x .* (1 - t / norm_x)
            end
        end
    )

    # Register property handlers for L2 norm
    register_property_handler(
        :l2_norm, Properties.Convexity, (expr, context) -> Properties.Convex()
    )

    register_property_handler(
        :l2_norm, Properties.Monotonicity, (expr, context) -> Properties.NonMonotone()
    )

    # Register actual properties
    return Properties.register_property!(:l2_norm, Properties.Convex())
end

"""
    l1_norm(expr::Language.Expression) -> Language.FunctionCall

Create an L1 norm function call for an expression.
"""
function l1_norm(expr::Language.Expression)
    return create_special_function(:l1_norm, [expr])
end

"""
    l2_norm(expr::Language.Expression) -> Language.FunctionCall

Create an L2 norm function call for an expression.
"""
function l2_norm(expr::Language.Expression)
    return create_special_function(:l2_norm, [expr])
end