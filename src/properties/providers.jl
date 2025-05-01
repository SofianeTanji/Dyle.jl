"""
    Concrete implementations of the IPropertyProvider interface.
"""

"""
    DefaultPropertyProvider <: IPropertyProvider

Default implementation of the IPropertyProvider interface that uses the global property registry.
"""
struct DefaultPropertyProvider <: IPropertyProvider end

"""
    register_property(provider::DefaultPropertyProvider, func_name::Symbol, property::Property)

Register a property for a function using the global registry.

# Arguments
- `provider::DefaultPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to register the property for
- `property::Property`: The property to register

# Returns
- The registered property
"""
function register_property(::DefaultPropertyProvider, func_name::Symbol, property::Property)
    return register_property!(func_name, property)
end

"""
    clear_properties(provider::DefaultPropertyProvider, func_name::Symbol)

Clear all properties for a function using the global registry.

# Arguments
- `provider::DefaultPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to clear properties for
"""
function clear_properties(::DefaultPropertyProvider, func_name::Symbol)
    return clear_properties!(func_name)
end

"""
    get_properties(provider::DefaultPropertyProvider, func_name::Symbol)

Get all properties for a function using the global registry.

# Arguments
- `provider::DefaultPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to get properties for

# Returns
- A Set of Property objects associated with the function
"""
function get_properties(::DefaultPropertyProvider, func_name::Symbol)
    return get_properties(func_name)
end

"""
    has_property(provider::DefaultPropertyProvider, func_name::Symbol, property_type::Type{<:Property})

Check if a function has a property of the specified type using the global registry.

# Arguments
- `provider::DefaultPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to check
- `property_type::Type{<:Property}`: The property type to check for

# Returns
- `true` if the function has the property type, `false` otherwise
"""
function has_property(
    ::DefaultPropertyProvider,
    func_name::Symbol,
    property_type::Type{<:Property},
)
    return has_property(func_name, property_type)
end

"""
    get_property(provider::DefaultPropertyProvider, func_name::Symbol, property_type::Type{<:Property})

Get a specific property of a function if it exists using the global registry.

# Arguments
- `provider::DefaultPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to get the property for
- `property_type::Type{<:Property}`: The property type to get

# Returns
- The property if found, `nothing` otherwise
"""
function get_property(
    ::DefaultPropertyProvider,
    func_name::Symbol,
    property_type::Type{<:Property},
)
    return get_property(func_name, property_type)
end

"""
    infer_properties(provider::DefaultPropertyProvider, expr::Expression)

Infer the properties of a composite expression using the global inference system.

# Arguments
- `provider::DefaultPropertyProvider`: The property provider
- `expr::Expression`: The expression to infer properties for

# Returns
- A Set of Property objects inferred for the expression
"""
function infer_properties(::DefaultPropertyProvider, expr::Expression)
    return infer_properties(expr)
end
