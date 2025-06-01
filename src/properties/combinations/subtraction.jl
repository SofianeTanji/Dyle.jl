# === CONVEX === #

function combine_properties_subtraction(p1::Convex, p2::Convex)
    return nothing
end

function combine_properties_subtraction(p1::Convex, p2::StronglyConvex)
    return nothing
end

function combine_properties_subtraction(p1::StronglyConvex, p2::Convex)
    return nothing
end

function combine_properties_subtraction(p1::Convex, p2::HypoConvex)
    return nothing
end

function combine_properties_subtraction(p1::HypoConvex, p2::Convex)
    return nothing
end

function combine_properties_subtraction(p1::Convex, p2::Smooth)
    return nothing
end

function combine_properties_subtraction(p1::Smooth, p2::Convex)
    return nothing
end

function combine_properties_subtraction(p1::Convex, p2::Lipschitz)
    return nothing
end

function combine_properties_subtraction(p1::Lipschitz, p2::Convex)
    return nothing
end

function combine_properties_subtraction(p1::Convex, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Linear, p2::Convex)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Convex, p2::Quadratic)
    return nothing
end

function combine_properties_subtraction(p1::Quadratic, p2::Convex)
    return nothing
end

# === STRONGLY CONVEX === #
function combine_properties_subtraction(p1::StronglyConvex, p2::StronglyConvex)
    return nothing
end

function combine_properties_subtraction(p1::StronglyConvex, p2::HypoConvex)
    return nothing
end

function combine_properties_subtraction(p1::HypoConvex, p2::StronglyConvex)
    return nothing
end

function combine_properties_subtraction(p1::StronglyConvex, p2::Smooth)
    if p1.μ === nothing || p2.L === nothing
        return nothing
    end

    diff = p1.μ - p2.L

    if diff.lower > 0
        return StronglyConvex(diff)
    elseif diff.lower == 0 && diff.upper == 0
        return Convex()
    else
        return HypoConvex(abs(diff))
    end
end

function combine_properties_subtraction(p1::Smooth, p2::StronglyConvex)
    if p1.L === nothing || p2.μ === nothing
        return nothing
    end

    if p1.L.lower >= p2.μ.upper
        return Smooth(p1.L - p2.μ)
    else
        return nothing
    end
end

function combine_properties_subtraction(p1::StronglyConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_subtraction(p1::Lipschitz, p2::StronglyConvex)
    return nothing
end

function combine_properties_subtraction(p1::StronglyConvex, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Linear, p2::StronglyConvex)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::StronglyConvex, p2::Quadratic)
    if p2.λₘₐₓ === nothing
        return nothing
    else
        return combine_properties_subtraction(p1::StronglyConvex, Smooth(p2.λₘₐₓ))
    end
end

function combine_properties_subtraction(p1::Quadratic, p2::StronglyConvex)
    if p1.λₘₐₓ === nothing
        return nothing
    else
        return combine_properties_subtraction(Smooth(p1.λₘₐₓ), p1::StronglyConvex)
    end
end

# === HypoConvex === #

function combine_properties_subtraction(p1::HypoConvex, p2::HypoConvex)
    return nothing
end

function combine_properties_subtraction(p1::HypoConvex, p2::Smooth)
    if p1.ρ === nothing || p2.L === nothing
        return nothing
    end
    if p1.ρ.lower >= p2.L.upper
        return HypoConvex(p1.ρ - p2.L)
    else
        return nothing
    end
end

function combine_properties_subtraction(p1::Smooth, p2::HypoConvex)
    result = Set{Property}()
    push!(result, combine_properties_subtraction(HypoConvex(p1), p2))
    push!(result, HypoConvex(p1.L + p2.ρ))
    return result
end

function combine_properties_subtraction(p1::HypoConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_subtraction(p1::Lipschitz, p2::HypoConvex)
    return nothing
end

function combine_properties_subtraction(p1::HypoConvex, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Linear, p2::HypoConvex)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::HypoConvex, p2::Quadratic)
    result = Set{Property}()
    if p2.λₘₐₓ !== nothing
        combined = combine_properties_subtraction(p1, Smooth(p2.λₘₐₓ))
        if combined !== nothing
            push!(result, combined)
        end
    end

    if p2.λₘᵢₙ !== nothing
        if p2.λₘᵢₙ.lower > 0
            combined = combine_properties_subtraction(p1, StronglyConvex(p2.λₘᵢₙ))
            if combined !== nothing
                push!(result, combined)
            end
        elseif p2.λₘᵢₙ.lower == 0 && p2.λₘᵢₙ.upper == 0
            combined = combine_properties_subtraction(p1, Convex())
            if combined !== nothing
                push!(result, combined)
            end
        else
            combined = combine_properties_subtraction(p1, HypoConvex(abs(p2.λₘᵢₙ)))
            if combined !== nothing
                push!(result, combined)
            end
        end
    end
    return isempty(result) ? nothing : result
