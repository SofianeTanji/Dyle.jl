"""
Abstract a single subexpression into a new function symbol.
For each eligible sub-block in an addition, maximum or minimum, generate a new expression
where that sub-block is replaced by H(args), and H is a fresh FunctionType.
"""
function structure_loss_strategy(expr)
    # helper to check atomicity: variable or simple call on variable
    is_atomic(e) =
        if e isa Variable
            true
        elseif e isa FunctionCall
            all(arg -> arg isa Variable, e.args)
        else
            false
        end

    results = Expression[]

    return results
end

# Register the strategy
register_strategy(:structure_loss, structure_loss_strategy)
