# src/special_functions/transformers.jl
using ..Language
using ..Oracles
using ..Properties

# Registry of all monotone transformers
const monotone_transformers = Symbol[:sqrt_function, :log_plus_one]

"""
    register_monotone_transformers()

Register all monotone transformer functions.
"""
function register_monotone_transformers()
    # Register sqrt function
    sqrt_info = register_special_function(
        :sqrt_function, "Square root function (monotone increasing for x >= 0)"
    )

    # Register evaluation oracle for sqrt
    register_oracle_handler(:sqrt_function, Oracles.EvaluationOracle, x -> sqrt.(x))

    # Register derivative oracle for sqrt
    register_oracle_handler(
        :sqrt_function, Oracles.DerivativeOracle, x -> 0.5 ./ max.(sqrt.(x), eps())
    )

    # Register property handlers for sqrt
    register_property_handler(
        :sqrt_function,
        Properties.Convex,
        (expr, context) -> begin
            # If input is convex and non-negative, output is concave (sqrt is concave for x >= 0)
            # If input is concave and non-negative, output is still concave
            arg_convexity = Properties.infer_property(expr.args[1], Properties.Convex, context)
            arg_sign = Properties.infer_property(expr.args[1], Properties.Sign, context)

            if arg_sign == Properties.Nonnegative() && (
                arg_convexity == Properties.Convex() ||
                arg_convexity == Properties.Concave()
            )
                return Properties.Concave()
            else
                return Properties.Unknown()
            end
        end,
    )

    register_property_handler(
        :sqrt_function, Properties.MonotonicallyIncreasing, (expr, context) -> Properties.Increasing()
    )

    # Register actual properties directly
    Properties.register_property!(:sqrt_function, Properties.Concave())
    Properties.register_property!(:sqrt_function, Properties.Increasing())

    # Register log(1+x) function
    log_info = register_special_function(
        :log_plus_one, "Natural logarithm of (1 + x) (monotone increasing for x > -1)"
    )

    # Register evaluation oracle for log(1+x)
    register_oracle_handler(:log_plus_one, Oracles.EvaluationOracle, x -> log.(1 .+ x))

    # Register derivative oracle for log(1+x)
    register_oracle_handler(
        :log_plus_one, Oracles.DerivativeOracle, x -> 1 ./ max.(1 .+ x, eps())
    )

    # Register property handlers for log(1+x)
    register_property_handler(
        :log_plus_one,
        Properties.Convexity,
        (expr, context) -> begin
            # log(1+x) is concave for x > -1
            arg_sign = Properties.infer_property(expr.args[1], Properties.Sign, context)

            if arg_sign == Properties.GreaterThan(-1) ||
                arg_sign == Properties.Nonnegative()
                return Properties.Concave()
            else
                return Properties.Unknown()
            end
        end,
    )

    register_property_handler(
        :log_plus_one, Properties.Monotonicity, (expr, context) -> Properties.Increasing()
    )

    # Register actual properties directly
    Properties.register_property!(:log_plus_one, Properties.Concave())
    return Properties.register_property!(:log_plus_one, Properties.Increasing())
end

"""
    sqrt_function(expr::Language.Expression) -> Language.FunctionCall

Create a square root function call for an expression.
"""
function sqrt_function(expr::Language.Expression)
    return create_special_function(:sqrt_function, [expr])
end

"""
    log_plus_one(expr::Language.Expression) -> Language.FunctionCall

Create a log(1+x) function call for an expression.
"""
function log_plus_one(expr::Language.Expression)
    return create_special_function(:log_plus_one, [expr])
end