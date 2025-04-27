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

## Curvature

struct Convex <: Property end

struct MonotonicallyIncreasing <: Property end

struct StronglyConvex <: Property
    μ::Union{Float64,Nothing} # can be unspecified
    StronglyConvex(μ::Union{Float64,Nothing} = nothing) = new(μ)
end

struct HypoConvex <: Property
    ρ::Union{Float64,Nothing} # can be unspecified
    HypoConvex(ρ::Union{Float64,Nothing} = nothing) = new(ρ)
end

struct Smooth <: Property
    L::Union{Float64,Nothing} # can be unspecified
    Smooth(L::Union{Float64,Nothing} = nothing) = new(L)
end

struct Lipschitz <: Property
    M::Union{Float64,Nothing} # can be unspecified
    Lipschitz(M::Union{Float64,Nothing} = nothing) = new(M)
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
