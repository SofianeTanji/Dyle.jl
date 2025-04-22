using Dyle
using Dyle.Language
using Test

Rns = Rn(:n)

@variable x::R()
@variable y::R()
@variable v::Rns

@func f(R(), R())
@func g(Rns, R())

expr1 = f(x) + f(y)
expr2 = g(v)
expr3 = f(x) + g(v)
expr4 = f(x) + g(v) + f(y)

f(x) + f
