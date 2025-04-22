import Base: +, -, ∘, max, min, |>, show

"""Expression
A type representing a mathematical expression.
Base type for all expression types in the system.
"""
abstract type Expression end

"""Variable <: Expression
A type representing a variable in an expression.
Fields:
- `name::Symbol`: The name of the variable, represented as a symbol.
- `space::Space`: The space to which the variable belongs, represented as a `Space` type.
"""
struct Variable <: Expression
    name::Symbol
end

"""FunctionCall <: Expression
A type representing a function call in an expression.

Fields:
- `name::Symbol`: The name of the function being called.
- `args::Vector{Expression}`: The arguments to the function call, represented as a vector of `Expression` types.
"""
struct FunctionCall <: Expression
    name::Symbol
    args::Vector{Expression}
end

"""Addition <: Expression
A type representing the sum of multiple expressions.
Fields:
- `terms::Vector{Expression}`: The terms to be added together, represented as a vector of `Expression` types.
"""
struct Addition <: Expression
    terms::Vector{Expression}
end

"""Subtraction <: Expression
A type representing the difference of multiple expressions.
First term is the minuend, and the rest are subtrahends.
Fields:
- terms::Vector{Expression}: The terms to be subtracted, represented as a vector of `Expression` types.
"""
struct Subtraction <: Expression
    terms::Vector{Expression}
end

"""Composition <: Expression
A type representing the composition of two expressions (outer ∘ inner).
Fields:
- `outer::Expression`: The outer expression.
- `inner::Expression`: The inner expression.
"""
struct Composition <: Expression
    outer::Expression
    inner::Expression
end

"""Maximum <: Expression
A type representing the maximum of multiple expressions.
Fields:
- `terms::Vector{Expression}`: The terms to be compared, represented as a vector of `Expression` types.
"""
struct Maximum <: Expression
    terms::Vector{Expression}
end

"""Minimum <: Expression
A type representing the minimum of multiple expressions.
Fields:
- `terms::Vector{Expression}`: The terms to be compared, represented as a vector of `Expression` types.
"""
struct Minimum <: Expression
    terms::Vector{Expression}
end

# Operator overloading

+(a::Expression, b::Expression) = Addition([a, b])
+(a::Addition, b::Expression) = Addition([a.terms..., b])
+(a::Expression, b::Addition) = Addition([a, b.terms...])

-(a::Expression, b::Expression) = Subtraction([a, b])

∘(f::Expression, g::Expression) = Composition(f, g)

max(a::Expression, b::Expression) = Maximum([a, b])
min(a::Expression, b::Expression) = Minimum([a, b])

function (f::Symbol)(args::Expression...) # space should be filled in during type checking
    return FunctionCall(f, collect(args))
end

# String representation

function show(io::IO, v::Variable)
    print(io, v.name)
end

function show(io::IO, f::FunctionCall)
    print(io, f.name, "(", join(string.(f.args), ", "), ")")
end

function show(io::IO, a::Addition)
    if isempty(a.terms)
        print(io, "0")
    else
        print(io, join(string.(a.terms), " + "))
    end
end

function show(io::IO, s::Subtraction)
    if isempty(s.terms)
        print(io, "0")
    elseif length(s.terms) == 1
        print(io, s.terms[1])
    else
        print(io, string(s.terms[1]), " - ", join(string.(s.terms[2:end]), " - "))
    end
end

function show(io::IO, c::Composition)
    print(io, "(", c.outer, " ∘ ", c.inner, ")")
end

function show(io::IO, m::Maximum)
    print(io, "max(", join(string.(m.terms), ", "), ")")
end

function show(io::IO, m::Minimum)
    print(io, "min(", join(string.(m.terms), ", "), ")")
end
