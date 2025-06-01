import Base: abs, -, +, ==, hash

abstract type Property end

## Interval type (especially for eigenvalues)
struct Interval
    lower::Float64
    upper::Float64

    # Constructor for proper intervals
    Interval(lower::Float64, upper::Float64) = new(lower, upper)

    # Constructor for degenerate intervals
    Interval(value::Float64) = new(value, value)
end

""" abs(i::Interval) -> Interval
    Returns the absolute value of an interval.
"""
function abs(i::Interval) # TODO : check if this is the correct way.
    if i.lower <= 0 && i.upper >= 0
        lower = 0.0
        upper = max(abs(i.lower), abs(i.upper))
    else
        lower = min(abs(i.lower), abs(i.upper))
        upper = max(abs(i.lower), abs(i.upper))
    end
    return Interval(lower, upper)
end

"""
    -(a::Interval, b::Interval)

Subtract two intervals.
For intervals [a,b] and [c,d], the result is [a-d, b-c].
"""
function -(a::Interval, b::Interval)
    return Interval(a.lower - b.upper, a.upper - b.lower)
end

"""
    +(a::Interval, b::Interval)

Add two intervals.
For intervals [a,b] and [c,d], the result is [a+c, b+d].
"""
function +(a::Interval, b::Interval)
    return Interval(a.lower + b.lower, a.upper + b.upper)
end

## Curvature

struct Convex <: Property end

struct MonotonicallyIncreasing <: Property end

struct StronglyConvex <: Property
    μ::Union{Interval,Nothing} # can be unspecified
    StronglyConvex(μ::Union{Nothing}=nothing) = new(nothing)
    StronglyConvex(μ::Float64) = new(Interval(μ, μ))
    StronglyConvex(μ::Interval) = new(μ)
end

struct HypoConvex <: Property
    ρ::Union{Interval,Nothing} # can be unspecified
    HypoConvex(ρ::Union{Nothing}=nothing) = new(nothing)
    HypoConvex(ρ::Float64) = new(Interval(ρ, ρ))
    HypoConvex(ρ::Interval) = new(ρ)
end

struct Smooth <: Property
    L::Union{Interval,Nothing} # can be unspecified
    Smooth(L::Union{Nothing}=nothing) = new(nothing)
    Smooth(L::Float64) = new(Interval(L, L))
    Smooth(L::Interval) = new(L)
end

struct Lipschitz <: Property
    M::Union{Interval,Nothing} # can be unspecified
    Lipschitz(M::Union{Nothing}=nothing) = new(nothing)
    Lipschitz(M::Float64) = new(Interval(M, M))
    Lipschitz(M::Interval) = new(M)
end

struct Linear <: Property
    λₘᵢₙ::Union{Interval,Nothing} # can be unspecified
    λₘₐₓ::Union{Interval,Nothing} # can be unspecified

    # Constructor for proper intervals
    function Linear(
        λₘᵢₙ::Union{Interval,Float64,Nothing}=nothing,
        λₘₐₓ::Union{Interval,Float64,Nothing}=nothing,
    )
        return new(
            isa(λₘᵢₙ, Float64) ? Interval(λₘᵢₙ) : λₘᵢₙ,
            isa(λₘₐₓ, Float64) ? Interval(λₘₐₓ) : λₘₐₓ,
        )
    end
end

struct Quadratic <: Property
    λₘᵢₙ::Union{Interval,Nothing} # can be unspecified
    λₘₐₓ::Union{Interval,Nothing} # can be unspecified

    # Constructor for proper intervals
    function Quadratic(
        λₘᵢₙ::Union{Interval,Float64,Nothing}=nothing,
        λₘₐₓ::Union{Interval,Float64,Nothing}=nothing,
    )
        return new(
            isa(λₘᵢₙ, Float64) ? Interval(λₘᵢₙ) : λₘᵢₙ,
            isa(λₘₐₓ, Float64) ? Interval(λₘₐₓ) : λₘₐₓ,
        )
    end
end

# Define equality for Convex: all Convex instances are equivalent
==(p1::Convex, p2::Convex) = true
hash(p::Convex, h::UInt) = hash(:Convex, h)

# For MonotonicallyIncreasing, assume all instances are equivalent:
==(p1::MonotonicallyIncreasing, p2::MonotonicallyIncreasing) = true
hash(p::MonotonicallyIncreasing, h::UInt) = hash(:MonotonicallyIncreasing, h)

# For parameterized types like StronglyConvex, compare their μ fields
==(p1::StronglyConvex, p2::StronglyConvex) = p1.μ == p2.μ
hash(p::StronglyConvex, h::UInt) = hash(p.μ, h)

==(p1::HypoConvex, p2::HypoConvex) = p1.ρ == p2.ρ
hash(p::HypoConvex, h::UInt) = hash(p.ρ, h)

==(p1::Smooth, p2::Smooth) = p1.L == p2.L
hash(p::Smooth, h::UInt) = hash(p.L, h)

==(p1::Lipschitz, p2::Lipschitz) = p1.M == p2.M
hash(p::Lipschitz, h::UInt) = hash(p.M, h)

# For Linear and Quadratic, you can compare each field:
==(p1::Linear, p2::Linear) = p1.λₘᵢₙ == p2.λₘᵢₙ && p1.λₘₐₓ == p2.λₘₐₓ
hash(p::Linear, h::UInt) = hash((p.λₘᵢₙ, p.λₘₐₓ), h)

==(p1::Quadratic, p2::Quadratic) = p1.λₘᵢₙ == p2.λₘᵢₙ && p1.λₘₐₓ == p2.λₘₐₓ
hash(p::Quadratic, h::UInt) = hash((p.λₘᵢₙ, p.λₘₐₓ), h)

==(i1::Interval, i2::Interval) = i1.lower == i2.lower && i1.upper == i2.upper
hash(i::Interval, h::UInt) = hash((i.lower, i.upper), h)
