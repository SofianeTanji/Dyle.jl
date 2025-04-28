using Dyle
using Dyle.Language
using Dyle.Properties
using Test

Rns = Rn(:n)

@variable x::R()
@variable y::R()
@variable v::Rns

@func f(R(), R())
@func g(Rns, R())

expr1 = f(x) + f(x)
expr2 = g(v)
expr3 = f(x) + g(v)

@property f StronglyConvex(1.0) Smooth(2.0)
@property g Convex() Lipschitz(5.0)
@property h Linear(1.0, 3.0)

f_props = get_properties(:f)
g_props = get_properties(:g)

expr1_props = infer_properties(expr1)
expr2_props = infer_properties(expr2)
expr3_props = infer_properties(expr3)


@func quad1(R(), R())
@func quad2(R(), R())
@property quad1 Quadratic(1.0, 2.0)
@property quad2 Quadratic(0.5, 1.5)

quad_sum = quad1(x) + quad2(x)
quad_sum_props = infer_properties(quad_sum)

expr4 = f(x) + quad1(x) + quad2(x) # (Strongly Convex + Smooth) + Quadratic + Quadratic
expr4_props = infer_properties(expr4)

expr5 = f(x) - f(x)

expr5_props = infer_properties(expr5)
