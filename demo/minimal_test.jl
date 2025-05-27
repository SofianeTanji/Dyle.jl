using Revise
using Argo
using Argo.Language
using Argo.Reformulations
using Test

@show list_strategies()
@show get_strategy(:structure_loss)

@variable x::R()
@func f(R(), R())
@func g(R(), R())
@func h(R(), R())

expr_comp = f(x)

typeof(expr_comp) == Composition
apply_strategy(:monotone_transform, expr_comp)
reform_comp = generate_reformulations(expr_comp)

@test length(reform_comp) == 3

expr_eval = expr_comp(x)
typeof(expr_eval)
expr_eval.args
expr_eval.name
reform_expr = generate_reformulations(expr_comp(x))

@test length(reform_expr) == 4
