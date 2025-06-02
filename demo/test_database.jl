using Test
using Argo
import Argo.Database:
    Template,
    Method,
    Rate,
    get_rates_by_template,
    get_rates_by_method,
    get_all_rates,
    get_rates,
    list_templates,
    list_methods,
    list_measures,
    NotFoundError
using Argo.Language: Literal, R

@testset "Database module unit tests" begin
    # -- Dummy entry must be present --
    @test :dummy in [t.name for t in list_templates()]
    @test :dummy_method in [m.name for m in list_methods()]

    # -- get_all_rates returns the full Dict --
    db = get_all_rates()
    @test typeof(db) <: Dict
    tpl = first(filter(t -> t.name == :dummy, list_templates()))
    mtd = first(filter(m -> m.name == :dummy_method, list_methods()))
    @test haskey(db, (tpl, mtd))

    # -- get_rates_by_template --
    rates_t = get_rates_by_template(:dummy)
    @test mtd in keys(rates_t)
    @test length(rates_t[mtd]) == 1

    # -- get_rates_by_method --
    rates_m = get_rates_by_method(:dummy_method)
    @test tpl in keys(rates_m)

    # -- get_rates (by measure) --
    rates = get_rates(:dummy, :dummy_method, :SuboptimalityGap)
    @test length(rates) == 1
    @test rates[1].measure == :SuboptimalityGap

    # -- list_measures --
    ms = list_measures(:dummy, :dummy_method)
    @test ms == [:SuboptimalityGap]

    # -- NotFoundError on missing entries --
    @test_throws NotFoundError get_rates_by_template(:nope)
    @test_throws NotFoundError get_rates_by_method(:nope)
    @test_throws NotFoundError get_rates(:dummy, :dummy_method, :nope)
    @test_throws NotFoundError list_measures(:nope, :dummy_method)

    # -- Equality & hashing based on name only --
    t1 = Template(:same, Literal(0, R()), Dict())
    t2 = Template(:same, Literal(1, R()), Dict())
    @test t1 == t2
    @test hash(t1) == hash(t2)

    m1 = Method(:same_method, t1, [:a], [:b], Dict())
    m2 = Method(:same_method, t2, [:x], [:y], Dict())
    @test m1 == m2
    @test hash(m1) == hash(m2)
end
