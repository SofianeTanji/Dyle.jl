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
    println("Entering infer_properties for Addition with $(length(expr.terms)) terms")

    if isempty(expr.terms)
        println("No terms in addition, returning empty set")
        return Set{Property}()
    end

    term_props = [infer_properties(term) for term in expr.terms]
    println("Properties of each term:")
    for (i, props) in enumerate(term_props)
        println("  Term $i: $props")
    end

    if any(isempty(props) for props in term_props)
        println("At least one term has no properties, returning empty set")
        return Set{Property}()
    end

    result_props = term_props[1]
    println("Starting with properties from first term: $result_props")

    for i in eachindex(term_props)[2:end]
        term_prop = term_props[i]
        if isempty(term_prop)
            println("Term $i has no properties, skipping")
            continue
        end
        println("Combining with term $i: $term_prop")
        new_result = Set{Property}()
        for p1 in result_props
            for p2 in term_prop
                println("  Trying to combine $p1 with $p2")
                combined = combine_properties_addition(p1, p2)
                if combined !== nothing
                    println("    Result: $combined")
                    push!(new_result, combined)
                else
                    println("    Result: nothing (incompatible)")
                end
            end
        end

        result_props = new_result
        println("  Updated result: $result_props")
    end

    println("Final result: $result_props")
    return result_props
end