end

function combine_properties_subtraction(p1::Quadratic, p2::HypoConvex)
    result = Set{Property}()
    if p1.λₘₐₓ !== nothing
        combined = combine_properties_subtraction(Smooth(p1.λₘₐₓ), p2)
        if combined !== nothing
            push!(result, combined)
        end
    end

    if p1.λₘᵢₙ !== nothing
        if p1.λₘᵢₙ.lower > 0
            combined = combine_properties_subtraction(StronglyConvex(p1.λₘᵢₙ), p2)
            if combined !== nothing
                push!(result, combined)
            end
        elseif p1.λₘᵢₙ.lower == 0 && p1.λₘᵢₙ.upper == 0
            combined = combine_properties_subtraction(Convex(), p2)
            if combined !== nothing
                push!(result, combined)
            end
        else
            combined = combine_properties_subtraction(HypoConvex(abs(p1.λₘᵢₙ)), p2)
            if combined !== nothing
                push!(result, combined)
            end
        end
    end

    return isempty(result) ? nothing : result
end

# === SMOOTH === #
function combine_properties_subtraction(p1::Smooth, p2::Smooth)
    if p1.L === nothing && p2.L === nothing
        return Smooth()
    elseif p1.L === nothing # FIXME: i think it is not correct
        return p2
    elseif p2.L === nothing
        return p1
    end
    return Smooth(p1.L + p2.L)
end

function combine_properties_subtraction(p1::Smooth, p2::Lipschitz)
    return nothing
end

function combine_properties_subtraction(p1::Lipschitz, p2::Smooth)
    return nothing
end

function combine_properties_subtraction(p1::Smooth, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Linear, p2::Smooth)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Smooth, p2::Quadratic)
    if p1.L === nothing || p2.λₘₐₓ === nothing
        return nothing
    end
    return Smooth(p1.L + p2.λₘₐₓ)
end

function combine_properties_subtraction(p1::Quadratic, p2::Smooth)
    if p1.λₘₐₓ === nothing || p2.L === nothing
        return nothing
    end
    return Smooth(p1.λₘₐₓ + p2.L)
end

# === LIPSCHITZ === #

function combine_properties_subtraction(p1::Lipschitz, p2::Lipschitz)
    if p1.M === nothing && p2.M === nothing
        return Lipschitz()
    elseif p1.M === nothing
        return p2
    elseif p2.M === nothing
        return p1
    end
    return Lipschitz(p1.M + p2.M)
end

function combine_properties_subtraction(p1::Lipschitz, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Linear, p2::Lipschitz)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Lipschitz, p2::Quadratic)
    return nothing
end

function combine_properties_subtraction(p1::Quadratic, p2::Lipschitz)
    return nothing
end

# === LINEAR === #
function combine_properties_subtraction(p1::Linear, p2::Linear)
    # TODO : [lambda_min(A) - lambda_max(B); lambda_max(A) - lambda_min(B)]
    λₘᵢₙ = nothing
    λₘₐₓ = nothing
    if p1.λₘᵢₙ !== nothing && p2.λₘₐₓ !== nothing
        λₘᵢₙ = Interval(p1.λₘᵢₙ.lower - p2.λₘₐₓ.upper, p1.λₘᵢₙ.lower - p2.λₘₐₓ.upper)
    end

    if p1.λₘₐₓ !== nothing && p2.λₘᵢₙ !== nothing
        λₘₐₓ = Interval(p1.λₘₐₓ.upper - p2.λₘᵢₙ.lower, p1.λₘₐₓ.upper - p2.λₘᵢₙ.lower)
    end

    return Linear(λₘᵢₙ, λₘₐₓ)
end

function combine_properties_subtraction(p1::Linear, p2::Quadratic)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

function combine_properties_subtraction(p1::Quadratic, p2::Linear)
    return error("Dimension mismatch. Operation not supposed to be performed.")
end

# === QUADRATIC === #
function combine_properties_subtraction(p1::Quadratic, p2::Quadratic)
    λₘᵢₙ = nothing
    λₘₐₓ = nothing
    if p1.λₘᵢₙ !== nothing && p2.λₘₐₓ !== nothing
        λₘᵢₙ = Interval(p1.λₘᵢₙ.lower - p2.λₘₐₓ.upper, p1.λₘᵢₙ.lower - p2.λₘₐₓ.upper)
    end

    if p1.λₘₐₓ !== nothing && p2.λₘᵢₙ !== nothing
        λₘₐₓ = Interval(p1.λₘₐₓ.upper - p2.λₘᵢₙ.lower, p1.λₘₐₓ.upper - p2.λₘᵢₙ.lower)
    end

    return Quadratic(λₘᵢₙ, λₘₐₓ)
end
