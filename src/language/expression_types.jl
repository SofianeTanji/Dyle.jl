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
        new(name, space)
    end
end

"""FunctionType
A type representing a function's type signature.

Fields:
- `name::Symbol`: The name of the function.
- `domain::Space`: The domain space of the function.
- `codomain::Space`: The codomain space of the function.
"""
struct FunctionType
    name::Symbol
    domain::Space
    codomain::Space

    function FunctionType(name::Symbol, domain::Space, codomain::Space)
        new(name, domain, codomain)
    end
end

"""FunctionCall <: Expression
A type representing a function call in an expression.

Fields:
- `name::Symbol`: The name of the function being called.
- `args::Vector{Expression}`: The arguments to the function call.
- `space::Space`: The space of the result (the codomain of the function).
"""
struct FunctionCall <: Expression
    name::Symbol
    args::Vector{Expression}
    space::Space

    function FunctionCall(name::Symbol, args::Vector{Expression}, space::Space)
        new(name, args, space)
    end

    # Constructor for when we have a FunctionType and arguments
    function FunctionCall(func::FunctionType, args::Vector{Expression})
        if isempty(args)
            # Function with no arguments - allowed in our system
            return new(func.name, args, func.codomain)
        end

        # Check that the first argument's space matches the function's domain
        arg_space = args[1].space
        if arg_space != func.domain
            error(
                "Type mismatch: function $(func.name) expects argument in $(func.domain) but got $(arg_space)",
            )
        end

        new(func.name, args, func.codomain)
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

        new(terms, space)
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

        new(terms, space)
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
        new(outer, inner, space)
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

        new(terms, space)
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

        new(terms, space)
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
            "Cannot subtract expressions from different spaces: $(a.space) and $(b.space)",
        )
    end
    return Subtraction(Expression[a, b], a.space)
end

function ∘(f::Expression, g::Expression)
    # For function composition, we need more information to properly check
    # This is a complex case that requires looking at the domain/codomain of functions
    # For now, we'll use the outer expression's space for the result
    # But we cannot verify domain/codomain compatibility at this point
    error(
        "Composition requires explicit space information and type checking. Use the parser or constructors directly.",
    )
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

# Function call operators - these are complex and require careful type checking

function (f::FunctionType)(args::Expression...)
    # Convert to vector for consistency, ensuring we get a Vector{Expression}
    args_vec = Expression[arg for arg in args]

    if isempty(args_vec)
        # No arguments, return a function call in the codomain
        return FunctionCall(f.name, args_vec, f.codomain)
    end

    # Check that the first argument's space matches the function's domain
    arg_space = args_vec[1].space
    if arg_space != f.domain
        error(
            "Type mismatch: function $(f.name) expects argument in $(f.domain) but got $(arg_space)",
        )
    end

    return FunctionCall(f.name, args_vec, f.codomain)
end

# We don't support directly calling a symbol as a function anymore
# This should be handled by the parser or by the @func macro
function (f::Symbol)(args::Expression...)
    error("Cannot call symbol $(f) as a function. Please declare it with @func first.")
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

function show(io::IO, l::Literal)
    print(io, l.value)
end

function show(io::IO, f::FunctionType)
    print(io, f.name, ": ", f.domain, " → ", f.codomain)
end
