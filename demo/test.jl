using Dyle
using Dyle.Language
using Test

Rns = Rn(:n)

@variable x::R()
@variable y::R()
@variable v::Rns

@func f(R(), R())
@func g(Rns, R())
@func h(R(), Rns)
expr1 = f(x) + f(y)
expr2 = g(v)
expr3 = f(x) + g(v)
expr4 = f(x) + g(v) + f(y)
expr5 = f(g(v))
expr6 = min(h(y), h(x))
expr = (f(x) - g(v)) + f(x) + g(h(x))
