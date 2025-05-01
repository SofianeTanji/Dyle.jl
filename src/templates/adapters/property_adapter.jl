"""
    PropertyAdapter

Adapter module to bridge the Templates and Properties modules.
This provides a clean interface for Templates to work with Properties without tight coupling.
"""
module PropertyAdapter

using ...Language
using ...Properties

"""
    meets_property_requirements(func_name::Symbol, required_properties::Vector{DataType},
                               provider::IPropertyProvider = DefaultPropertyProvider())

Check if a function meets all the specified property requirements.

# Arguments
- `func_name::Symbol`: The function name to check
- `required_properties::Vector{DataType}`: Property types that the function must have
- `provider::IPropertyProvider`: (Optional) The property provider to use

# Returns
- `true` if the function meets all requirements, `false` otherwise
"""
function meets_property_requirements(
    func_name::Symbol,
    required_properties::Vector{DataType},
    provider::IPropertyProvider = DefaultPropertyProvider(),
)
    # If no properties required, automatically passes
    isempty(required_properties) && return true

    # Check that the function has each required property
    for prop_type in required_properties
        if !has_property(provider, func_name, prop_type)
            return false
        end
    end

    return true
end

"""
    get_parameter_value(func_name::Symbol, property_type::Type{<:Property}, param_name::Symbol,
                      provider::IPropertyProvider = DefaultPropertyProvider())

Get a parameter value from a function's property.

# Arguments
- `func_name::Symbol`: The function name to check
- `property_type::Type{<:Property}`: The property type to get the parameter from
- `param_name::Symbol`: The parameter name to get
- `provider::IPropertyProvider`: (Optional) The property provider to use

# Returns
- The parameter value if found, `nothing` otherwise
"""
function get_parameter_value(
    func_name::Symbol,
    property_type::Type{<:Property},
    param_name::Symbol,
    provider::IPropertyProvider = DefaultPropertyProvider(),
)
    # Get the specific property
    prop = get_property(provider, func_name, property_type)

    # Return nothing if property not found
    prop === nothing && return nothing

    # Check if the property has the parameter
    if hasfield(typeof(prop), param_name)
        return getfield(prop, param_name)
    end

    return nothing
end

"""
    get_properties_for_function(func_name::Symbol, provider::IPropertyProvider = DefaultPropertyProvider())

Get all properties for a function.

# Arguments
- `func_name::Symbol`: The function name to get properties for
- `provider::IPropertyProvider`: (Optional) The property provider to use

# Returns
- A Set of Property objects associated with the function
"""
function get_properties_for_function(
    func_name::Symbol,
    provider::IPropertyProvider = DefaultPropertyProvider(),
)
    return get_properties(provider, func_name)
end

"""
    infer_properties_for_expression(expr::Expression, provider::IPropertyProvider = DefaultPropertyProvider())

Infer properties for an expression.

# Arguments
- `expr::Expression`: The expression to infer properties for
- `provider::IPropertyProvider`: (Optional) The property provider to use

# Returns
- A Set of Property objects inferred for the expression
"""
function infer_properties_for_expression(
    expr::Expression,
    provider::IPropertyProvider = DefaultPropertyProvider(),
)
    return infer_properties(provider, expr)
end

end # module
