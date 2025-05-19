# Registry system provides a way to associate math properties with function symbols.
# This is basically what allows annotating functions with properties.

const function_property_registry = Dict{Symbol,Set{Property}}()

"""register_property!(f::Symbol, p::Property)
    Register a property `p` for the function `f`.
    If the function is already registered, add the property to the set of properties.
"""
function register_property!(f::Symbol, p::Property)
    if haskey(function_property_registry, f)
        push!(function_property_registry[f], p)
    else
        function_property_registry[f] = Set{Property}([p])
    end
    return p
end

"""clear_properties!(f::Symbol)
    Clear all properties for the function `f`.
"""
function clear_properties!(f::Symbol)
    if haskey(function_property_registry, f)
        delete!(function_property_registry, f)
    end
    return nothing
end

# "get_properties(f::Symbol)" remains the main entry point
# But allow Expression names to be inferred by falling back to infer_properties
using ..Properties: infer_properties  # fallback for composed names

# forward non-Symbol names to structural inference
function get_properties(f::Expression)
    return infer_properties(f)  # use full inference for composed or nested names
end

"""
    get_properties(f::Symbol)
"""
# Get the properties of the function `f`.
function get_properties(f::Symbol)
    if haskey(function_property_registry, f)
        return function_property_registry[f]
    else
        return Set{Property}()
    end
end

"""has_property(f::Symbol, p::Type{<:Property})
    Check if the function `f` has the property `p`.
"""
function has_property(f::Symbol, prop_type::Type{<:Property})
    return any(p isa prop_type for p in get_properties(f))
end

"""get_property(f::Symbol, prop_type::Type{<:Property})
    Get the property `p` of the function `f`.
"""
function get_property(f::Symbol, prop_type::Type{<:Property})
    props = get_properties(f)
    for p in props
        if p isa prop_type
            return p
        end
    end
    return nothing
end
