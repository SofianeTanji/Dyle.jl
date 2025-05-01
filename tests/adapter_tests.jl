using Test
using Dyle
using Dyle.Language
using Dyle.Properties
using Dyle.Oracles
using Dyle.Templates
using Dyle.Templates.Adapters

@testset "Property Adapter Tests" begin
    # Define test variables and functions
    @variable x::R()
    @func f(R(), R())

    # Register properties for functions
    @property f StronglyConvex(1.0) Smooth(2.0)

    # Test meets_property_requirements
    @test PropertyAdapter.meets_property_requirements(:f, [StronglyConvex, Smooth])
    @test PropertyAdapter.meets_property_requirements(:f, [StronglyConvex])
    @test PropertyAdapter.meets_property_requirements(:f, [Smooth])
    @test !PropertyAdapter.meets_property_requirements(:f, [Lipschitz])

    # Test get_parameter_value
    μ = PropertyAdapter.get_parameter_value(:f, StronglyConvex, :μ)
    L = PropertyAdapter.get_parameter_value(:f, Smooth, :L)

    @test μ !== nothing
    @test L !== nothing
    @test μ.lower == 1.0 && μ.upper == 1.0
    @test L.lower == 2.0 && L.upper == 2.0

    # Test get_properties_for_function
    props = PropertyAdapter.get_properties_for_function(:f)
    @test length(props) == 2
    @test any(p isa StronglyConvex for p in props)
    @test any(p isa Smooth for p in props)

    # Test infer_properties_for_expression
    expr = f(x)
    inferred_props = PropertyAdapter.infer_properties_for_expression(expr)
    @test length(inferred_props) >= 1
    @test any(p isa StronglyConvex for p in inferred_props)
end

@testset "Oracle Adapter Tests" begin
    # Define test variables and functions
    @variable x::R()
    @func f(R(), R())

    # Register oracles for functions
    @oracle f EvaluationOracle(x -> x^2)
    @oracle f DerivativeOracle(x -> 2 * x)

    # Test meets_oracle_requirements
    @test OracleAdapter.meets_oracle_requirements(:f, [EvaluationOracle, DerivativeOracle])
    @test OracleAdapter.meets_oracle_requirements(:f, [EvaluationOracle])
    @test OracleAdapter.meets_oracle_requirements(:f, [DerivativeOracle])
    @test !OracleAdapter.meets_oracle_requirements(:f, [ProximalOracle])

    # Test get_oracle_for_function
    eval_oracle = OracleAdapter.get_oracle_for_function(:f, EvaluationOracle)
    deriv_oracle = OracleAdapter.get_oracle_for_function(:f, DerivativeOracle)

    @test eval_oracle !== nothing
    @test deriv_oracle !== nothing
    @test eval_oracle(2.0) == 4.0
    @test deriv_oracle(2.0) == 4.0

    # Test get_oracle_for_expr
    expr = f(x)
    expr_eval = OracleAdapter.get_oracle_for_expr(expr, EvaluationOracle)
    expr_deriv = OracleAdapter.get_oracle_for_expr(expr, DerivativeOracle)

    @test expr_eval !== nothing
    @test expr_deriv !== nothing
    @test expr_eval(2.0) == 4.0
    @test expr_deriv(2.0) == 4.0

    # Test get_oracle_metadata and related functions
    metadata = OracleAdapter.get_oracle_metadata(:f, EvaluationOracle)
    @test metadata !== nothing
    @test metadata.exactness isa Exact

    exactness = OracleAdapter.get_exactness(:f, EvaluationOracle)
    @test exactness isa Exact
end

@testset "Template Matching with Adapters" begin
    # Define test variables and functions
    @variable x::R()
    @func f(R(), R())
    @func g(R(), R())

    # Register properties and oracles
    @property f StronglyConvex(1.0) Smooth(2.0)
    @property g Convex() Lipschitz(3.0)

    @oracle f EvaluationOracle(x -> x^2)
    @oracle f DerivativeOracle(x -> 2 * x)
    @oracle g EvaluationOracle(x -> sin(x))
    @oracle g DerivativeOracle(x -> cos(x))

    # Create a template with requirements - this will ensure g(x) doesn't match
    simple_template = :simple_template
    register_template(simple_template, f(x), "Simple template")

    # Add specific requirements that only f should match
    @add_requirements simple_template require_function(
        :f,
        "Function f",
        [StronglyConvex],
        [EvaluationOracle],
    )

    # Add method/rate for completeness
    add_method_to_template(
        simple_template,
        create_method("Test Method", "A test method"),
        create_rate(
            "Test Rate",
            "A test rate",
            SuboptimalityGap,
            (k, initial, params) -> params[:L] / (2 * k) * initial,
            "O(1/k)",
        ),
    )

    # Now test matching - with requirements, g should not match the template
    @test matches_template(f(x), simple_template)
    @test !matches_template(g(x), simple_template)

    # Test function mapping
    mapping = get_function_mapping(f(x), simple_template)
    @test mapping !== nothing
    @test length(mapping) == 1
    @test first(values(mapping)) == :f

    # Create a complex template with a unique name to avoid conflicts
    unique_template = Symbol("complex_template_", rand(1:1000))
    register_template(unique_template, f(x) + g(x), "Complex template")

    # Add requirements directly
    @add_requirements unique_template require_function(
        :f,
        "Function f",
        [StronglyConvex, Smooth],
        [EvaluationOracle, DerivativeOracle],
    )

    @add_requirements unique_template require_function(
        :g,
        "Function g",
        [Convex],
        [EvaluationOracle],
    )

    # Test if the expression matches the template
    @test matches_template(f(x) + g(x), unique_template)

    # Test get_parameter_values
    params = get_parameter_values(f(x) + g(x), unique_template)
    @test params !== nothing
    @test haskey(params, :f)
    @test haskey(params[:f], :μ)
    @test haskey(params[:f], :L)
    @test params[:f][:μ].lower == 1.0
    @test params[:f][:L].lower == 2.0
end
