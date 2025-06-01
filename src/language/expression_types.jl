import Base: +, -, ∘, max, min, |>, show

"""Expression
A type representing a mathematical expression.
Base type for all expression types in the system.

All Expression subtypes must have a `space` field indicating
the mathematical space to which the expression's value belongs.
"""
abstract type Expression end

# Method to access the space of any expression (must be implemented by subtypes)
space(e::Expression) = e.space

"""Literal <: Expression
A type representing a literal value (constant) in an expression.

Fields:
- `value`: The literal value
- `space::Space`: The space to which the value belongs
"""
struct Literal <: Expression
    value::Any
    space::Space
end

"""Variable <: Expression
A type representing a variable in an expression.

Fields:
- `name::Symbol`: The name of the variable, represented as a symbol.
- `space::Space`: The space to which the variable belongs.
"""
struct Variable <: Expression
    name::Symbol
    space::Space

    # No default constructor - space must be explicitly provided
    function Variable(name::Symbol, space::Space)
        return new(name, space)
    end
end

"""FunctionType <: Expression
A type representing a function's type signature.

Fields:
- `name::Symbol`: The name of the function.
- `domain::Space`: The domain space of the function.
- `codomain::Space`: The codomain space of the function.
- `space::Space`: The space of the expression (same as codomain).
"""
struct FunctionType <: Expression
    name::Symbol
    domain::Space
    codomain::Space
    space::Space

    # 3-arg constructor sets space = codomain
    function FunctionType(name::Symbol, domain::Space, codomain::Space)
        return new(name, domain, codomain, codomain)
    end

    # 4-arg constructor
    function FunctionType(name::Symbol, domain::Space, codomain::Space, space::Space)
        return new(name, domain, codomain, space)  # use the provided space
    end
end

# Composition operator for two FunctionType objects
function ∘(f::FunctionType, g::FunctionType)
    if f.domain != g.codomain
        error("Type mismatch in function composition: $(g.name) -> $(f.name)")
    end
    return Composition(f, g, f.codomain)
end

# Equality for FunctionType
function ==(a::FunctionType, b::FunctionType)
    return a.name == b.name && a.domain == b.domain && a.codomain == b.codomain
end

# Hash for FunctionType
function hash(ft::FunctionType, h::UInt)
    return hash((ft.name, ft.domain, ft.codomain), h)
end

"""FunctionCall <: Expression
A type representing a function call in an expression.

Fields:
- `name::Symbol`: The name of the function being called.
- `args::Vector{Expression}`: The arguments to the function call.
- `space::Space`: The space of the result (the codomain of the function).
"""
struct FunctionCall <: Expression
    name::Expression # Changed from Symbol to Expression
    args::Vector{Expression}
    space::Space

    # Constructor for when name is an Expression (e.g., FunctionType or Composition)
    function FunctionCall(name::Expression, args::Vector{Expression}, space::Space)
        if name isa FunctionType && name.codomain != space
            error(
                "FunctionCall space $(space) mismatches FunctionType codomain $(name.codomain)",
            )
        end
        if name isa Composition && name.space != space # .space of Composition is its codomain
            error("FunctionCall space $(space) mismatches Composition space $(name.space)")
        end
        return new(name, args, space)
    end
    # Constructor for when we have a FunctionType and arguments
    function FunctionCall(func::FunctionType, args::Vector{Expression})
        return FunctionCall(func, args, func.codomain)
    end
end

"""Addition <: Expression
A type representing the sum of multiple expressions.

Fields:
- `terms::Vector{Expression}`: The terms to be added.
- `space::Space`: The space of the result of the addition.
"""
struct Addition <: Expression
    terms::Vector{Expression}
    space::Space

    function Addition(terms::Vector{Expression}, space::Space)
        if isempty(terms)
            # Empty addition is allowed, and its space is provided explicitly
            return new(terms, space)
        end

        # Check that all terms have the same space
        for term in terms
            if term.space != space
                error(
                    "Type mismatch in addition: term has space $(term.space) but expected $(space)",
                )
            end
        end

        return new(terms, space)
    end
