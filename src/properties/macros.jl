"""@property func_expr property_expr
Macro for associating properties with a function.
Example: @property f() Convex() Smooth(1.0)
"""
macro property(func_expr, property_expr...)
    if func_expr isa Symbol
        func_name = func_expr # Simple case @property f Convex() ...
    elseif func_expr.head == :call
        func_name = func_expr.args[1] # Complex case @property f() Convex() ...
    else
        error("Invalid function expression")
    end
    result = Expr(:block)

    if !isempty(property_expr) # Clear existing properties if any. # TODO: Check if this is necessary.
        push!(result.args, :(clear_properties($(QuoteNode(func_name)))))
    end

    for prop in property_expr
        push!(result.args, :(register_property($(QuoteNode(func_name))), $(esc(prop))))
    end
    return result
end
