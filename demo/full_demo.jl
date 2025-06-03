using Revise
using Argo
using Argo.Language        # variable, func, expressions
using Argo.Templates       # register and match templates
using Argo.Properties      # property registration and inference
using Argo.Oracles         # oracle registration and queries
using Argo.Reformulations  # generate reformulations

println("============= LANGUAGE MODULE =============")
# Define spaces and symbols
@variable x::R()
@variable y::R()
@func f(R(), R())
@func g(R(), R())
# Build and display expressions
e1 = f(x) + g(y)
println("Expression e1: ", e1)
println("Parsed AST type: ", typeof(e1))

println("\n============= TEMPLATES MODULE =============")
using Argo.Templates: register_template, require_function, matches_template
# Register a custom demo template
tmpl = register_template(
    :demo_template,
    f(x) + g(x),
    "Demo template for f+g";
    function_requirements=[
        require_function(
            :f, f(x), "square", [EvaluationOracle, DerivativeOracle], [], Dict()
        ),
        require_function(
            :g, "sine function", [EvaluationOracle, DerivativeOracle], [], Dict()
        ),
    ],
)
println("Registered template: ", tmpl)
matched = matches_template(f(x) + g(x), tmpl)
println("Does f(x)+g(x) match demo_template? ", matched)

println("\n============= PROPERTIES MODULE =============")
# Register and infer properties
@property f StronglyConvex(1.0) Smooth(2.0)
@property g Convex() Lipschitz(3.0)
e2 = f(x) + g(x)
props = infer_properties(e2)
println("Inferred properties for e2 = f(x)+g(x): ", props)

println("\n============= ORACLES MODULE =============")
# Register simple oracles
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2 * x)
@oracle g EvaluationOracle(x -> sin(x))
@oracle g DerivativeOracle(x -> cos(x))
# Compose oracles to evaluate and derive composite expr
e3 = f(x)
eval3 = get_oracle_for_expression(e3, EvaluationOracle)
deriv3 = get_oracle_for_expression(e3, DerivativeOracle)
pt = 2.0
println("f(g(x)) at x=", pt, " = ", eval3(pt))
println("(f\u27(g(x))) at x=", pt, " = ", deriv3(pt))

println("\n============= REFORMULATIONS MODULE =============")
# Generate reformulations
reforms = generate_reformulations(f(x) + g(x); max_iterations=1)
println("Reformulations of f(x)+g(x): ", reforms)

println("\nAll modules demo completed.")
