using Revise
using Argo
using Argo.Language
using Test

@variable x::R()
@func f(R(), R())
@func g(R(), R())
@func h(R(), R())

expr_comp = (f ∘ g ∘ h)

typeof(expr_comp) == Composition

using Argo.Reformulations

reform_comp = generate_reformulations(expr_comp)

@test length(reform_comp) == 2

reform_expr = generate_reformulations(expr_comp(x))

@test length(reform_expr) == 2
