# === CONVEX === #

function combine_properties_addition(p1::Convex, p2::Convex)
    return Convex()
end

function combine_properties_addition(p1::Convex, p2::StronglyConvex)
    return p2
end

function combine_properties_addition(p1::StronglyConvex, p2::Convex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::Convex, p2::HypoConvex)
    return p2
end

function combine_properties_addition(p1::HypoConvex, p2::Convex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::Convex, p2::Smooth)
    if p2.L === nothing
        return HypoConvex()
    else
        return HypoConvex(p2.L)
    end
end

function combine_properties_addition(p1::Smooth, p2::Convex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::Convex, p2::Lipschitz)
    return nothing
end

function combine_properties_addition(p1::Lipschitz, p2::Convex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::Convex, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::Convex)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Convex, p2::Quadratic)
    if p2.λₘᵢₙ === nothing
        return nothing
    else
        min_val = p2.λₘᵢₙ.lower
        if min_val < 0
            return HypoConvex(abs(Interval(min_val, min_val)))
        elseif min_val == 0
            return Convex()
        else
            return StronglyConvex(Interval(min_val, min_val))
        end
    end
end

function combine_properties_addition(p1::Quadratic, p2::Convex)
    return combine_properties_addition(p2, p1)
end

# === STRONGLY CONVEX === #
function combine_properties_addition(p1::StronglyConvex, p2::StronglyConvex)
    if p1.μ === nothing && p2.μ === nothing
        return StronglyConvex()
    elseif p1.μ === nothing
        return p2
    elseif p2.μ === nothing
        return p1
    end

    # Both have values, add the intervals
    lower = p1.μ.lower + p2.μ.lower
    upper = p1.μ.upper + p2.μ.upper

    return StronglyConvex(Interval(lower, upper))
end

function combine_properties_addition(p1::StronglyConvex, p2::HypoConvex)
    if p1.μ === nothing || p2.ρ === nothing
        return nothing
    end

    diff = p1.μ - p2.ρ
    if diff.lower > 0
        return StronglyConvex(diff)
    elseif diff.lower == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end
function combine_properties_addition(p1::HypoConvex, p2::StronglyConvex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::StronglyConvex, p2::Smooth)
    if p1.μ === nothing || p2.L === nothing
        return nothing
    end

    diff = p1.μ - p2.L
    if diff.lower > 0
        return StronglyConvex(diff)
    elseif diff.lower == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end

function combine_properties_addition(p1::Smooth, p2::StronglyConvex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::StronglyConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_addition(p1::Lipschitz, p2::StronglyConvex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::StronglyConvex, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::StronglyConvex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::StronglyConvex, p2::Quadratic)
    if p1.μ === nothing || p2.λₘᵢₙ === nothing
        return nothing
    end
    result = p1.μ + p2.λₘᵢₙ

    if result.lower > 0
        return StronglyConvex(result)
    elseif result.lower == 0
        return Convex()
    else
        return HypoConvex(abs(result))
    end
end

function combine_properties_addition(p1::Quadratic, p2::StronglyConvex)
    return combine_properties_addition(p2, p1)
end

# === HypoConvex === #

function combine_properties_addition(p1::HypoConvex, p2::HypoConvex)
    if p1.ρ === nothing && p2.ρ === nothing
        return HypoConvex()
    elseif p1.ρ === nothing
        return p2
    elseif p2.ρ === nothing
        return p1
    end
    return HypoConvex(p1.ρ + p2.ρ)
end

function combine_properties_addition(p1::HypoConvex, p2::Smooth)
    if p1.ρ === nothing || p2.L === nothing
        return HypoConvex()
    end

    return HypoConvex(p1.ρ + p2.L)
end

function combine_properties_addition(p1::Smooth, p2::HypoConvex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::HypoConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_addition(p1::Lipschitz, p2::HypoConvex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::HypoConvex, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::HypoConvex)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::HypoConvex, p2::Quadratic)
    if p2.λₘᵢₙ === nothing
        return nothing
    elseif p2.λₘᵢₙ.lower > 0
        return combine_properties_addition(p1, StronglyConvex(p2.λₘᵢₙ))
    elseif p2.λₘᵢₙ.lower == 0 && p2.λₘᵢₙ.upper == 0
        return combine_properties_addition(p1, Convex())
    else
        return combine_properties_addition(p1, HypoConvex(abs(p2.λₘᵢₙ)))
    end
end

function combine_properties_addition(p1::Quadratic, p2::HypoConvex)
    return combine_properties_addition(p2, p1)
end

# === SMOOTH === #
function combine_properties_addition(p1::Smooth, p2::Smooth)
    if p1.L === nothing && p2.L === nothing
        return Smooth()
    elseif p1.L === nothing
        return p2
    elseif p2.L === nothing
        return p1
    end
    return Smooth(p1.L + p2.L)
end

function combine_properties_addition(p1::Smooth, p2::Lipschitz)
    return nothing
end

function combine_properties_addition(p1::Lipschitz, p2::Smooth)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::Smooth, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::Smooth)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::Smooth, p2::Quadratic)
    if p1.L === nothing || p2.λₘₐₓ === nothing
        return nothing
    end
    abs_λₘₐₓ = abs(p2.λₘₐₓ)
    result = p1.L + abs_λₘₐₓ # FIXME
    return Smooth(result)
end

function combine_properties_addition(p1::Quadratic, p2::Smooth)
    return combine_properties_addition(p2, p1)
end

# === LIPSCHITZ === #

function combine_properties_addition(p1::Lipschitz, p2::Lipschitz)
    if p1.M === nothing && p2.M === nothing
        return Lipschitz()
    elseif p1.M === nothing
        return p2
    elseif p2.M === nothing
        return p1
    end
    return Lipschitz(p1.M + p2.M)
end

function combine_properties_addition(p1::Lipschitz, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Linear, p2::Lipschitz)
    return combine_properties_addition(p2, p1)
end

function combine_properties_addition(p1::Lipschitz, p2::Quadratic)
    return nothing
end

function combine_properties_addition(p1::Quadratic, p2::Lipschitz)
    return combine_properties_addition(p2, p1)
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
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_addition(p1::Quadratic, p2::Linear)
    return combine_properties_addition(p2, p1)
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
