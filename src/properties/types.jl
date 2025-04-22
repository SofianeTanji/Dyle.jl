abstract type Property end

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
    λₘᵢₙ::Union{Float64,Nothing} # can be unspecified
    λₘₐₓ::Union{Float64,Nothing} # can be unspecified
    Linear(λₘᵢₙ::Union{Float64,Nothing} = nothing, λₘₐₓ::Union{Float64,Nothing} = nothing) =
        new(λₘᵢₙ, λₘₐₓ)
end

struct Quadratic <: Property
    λₘᵢₙ::Union{Float64,Nothing} # can be unspecified
    λₘₐₓ::Union{Float64,Nothing} # can be unspecified
    Quadratic(
        λₘᵢₙ::Union{Float64,Nothing} = nothing,
        λₘₐₓ::Union{Float64,Nothing} = nothing,
    ) = new(λₘᵢₙ, λₘₐₓ)
end
