using Test
using Argo

@testset "Special Functions" begin
    # Test L1 norm
    expr = Argo.Language.FunctionCall(:test_func, [])
    l1 = Argo.SpecialFunctions.l1_norm(expr)

    # Test if the L1 norm is recognized as convex
    @test Argo.Properties.infer_property(l1, Argo.Properties.Convexity) == Argo.Properties.Convex()

    # Test sqrt transformation
    sqrt_expr = Argo.SpecialFunctions.sqrt_function(expr)

    # Test if sqrt is recognized as concave and increasing
    @test Argo.Properties.infer_property(sqrt_expr, Argo.Properties.Monotonicity) == Argo.Properties.Increasing()

    # Test MonotoneTransform strategy
    reformulations = Argo.Reformulations.apply_strategy(:monotone_transform, expr)
    @test length(reformulations) > 0

    # Test that sqrt and log(1+x) transformations are included
    @test any(r -> contains(string(r.expr), "sqrt_function"), reformulations)
    @test any(r -> contains(string(r.expr), "log_plus_one"), reformulations)
end
