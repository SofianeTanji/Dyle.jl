# === CONVEX === #

function combine_properties_composition(p1::Convex, p2::Convex)
    return nothing
end

function combine_properties_composition(p1::Convex, p2::StronglyConvex)
    return nothing
end

function combine_properties_composition(p1::StronglyConvex, p2::Convex)
    return nothing
end

function combine_properties_composition(p1::Convex, p2::HypoConvex)
    return nothing
end

function combine_properties_composition(p1::HypoConvex, p2::Convex)
    return nothing
end

function combine_properties_composition(p1::Convex, p2::Smooth)
    return nothing
end

function combine_properties_composition(p1::Smooth, p2::Convex)
    return nothing
end

function combine_properties_composition(p1::Convex, p2::Lipschitz)
    return nothing
end

function combine_properties_composition(p1::Lipschitz, p2::Convex)
    return nothing
end

function combine_properties_composition(p1::Convex, p2::Linear)
    return Convex()
end

function combine_properties_composition(p1::Linear, p2::Convex)
    return nothing
end

function combine_properties_composition(p1::Convex, p2::Quadratic)
    return nothing
end


function combine_properties_composition(p1::Quadratic, p2::Convex)
    return nothing
end

# === STRONGLY CONVEX === #
function combine_properties_composition(p1::StronglyConvex, p2::StronglyConvex)
    return nothing
end

function combine_properties_composition(p1::StronglyConvex, p2::HypoConvex)
    return nothing
end

function combine_properties_composition(p1::HypoConvex, p2::StronglyConvex)
    return nothing
end

function combine_properties_composition(p1::StronglyConvex, p2::Smooth)
    return nothing
end

function combine_properties_composition(p1::Smooth, p2::StronglyConvex)
    return nothing
end

function combine_properties_composition(p1::StronglyConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_composition(p1::Lipschitz, p2::StronglyConvex)
    return nothing
end

function combine_properties_composition(p1::StronglyConvex, p2::Linear)
    if p1.μ === nothing || p2.λₘᵢₙ === nothing
        return Convex() # We at least know it's convex
    end

    if p2.λₘᵢₙ.lower <= 0
        return Convex()
    end
    return StronglyConvex(
        Interval(p1.μ.lower + p2.λₘᵢₙ.lower^2, p1.μ.upper + p2.λₘᵢₙ.upper^2),
    )
end

function combine_properties_composition(p1::Linear, p2::StronglyConvex)
    return nothing
end

function combine_properties_composition(p1::StronglyConvex, p2::Quadratic)
    return nothing
end

function combine_properties_composition(p1::Quadratic, p2::StronglyConvex)
    return nothing
end

# === HypoConvex === #

function combine_properties_composition(p1::HypoConvex, p2::HypoConvex)
    return nothing
end

function combine_properties_composition(p1::HypoConvex, p2::Smooth)
    return nothing
end

function combine_properties_composition(p1::Smooth, p2::HypoConvex)
    return nothing
end

function combine_properties_composition(p1::HypoConvex, p2::Lipschitz)
    return nothing
end

function combine_properties_composition(p1::Lipschitz, p2::HypoConvex)
    return nothing
end

function combine_properties_composition(p1::HypoConvex, p2::Linear)
    if p1.ρ === nothing || p2.λₘₐₓ === nothing
        return HypoConvex() # We know it's hypoconvex but can't quantify
    end
    return HypoConvex(Interval(p1.ρ.lower * p2.λₘₐₓ.lower^2, p1.ρ.upper * p2.λₘₐₓ.upper^2))
end

function combine_properties_composition(p1::Linear, p2::HypoConvex)
    return nothing
end

function combine_properties_composition(p1::HypoConvex, p2::Quadratic)
    return nothing
end

function combine_properties_composition(p1::Quadratic, p2::HypoConvex)
    return nothing
end

# === SMOOTH === #
function combine_properties_composition(p1::Smooth, p2::Smooth)
    return nothing
end

function combine_properties_composition(p1::Smooth, p2::Lipschitz)
    if p1.L === nothing || p2.M === nothing
        return Smooth() # We know it's smooth but can't quantify
    end
    return Smooth(Interval(p1.L.lower * p2.M.lower^2, p1.L.upper * p2.M.upper^2))
end

function combine_properties_composition(p1::Lipschitz, p2::Smooth)
    return nothing
end

function combine_properties_composition(p1::Smooth, p2::Linear)
    if p1.L === nothing || p2.λₘᵢₙ === nothing
        return Smooth() # We know it's smooth but can't quantify
    end
    return Smooth(Interval(p1.L.lower + p2.λₘᵢₙ.lower^2, p1.L.upper + p2.λₘᵢₙ.upper^2))
end

function combine_properties_composition(p1::Linear, p2::Smooth)
    return nothing
end

function combine_properties_composition(p1::Smooth, p2::Quadratic)
    return nothing
end

function combine_properties_composition(p1::Quadratic, p2::Smooth)
    return nothing
end

# === LIPSCHITZ === #

function combine_properties_composition(p1::Lipschitz, p2::Lipschitz)
    if p1.M === nothing || p2.M === nothing
        return Lipschitz() # We know it's Lipschitz but can't quantify
    end
    return Lipschitz(Interval(p1.M.lower * p2.M.lower, p1.M.upper * p2.M.upper))
end

function combine_properties_composition(p1::Lipschitz, p2::Linear)
    if p1.M === nothing || p2.λₘᵢₙ === nothing
        return Lipschitz() # We know it's Lipschitz but can't quantify
    end
    return Lipschitz(Interval(p1.M.lower + p2.λₘᵢₙ.lower, p1.M.upper + p2.λₘᵢₙ.upper))
end

function combine_properties_composition(p1::Linear, p2::Lipschitz)
    if p1.λₘᵢₙ === nothing || p2.M === nothing
        return Lipschitz() # We know it's Lipschitz but can't quantify
    end
    return Lipschitz(Interval(p1.λₘᵢₙ.lower * p2.M.lower, p1.λₘᵢₙ.upper * p2.M.upper))
end

function combine_properties_composition(p1::Lipschitz, p2::Quadratic)
    return nothing
end

function combine_properties_composition(p1::Quadratic, p2::Lipschitz)
    return nothing
end

# === LINEAR === #
function combine_properties_composition(p1::Linear, p2::Linear)
    return Linear() # FIXME: I think we can get conservative bounds on the eigenvalues here.
end

function combine_properties_composition(p1::Linear, p2::Quadratic)
    return nothing
end

function combine_properties_composition(p1::Quadratic, p2::Linear)
    return Quadratic # FIXME: I think we can get conservative bounds on the eigenvalues here.
end

# === QUADRATIC === #
function combine_properties_composition(p1::Quadratic, p2::Quadratic)
    return nothing
end

# === SPECIAL CASES === #
function combine_properties_composition(
    outer_props::Set{Property},
    inner_props::Set{Property},
)
    result = Set{Property}()

    # Case 1: Monotonically increasing convex ∘ convex = convex
    has_monotone = any(p isa MonotonicallyIncreasing for p in outer_props)
    has_convex_outer = any(p isa Convex || p isa StronglyConvex for p in outer_props)
    has_convex_inner = any(p isa Convex || p isa StronglyConvex for p in inner_props)

    if has_monotone && has_convex_outer && has_convex_inner
        push!(result, Convex())
    end
end
