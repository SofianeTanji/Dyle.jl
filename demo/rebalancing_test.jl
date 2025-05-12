using Test
using Argo
using Argo.Language
using Argo.Reformulations

@variable x::R()
@func f(R(), R())
@func g(R(), R())
@func h(R(), R())

@testset "Rebalancing Strategy Tests" begin
    @testset "Addition splits" begin
        expr = f(x) + g(x) + h(x)
        reforms = apply_strategy(:rebalancing, expr)
        @test length(reforms) >= 2

        found_left = false
        found_right = false
        for r in reforms
            if r.expr isa Addition && length(r.expr.terms) == 2
                t1, t2 = r.expr.terms
                # Check (f + g) + h
                if t1 isa Addition && length(t1.terms) == 2 && t2 isa FunctionCall
                    names = map(t -> t.name, t1.terms)
                    if names == [:f, :g] && t2.name == :h
                        found_left = true
                    end
                end
                # Check f + (g + h)
                if t2 isa Addition && length(t2.terms) == 2 && t1 isa FunctionCall
                    names = map(t -> t.name, t2.terms)
                    if t1.name == :f && names == [:g, :h]
                        found_right = true
                    end
                end
            end
        end
        @test found_left && found_right
    end

    @testset "Nested addition alternative grouping" begin
        base = f(x) + g(x)
        expr = base + h(x)
        reforms = apply_strategy(:rebalancing, expr)
        # Expect f + (g + h) as one reformulation
        @test any(
            r ->
                r.expr isa Addition &&
                    r.expr.terms[2] isa Addition &&
                    r.expr.terms[2].terms[1].name == :g &&
                    r.expr.terms[2].terms[2].name == :h,
            reforms,
        )
    end
end