end

"""Subtraction <: Expression
A type representing the difference of multiple expressions.
First term is the minuend, and the rest are subtrahends.

Fields:
- `terms::Vector{Expression}`: The terms in the subtraction.
- `space::Space`: The space of the result of the subtraction.
"""
struct Subtraction <: Expression
    terms::Vector{Expression}
    space::Space

    function Subtraction(terms::Vector{Expression}, space::Space)
        if isempty(terms)
            # Empty subtraction is allowed, and its space is provided explicitly
            return new(terms, space)
        end

        # Check that all terms have the same space
        for term in terms
            if term.space != space
                error(
                    "Type mismatch in subtraction: term has space $(term.space) but expected $(space)",
                )
            end
        end

        return new(terms, space)
    end
end

"""Composition <: Expression
A type representing the composition of two expressions (outer ∘ inner).

Fields:
- `outer::Expression`: The outer expression.
- `inner::Expression`: The inner expression.
- `space::Space`: The space of the result of the composition.
"""
struct Composition <: Expression
    outer::Expression
    inner::Expression
    space::Space

    function Composition(outer::Expression, inner::Expression, space::Space)
        # The space check between inner's output and outer's domain requires
        # information about function domains and codomains that might not be
        # available for arbitrary expressions. This would require a full type system.
        # For now, we just require the user to provide the expected result space.
        return new(outer, inner, space)
    end
end

"""Maximum <: Expression
A type representing the maximum of multiple expressions.

Fields:
- `terms::Vector{Expression}`: The terms to be compared.
- `space::Space`: The space of the result of the maximum.
"""
struct Maximum <: Expression
    terms::Vector{Expression}
    space::Space

    function Maximum(terms::Vector{Expression}, space::Space)
        if isempty(terms)
            # Empty maximum is allowed, and its space is provided explicitly
            return new(terms, space)
        end

        # Check that all terms have the same space
        for term in terms
            if term.space != space
                error(
                    "Type mismatch in maximum: term has space $(term.space) but expected $(space)",
                )
            end
        end

        return new(terms, space)
    end
end

"""Minimum <: Expression
A type representing the minimum of multiple expressions.

Fields:
- `terms::Vector{Expression}`: The terms to be compared.
- `space::Space`: The space of the result of the minimum.
"""
struct Minimum <: Expression
    terms::Vector{Expression}
    space::Space

    function Minimum(terms::Vector{Expression}, space::Space)
        if isempty(terms)
            # Empty minimum is allowed, and its space is provided explicitly
            return new(terms, space)
        end

        # Check that all terms have the same space
        for term in terms
            if term.space != space
                error(
                    "Type mismatch in minimum: term has space $(term.space) but expected $(space)",
                )
            end
        end

        return new(terms, space)
    end
end

# Operator overloading - requires explicit space compatibility

function +(a::Expression, b::Expression)
    if a.space != b.space
        error("Cannot add expressions from different spaces: $(a.space) and $(b.space)")
    end
    # Use Expression[] to create a vector of the base type
    return Addition(Expression[a, b], a.space)
end

function +(a::Addition, b::Expression)
    if a.space != b.space
        error("Cannot add expressions from different spaces: $(a.space) and $(b.space)")
    end
    # Create a new vector of type Expression
    terms = Expression[term for term in a.terms]
    push!(terms, b)
    return Addition(terms, a.space)
end

function +(a::Expression, b::Addition)
    if a.space != b.space
        error("Cannot add expressions from different spaces: $(a.space) and $(b.space)")
    end
    # Create a new vector of type Expression
    terms = Expression[a]
    append!(terms, Expression[term for term in b.terms])
    return Addition(terms, a.space)
end

