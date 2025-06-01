using Revise
using Argo
using Argo.Language
using Argo.Properties
using Argo.Oracles
using Argo.Reformulations
using Test

@variable x::R()
@func f(R(), R())
@func g(R(), R())
@func h(R(), R())
@property f HypoConvex()
@property g Convex()
expr_add = f(x) + g(x)

r = create_reformulation(expr_add)

# Test create_reformulation helper
r2 = create_reformulation(expr_add)
@test isa(r2, Reformulation)
@test r2.expr == expr_add
@test length(r2.properties) == 1
@test isempty(r2.oracles)

# Test strategy registry
strategy = register_strategy(:identity, expr -> [expr])
@test :identity in list_strategies()
@test get_strategy(:identity) === strategy
@test get_strategy(:identity)(expr_add) == [expr_add]
@test apply_strategy(:identity, expr_add) == [expr_add]

# Test commutativity strategy
@test :commutativity in list_strategies()
p2 = apply_strategy(:commutativity, expr_add)
@test length(p2) == 2
@test all(e -> isa(e, Addition), p2)

# Test commutativity on three-term addition
expr3 = f(x) + g(x) + h(x)
p3 = apply_strategy(:commutativity, expr3)
@test length(p3) == 6
@test all(e -> isa(e, Addition), p3)

# Test error on unknown strategy
@test_throws ErrorException get_strategy(:unknown)

reforms = generate_reformulations(expr_add)
generate_reformulations(expr3)

# Test structure-loss strategy
expr_nested = f(x) + g(f(x))
sl_nested = apply_strategy(:structure_loss, expr_nested)