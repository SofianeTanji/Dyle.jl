using Test
using Dyle
using Dyle.Language
using Dyle.Properties

@testset "Property Interface Tests" begin
    # Create a default provider
    provider = DefaultPropertyProvider()

    # Define test variables and functions
    @variable x::R()
    @func f(R(), R())

    # Test registering properties through the provider
    @test begin
        register_property(provider, :f, Convex())
        register_property(provider, :f, Smooth(2.0))
        true
    end

    # Test getting properties
    props = get_properties(provider, :f)
    @test length(props) == 2
    @test any(p isa Convex for p in props)
    @test any(p isa Smooth for p in props)

    # Test has_property
    @test has_property(provider, :f, Convex)
    @test has_property(provider, :f, Smooth)
    @test !has_property(provider, :f, StronglyConvex)

    # Test get_property
    smooth_prop = get_property(provider, :f, Smooth)
    @test smooth_prop isa Smooth
    @test smooth_prop.L.lower == 2.0

    # Test infer_properties with provider
    expr = f(x)
    inferred_props = infer_properties(provider, expr)
    @test length(inferred_props) == 2
    @test any(p isa Convex for p in inferred_props)
    @test any(p isa Smooth for p in inferred_props)

    # Test clear_properties
    clear_properties(provider, :f)
    @test isempty(get_properties(provider, :f))

    # Test with a composite expression
    register_property(provider, :f, Convex())
    @func g(R(), R())
    register_property(provider, :g, Smooth(1.0))

    composite_expr = f(x) + g(x)
    composite_props = infer_properties(provider, composite_expr)
    @test !isempty(composite_props)
end
