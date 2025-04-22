module Property

using ..Language
include("types.jl")
include("specials.jl")

# === PUBLIC API === #
export Property,
    Convex,
    MonotonicallyIncreasing,
    StronglyConvex,
    HypoConvex,
    Smooth,
    Lipschitz,
    Linear,
    Quadratic

end
