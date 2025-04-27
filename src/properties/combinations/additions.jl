# === CONVEX === #

function combine_properties_addition(p1::Convex, p2::Convex)
    return Convex()
end

function combine_properties_addition(p1::Convex, p2::StronglyConvex)
    return p2
end

function combine_properties_addition(p1::StronglyConvex, p2::Convex)
    return p1
end

function combine_properties_addition(p1::Convex, p2::HypoConvex)
    return p2
end

function combine_properties_addition(p1::HypoConvex, p2::Convex)
    return p1
end

function combine_properties_addition(p1::Convex, p2::Smooth)
    return HypoConvex(p2.L)
end

function combine_properties_addition(p1::Smooth, p2::Convex)
    return HypoConvex(p1.L)
end

function combine_properties_addition(p1::Convex, p2::Lipschitz)
    return nothing
end

function combine_properties_addition(p1::Lipschitz, p2::Convex)
    return nothing
end

function combine_properties_addition(p1::Convex, p2::Linear)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::Convex)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Convex, p2::Quadratic)
    if p2.λₘᵢₙ === nothing
        return nothing
    elseif p2.λₘᵢₙ < 0
        return HypoConvex(abs(p2.λₘᵢₙ))
    elseif p2.λₘᵢₙ == 0
        return Convex()
    else
        return StronglyConvex(p2.λₘᵢₙ)
    end
end

function combine_properties_addition(p1::Quadratic, p2::Convex)
    if p1.λₘᵢₙ === nothing
        return nothing
    elseif p1.λₘᵢₙ < 0
        return HypoConvex(abs(p2.λₘᵢₙ))
    elseif p1.λₘᵢₙ == 0
        return Convex()
    else
        return StronglyConvex(p2.λₘᵢₙ)
    end
end

# === STRONGLY CONVEX === #
function combine_properties_addition(p1::StronglyConvex, p2::StronglyConvex)
    μ1 = p1.μ === nothing ? 0.0 : p1.μ
    μ2 = p2.μ === nothing ? 0.0 : p2.μ
    return StronglyConvex(μ1 + μ2)
end

function combine_properties_addition(p1::StronglyConvex, p2::HypoConvex)
    μ = p1.μ === nothing ? 0.0 : p1.μ
    ρ = p2.ρ === nothing ? 0.0 : p2.ρ
    diff = μ - ρ
    if diff > 0
        return StronglyConvex(diff)
    elseif diff == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end
function combine_properties_addition(p1::HypoConvex, p2::StronglyConvex)
    μ = p2.μ === nothing ? 0.0 : p2.μ
    ρ = p1.ρ === nothing ? 0.0 : p1.ρ
    diff = μ - ρ
    if diff > 0
        return StronglyConvex(diff)
    elseif diff == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end

function combine_properties_addition(p1::StronglyConvex, p2::Smooth)
    μ = p1.μ === nothing ? 0.0 : p1.μ
    L = p2.L === nothing ? 0.0 : p2.L
    diff = μ - L
    if diff > 0
        return StronglyConvex(diff)
    elseif diff == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end

function combine_properties_addition(p1::Smooth, p2::StronglyConvex)
    μ = p2.μ === nothing ? 0.0 : p2.μ
    L = p1.L === nothing ? 0.0 : p1.L
    diff = μ - L
    if diff > 0
        return StronglyConvex(diff)
    elseif diff == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end

function combine_properties_addition(p1::StronglyConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_addition(p1::Lipschitz, p2::StronglyConvex)
    return nothing
end

function combine_properties_addition(p1::StronglyConvex, p2::Linear)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::StronglyConvex)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::StronglyConvex, p2::Quadratic)
    μ = p1.μ === nothing ? 0.0 : p1.μ
    λₘᵢₙ = p2.λₘᵢₙ === nothing ? 0.0 : p2.λₘᵢₙ
    diff = μ - λₘᵢₙ
    if diff > 0
        return StronglyConvex(diff)
    elseif diff == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end

function combine_properties_addition(p1::Quadratic, p2::StronglyConvex)
    μ = p2.μ === nothing ? 0.0 : p2.μ
    λₘᵢₙ = p1.λₘᵢₙ === nothing ? 0.0 : p1.λₘᵢₙ
    diff = μ - λₘᵢₙ
    if diff > 0
        return StronglyConvex(diff)
    elseif diff == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end

# === HypoConvex === #

function combine_properties_addition(p1::HypoConvex, p2::HypoConvex)
    ρ1 = p1.ρ === nothing ? 0.0 : p1.ρ
    ρ2 = p2.ρ === nothing ? 0.0 : p2.ρ
    return HypoConvex(ρ1 + ρ2)
end

function combine_properties_addition(p1::HypoConvex, p2::Smooth)
    ρ = p1.ρ === nothing ? 0.0 : p1.ρ
    L = p2.L === nothing ? 0.0 : p2.L
    return HypoConvex(ρ + L)
end

function combine_properties_addition(p1::Smooth, p2::HypoConvex)
    ρ = p2.ρ === nothing ? 0.0 : p2.ρ
    L = p1.L === nothing ? 0.0 : p1.L
    return HypoConvex(ρ + L)