function -(a::Expression, b::Expression)
    if a.space != b.space
        error(
            "Cannot subtract expressions from different spaces: $(a.space) and $(b.space)"
        )
    end
    return Subtraction(Expression[a, b], a.space)
end

function ∘(f::Expression, g::Expression)
    # Check if both f and g have the domain/codomain attributes
    if hasfield(typeof(f), :codomain) && hasfield(typeof(g), :domain)
        # Type checking for function composition
        if f.codomain != g.domain
            error(
                "Type mismatch in composition: $(f.codomain) and $(g.domain) are not compatible.",
            )
        end
        return Composition(f, g, f.codomain)
    else
        error(
            "Cannot compose expressions without type information: $(typeof(f)) and $(typeof(g)).",
        )
    end
end

# composition of a Composition AST with a FunctionType on the right
function ∘(c::Composition, g::FunctionType)
    if c.space != g.codomain
        error(
            "Type mismatch in composition: $(c.space) and $(g.codomain) are not compatible."
        )
    end
    return Composition(c, g, c.space)
end

# composition of a FunctionType on the left with a Composition AST on the right
function ∘(f::FunctionType, c::Composition)
    if f.domain != c.space
        error(
            "Type mismatch in composition: $(f.domain) and $(c.space) are not compatible."
        )
    end
    return Composition(f, c, f.codomain)
end

function max(a::Expression, b::Expression)
    if a.space != b.space
        error(
            "Cannot take maximum of expressions from different spaces: $(a.space) and $(b.space)",
        )
    end
    return Maximum(Expression[a, b], a.space)
end

function min(a::Expression, b::Expression)
    if a.space != b.space
        error(
            "Cannot take minimum of expressions from different spaces: $(a.space) and $(b.space)",
        )
    end
    return Minimum(Expression[a, b], a.space)
end

# n-ary max/min building flat nodes
function max(a::Expression, b::Expression, rest::Expression...)
    space = a.space
    terms = Expression[]
    for expr in (a, b, rest...)
        if expr.space != space
            error(
                "Cannot take maximum of expressions from different spaces: $(space) and $(expr.space)",
            )
        end
        if expr isa Maximum
            append!(terms, expr.terms)
        else
            push!(terms, expr)
        end
    end
    return Maximum(terms, space)
end

function min(a::Expression, b::Expression, rest::Expression...)
    space = a.space
    terms = Expression[]
    for expr in (a, b, rest...)
        if expr.space != space
            error(
                "Cannot take minimum of expressions from different spaces: $(space) and $(expr.space)",
            )
        end
        if expr isa Minimum
            append!(terms, expr.terms)
        else
            push!(terms, expr)
        end
    end
    return Minimum(terms, space)
end

# Function call operators - these are complex and require careful type checking

function (f::FunctionType)(args::Expression...)
    args_vec = Expression[arg for arg in args]
    return FunctionCall(f, args_vec, f.codomain)
end

# Callable Composition: (f ∘ g)(x) should create FunctionCall( (f ∘ g), [x])
function (c::Composition)(args::Expression...)
    args_vec = Expression[arg for arg in args]
    return FunctionCall(c, args_vec, c.space)
end

# We don't support directly calling a symbol as a function anymore
# This should be handled by the parser or by the @func macro
function (f::Symbol)(args::Expression...)
    return error(
        "Cannot call symbol $(f) as a function. Please declare it with @func first."
    )
end

# String representation

function show(io::IO, v::Variable)
    return print(io, v.name)
end

function show(io::IO, f::FunctionCall)
    # If f.name is a FunctionType, print its actual name symbol
    # Otherwise, print the expression (e.g., a Composition)
    name_str = f.name isa FunctionType ? string(f.name.name) : string(f.name)
    return print(io, name_str, "(", join(string.(f.args), ", "), ")")
end

# Custom printing for Expression types to show grouping with parentheses
function show(io::IO, a::Addition)
    if isempty(a.terms)
        print(io, "0")
    elseif length(a.terms) == 1
        show(io, a.terms[1])
    else
        print(io, "(")
        for (i, term) in enumerate(a.terms)
            show(io, term)
            if i < length(a.terms)
                print(io, " + ")
            end
        end
        print(io, ")")
    end
