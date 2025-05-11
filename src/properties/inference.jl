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
    # Entering infer_properties for Addition with $(length(expr.terms)) terms"

    if isempty(expr.terms)
        # No terms in addition, returning empty set
        return Set{Property}()
    end

    term_props = [infer_properties(term) for term in expr.terms]

    if any(isempty(props) for props in term_props)
        # At least one term has no properties, returning empty set
        return Set{Property}()
    end

    result_props = term_props[1]

    for i in eachindex(term_props)[2:end]
        term_prop = term_props[i]
        if isempty(term_prop)
            continue
        end
        new_result = Set{Property}()
        for p1 in result_props
            for p2 in term_prop
                combined = combine_properties_addition(p1, p2)
                if combined !== nothing
                    push!(new_result, combined)
                end
            end
        end

        result_props = new_result
    end
    return result_props
end

function infer_properties(expr::Subtraction)
    if isempty(expr.terms)
        return Set{Property}()
    end

    term_props = [infer_properties(term) for term in expr.terms]
    for (i, props) in enumerate(term_props)
    end

    if any(isempty(props) for props in term_props)
        return Set{Property}()
    end

    result_props = term_props[1]

    for i in eachindex(term_props)[2:end]
        term_prop = term_props[i]
        if isempty(term_prop)
            continue
        end
        new_result = Set{Property}()
        for p1 in result_props
            for p2 in term_prop
                combined = combine_properties_subtraction(p1, p2)
                if combined !== nothing
                    push!(new_result, combined)
                else
                end
            end
        end

        result_props = new_result
    end

    return result_props
end

function infer_properties(expr::Composition)

    # Get properties of outer and inner expressions
    outer_props = infer_properties(expr.outer)
    inner_props = infer_properties(expr.inner)

    if isempty(outer_props) || isempty(inner_props)
        return Set{Property}()
    end

    # Initialize result set
    result_props = Set{Property}()

    # First check for special cases that require examining multiple properties
    set_props = combine_properties_composition(outer_props, inner_props)
    if set_props !== nothing
        union!(result_props, set_props)
    else
    end

    # Now apply the binary combination rules for all property pairs
    for p1 in outer_props
        for p2 in inner_props
            combined = combine_properties_composition(p1, p2)
            if combined !== nothing
                if combined isa Set
                    for c in combined
                        push!(result_props, c)
                    end
                else
                    push!(result_props, combined)
                end
            else
            end
        end
    end
    return result_props
end