end

function combine_properties_addition(p1::HypoConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_addition(p1::Lipschitz, p2::HypoConvex)
    return nothing
end

function combine_properties_addition(p1::HypoConvex, p2::Linear)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::HypoConvex)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::HypoConvex, p2::Quadratic)
    if p2.λₘᵢₙ === nothing
        return nothing
    elseif p2.λₘᵢₙ > 0
        return combine_properties_addition(p1, StronglyConvex(p2.λₘᵢₙ))
    elseif p2.λₘᵢₙ == 0
        return combine_properties_addition(p1, Convex())
    else
        return combine_properties_addition(p1, HypoConvex(abs(p2.λₘᵢₙ)))
    end
end

function combine_properties_addition(p1::Quadratic, p2::HypoConvex)
    if p1.λₘᵢₙ === nothing
        return nothing
    elseif p1.λₘᵢₙ > 0
        return combine_properties_addition(StronglyConvex(p1.λₘᵢₙ), p2)
    elseif p1.λₘᵢₙ == 0
        return combine_properties_addition(Convex(), p2)
    else
        return combine_properties_addition(HypoConvex(abs(p1.λₘᵢₙ)), p2)
    end
end

# === SMOOTH === #
function combine_properties_addition(p1::Smooth, p2::Smooth)
    L1 = p1.L === nothing ? 0.0 : p1.L
    L2 = p2.L === nothing ? 0.0 : p2.L
    return Smooth(L1 + L2)
end

function combine_properties_addition(p1::Smooth, p2::Lipschitz)
    return nothing
end

function combine_properties_addition(p1::Lipschitz, p2::Smooth)
    return nothing
end

function combine_properties_addition(p1::Smooth, p2::Linear)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::Smooth)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Smooth, p2::Quadratic)
    L = p1.L === nothing ? 0.0 : p1.L

    if p2.λₘₐₓ === nothing
        return nothing
    else
        return Smooth(L + 2 * abs(p2.λₘₐₓ))
    end
end

function combine_properties_addition(p1::Quadratic, p2::Smooth)
    L = p2.L === nothing ? 0.0 : p2.L

    if p1.λₘₐₓ === nothing
        return nothing
    else
        return Smooth(L + 2 * abs(p1.λₘₐₓ))
    end
end

# === LIPSCHITZ === #

function combine_properties_addition(p1::Lipschitz, p2::Lipschitz)
    M1 = p1.M === nothing ? 0.0 : p1.M
    M2 = p2.M === nothing ? 0.0 : p2.M
    return Lipschitz(M1 + M2)
end

function combine_properties_addition(p1::Lipschitz, p2::Linear)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::Lipschitz)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Lipschitz, p2::Quadratic)
    return nothing
end

function combine_properties_addition(p1::Quadratic, p2::Lipschitz)
    return nothing
end

# === LINEAR === #
function combine_properties_addition(p1::Linear, p2::Linear)
    λₘᵢₙ = nothing
    λₘₐₓ = nothing
    if p1.λₘᵢₙ !== nothing && p2.λₘᵢₙ !== nothing && p2.λₘₐₓ !== nothing
        min_lower = p1.λₘᵢₙ.lower + p2.λₘᵢₙ.lower
        min_upper = p1.λₘᵢₙ.upper + p2.λₘₐₓ.upper
        λₘᵢₙ = Interval(min_lower, min_upper)
    end

    if p1.λₘₐₓ !== nothing && p2.λₘᵢₙ !== nothing && p2.λₘₐₓ !== nothing
        max_lower = p1.λₘₐₓ.lower + p2.λₘᵢₙ.lower
        max_upper = p1.λₘₐₓ.upper + p2.λₘₐₓ.upper
        λₘₐₓ = Interval(max_lower, max_upper)
    end
    return Linear(λₘᵢₙ, λₘₐₓ)
end

function combine_properties_addition(p1::Linear, p2::Quadratic)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Quadratic, p2::Linear)
    error("Dimension mismatch. Operation not supposed to be performed.")
end

# === QUADRATIC === #
function combine_properties_addition(p1::Quadratic, p2::Quadratic)
    λₘᵢₙ = nothing
    λₘₐₓ = nothing

    if p1.λₘᵢₙ !== nothing && p2.λₘᵢₙ !== nothing && p2.λₘₐₓ !== nothing
        min_lower = p1.λₘᵢₙ.lower + p2.λₘᵢₙ.lower
        min_upper = p1.λₘᵢₙ.upper + p2.λₘₐₓ.upper
        λₘᵢₙ = Interval(min_lower, min_upper)
    end

    if p1.λₘₐₓ !== nothing && p2.λₘᵢₙ !== nothing && p2.λₘₐₓ !== nothing
        max_lower = p1.λₘₐₓ.lower + p2.λₘᵢₙ.lower
        max_upper = p1.λₘₐₓ.upper + p2.λₘₐₓ.upper
        λₘₐₓ = Interval(max_lower, max_upper)
    end
    return Quadratic(λₘᵢₙ, λₘₐₓ)
end
