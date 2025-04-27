import Base: abs, -, +

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
    StronglyConvex(μ::Union{Nothing} = nothing) = new(nothing)
    StronglyConvex(μ::Float64) = new(Interval(μ, μ))
    StronglyConvex(μ::Interval) = new(μ)
end

struct HypoConvex <: Property
    ρ::Union{Interval,Nothing} # can be unspecified
    HypoConvex(ρ::Union{Nothing} = nothing) = new(nothing)
    HypoConvex(ρ::Float64) = new(Interval(ρ, ρ))
    HypoConvex(ρ::Interval) = new(ρ)
end

struct Smooth <: Property
    L::Union{Interval,Nothing} # can be unspecified
    Smooth(L::Union{Nothing} = nothing) = new(nothing)
    Smooth(L::Float64) = new(Interval(L, L))
    Smooth(L::Interval) = new(L)
end

struct Lipschitz <: Property
    M::Union{Interval,Nothing} # can be unspecified
    Lipschitz(M::Union{Nothing} = nothing) = new(nothing)
    Lipschitz(M::Float64) = new(Interval(M, M))
    Lipschitz(M::Interval) = new(M)
end


struct Linear <: Property
    λₘᵢₙ::Union{Interval,Nothing} # can be unspecified
    λₘₐₓ::Union{Interval,Nothing} # can be unspecified

    # Constructor for proper intervals
    Linear(
        λₘᵢₙ::Union{Interval,Float64,Nothing} = nothing,
        λₘₐₓ::Union{Interval,Float64,Nothing} = nothing,
    ) = new(
        isa(λₘᵢₙ, Float64) ? Interval(λₘᵢₙ) : λₘᵢₙ,
        isa(λₘₐₓ, Float64) ? Interval(λₘₐₓ) : λₘₐₓ,
    )
end

struct Quadratic <: Property
    λₘᵢₙ::Union{Interval,Nothing} # can be unspecified
    λₘₐₓ::Union{Interval,Nothing} # can be unspecified

    # Constructor for proper intervals
    Quadratic(
        λₘᵢₙ::Union{Interval,Float64,Nothing} = nothing,
        λₘₐₓ::Union{Interval,Float64,Nothing} = nothing,
    ) = new(
        isa(λₘᵢₙ, Float64) ? Interval(λₘᵢₙ) : λₘᵢₙ,
        isa(λₘₐₓ, Float64) ? Interval(λₘₐₓ) : λₘₐₓ,
    )
end
