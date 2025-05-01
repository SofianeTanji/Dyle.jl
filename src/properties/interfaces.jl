"""
    IPropertyProvider

An interface for providing property-related functionality.
This abstraction allows property checking and inference without exposing internal implementation details.
"""
abstract type IPropertyProvider end

"""
    register_property(provider::IPropertyProvider, func_name::Symbol, property::Property)

Register a property for a function.
Returns the property for chaining.

# Arguments
- `provider::IPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to register the property for
- `property::Property`: The property to register

# Returns
- The registered property
"""
function register_property end

"""
    clear_properties(provider::IPropertyProvider, func_name::Symbol)

Clear all properties registered for the given function.

# Arguments
- `provider::IPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to clear properties for
"""
function clear_properties end

"""
    get_properties(provider::IPropertyProvider, func_name::Symbol)

Get all properties registered for the given function.

# Arguments
- `provider::IPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to get properties for

# Returns
- A Set of Property objects associated with the function
"""
function get_properties end

"""
    has_property(provider::IPropertyProvider, func_name::Symbol, property_type::Type{<:Property})

Check if a function has a property of the specified type.

# Arguments
- `provider::IPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to check
- `property_type::Type{<:Property}`: The property type to check for

# Returns
- `true` if the function has the property type, `false` otherwise
"""
function has_property end

"""
    get_property(provider::IPropertyProvider, func_name::Symbol, property_type::Type{<:Property})

Get a specific property of the function if it exists.

# Arguments
- `provider::IPropertyProvider`: The property provider
- `func_name::Symbol`: The function name to get the property for
- `property_type::Type{<:Property}`: The property type to get

# Returns
- The property if found, `nothing` otherwise
"""
function get_property end

"""
    infer_properties(provider::IPropertyProvider, expr::Expression)

Infer the properties of a composite expression.

# Arguments
- `provider::IPropertyProvider`: The property provider
- `expr::Expression`: The expression to infer properties for

# Returns
- A Set of Property objects inferred for the expression
"""
function infer_properties end
