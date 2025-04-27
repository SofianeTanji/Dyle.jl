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

    if any(isempty(props) for props in term_props)
        return Set{Property}() # If any term has no known properties, we can't guarantee having any property.
    end

    result_props = term_props[1]
    for i in eachindex(term_props)[2:end]
        term_prop = term_props[i]
        new_result = Set{Property}()
        for p1 in result_props
            for p2 in term_prop
                combined = combine_properties_addition(p1, p2)
                if combined !== nothing
                    push!(new_result, combined)
                end
            end
        end
        if isempty(new_result)
            return Set{Property}() # If we can't combine any properties, we can't guarantee having any property.
        end
        result_props = new_result
    end

    return result
end
