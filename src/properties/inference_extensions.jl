"""
Extension functions for property inference using the IPropertyProvider interface.
"""

# Global default provider instance
const global_property_provider = DefaultPropertyProvider()

"""
    with_provider(func::Function, provider::IPropertyProvider)

Execute a function with a specific property provider.

# Arguments
- `func::Function`: The function to execute with the provider
- `provider::IPropertyProvider`: The property provider to use

# Returns
- The result of the function
"""
function with_provider(func::Function, provider::IPropertyProvider)
    return func(provider)
end

"""
    infer_properties_with_provider(expr::Expression, provider::IPropertyProvider)

Infer properties of an expression using a specific provider.

# Arguments
- `expr::Expression`: The expression to infer properties for
- `provider::IPropertyProvider`: The property provider to use

# Returns
- A Set of Property objects inferred for the expression
"""
function infer_properties_with_provider(expr::Expression, provider::IPropertyProvider)
    return infer_properties(provider, expr)
end

# Overload the existing global infer_properties function to use the default provider
# This maintains backward compatibility while using the new interface internally
function infer_properties(expr::Expression)
    return infer_properties(global_property_provider, expr)
end
