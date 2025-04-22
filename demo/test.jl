using Dyle
using Dyle.Language

@func f g h
@variable x
expr = @expression (f - g(x)) + f(x) + g(h(x))
