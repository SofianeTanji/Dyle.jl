module Properties

using ..Language
include("types.jl")
include("specials.jl")
include("inference.jl")
include("registry.jl")
include("macros.jl")

# Combinations
include("combinations/addition.jl")
include("combinations/subtraction.jl")
include("combinations/composition.jl")

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

export infer_properties

export register_property!, clear_properties!, get_properties, has_property, get_property

export @property

end