end

function show(io::IO, s::Subtraction)
    if isempty(s.terms)
        print(io, "0")
    elseif length(s.terms) == 1
        show(io, s.terms[1])
    else
        print(io, "(")
        show(io, s.terms[1])
        for i in 2:length(s.terms)
            print(io, " - ")
            show(io, s.terms[i])
        end
        print(io, ")")
    end
end

function show(io::IO, c::Composition)
    print(io, "(")
    show(io, c.outer)
    print(io, " ∘ ")
    show(io, c.inner)
    return print(io, ")")
end

function show(io::IO, m::Maximum)
    print(io, "max(")
    for (i, term) in enumerate(m.terms)
        show(io, term)
        if i < length(m.terms)
            print(io, ", ")
        end
    end
    return print(io, ")")
end

function show(io::IO, m::Minimum)
    print(io, "min(")
    for (i, term) in enumerate(m.terms)
        show(io, term)
        if i < length(m.terms)
            print(io, ", ")
        end
    end
    return print(io, ")")
end

function show(io::IO, l::Literal)
    return print(io, l.value)
end

function show(io::IO, f::FunctionType)
    return print(io, f.name, ": ", f.domain, " → ", f.codomain)
end

==(a::Literal, b::Literal) = a.value == b.value && a.space == b.space
==(a::Variable, b::Variable) = a.name == b.name && a.space == b.space

function ==(a::FunctionCall, b::FunctionCall)
    return a.name == b.name &&
           a.space == b.space &&
           length(a.args) == length(b.args) &&
           all(==(x, y) for (x, y) in zip(a.args, b.args))
end

function ==(a::Addition, b::Addition)
    return a.space == b.space &&
           length(a.terms) == length(b.terms) &&
           all(==(x, y) for (x, y) in zip(a.terms, b.terms))
end

function ==(a::Subtraction, b::Subtraction)
    return a.space == b.space &&
           length(a.terms) == length(b.terms) &&
           all(==(x, y) for (x, y) in zip(a.terms, b.terms))
end

function ==(a::Composition, b::Composition)
    return a.space == b.space && a.outer == b.outer && a.inner == b.inner
end

function ==(a::Maximum, b::Maximum)
    return a.space == b.space &&
           length(a.terms) == length(b.terms) &&
           all(==(x, y) for (x, y) in zip(a.terms, b.terms))
end

function ==(a::Minimum, b::Minimum)
    return a.space == b.space &&
           length(a.terms) == length(b.terms) &&
           all(==(x, y) for (x, y) in zip(a.terms, b.terms))
end

# fallback
==(a::Expression, b::Expression) = false

function hash(l::Literal, h::UInt)
    return hash((l.value, l.space), h)
end
function hash(v::Variable, h::UInt)
    return hash((v.name, v.space), h)
end
function hash(fc::FunctionCall, h::UInt)
    return hash((fc.name, fc.space, fc.args), h)
end
function hash(ad::Addition, h::UInt)
    return hash((:Addition, ad.space, ad.terms), h)
end
function hash(sb::Subtraction, h::UInt)
    return hash((:Subtraction, sb.space, sb.terms), h)
end
function hash(co::Composition, h::UInt)
    return hash((:Composition, co.space, co.outer, co.inner), h)
end
function hash(mx::Maximum, h::UInt)
    return hash((:Maximum, mx.space, mx.terms), h)
end
function hash(mn::Minimum, h::UInt)
    return hash((:Minimum, mn.space, mn.terms), h)
end

# # Function call on a Composition node: (f ∘ g)(x) → f(g(x))
# function (c::Composition)(args::Expression...)
#     # first apply inner to args, then feed result to outer
#     inner_app = c.inner(args...)
#     return c.outer(inner_app)
# end
