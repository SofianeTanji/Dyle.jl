module Properties

using ..Language
include("types.jl")
include("interfaces.jl")
include("specials.jl")
include("registry.jl")
include("providers.jl")
include("macros.jl")
include("inference.jl")

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

# Interface exports
export IPropertyProvider,
    register_property,
    clear_properties,
    get_properties,
    has_property,
    get_property,
    infer_properties

# Provider implementations
export DefaultPropertyProvider

# Legacy direct functions (for backward compatibility)
export infer_properties

export register_property!, clear_properties!, get_properties, has_property, get_property

export @property

end
