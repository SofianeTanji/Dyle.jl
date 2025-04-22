# This file implements the algebra around properties.

"""infer_properties(expr::Expression)
"""
function infer_properties(expr::Expression)
    return Set{Property}() # This is the default. This should be specialized for each expression type. # TODO : check if this is the correct way.
end

function infer_properties(expr::Variable)
    return Set{Property}()
end

function infer_properties(expr::FunctionCall)
    return get_properties(expr.name)
end

function infer_properties(expr::Addition)
    if isempty(expr.terms)
        return Set{Property}()
    end

    term_props = [infer_properties(term) for term in expr.terms]

    result = Set{Property}()

    # TODO

    return result

end
