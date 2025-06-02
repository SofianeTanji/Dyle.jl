# Query and listing functions for Database

import Base: getindex

using ..Language: Expression  # ensure Expression type imported

# Utility: compare names
_eq(a, b) = a == b

# get_rates_by_template: returns Dict{Method,Vector{Rate}}
function get_rates_by_template(name::Symbol)
    result = Dict{Method,Vector{Rate}}()
    for (key, rates) in DATABASE
        t, m = key
        if t.name == name
            result[m] = rates
        end
    end
    isempty(result) && throw(NotFoundError("No rates found for template: $(name)"))
    return result
end

# get_rates_by_method: returns Dict{Template,Vector{Rate}}
function get_rates_by_method(name::Symbol)
    result = Dict{Template,Vector{Rate}}()
    for (key, rates) in DATABASE
        t, m = key
        if m.name == name
            result[t] = rates
        end
    end
    isempty(result) && throw(NotFoundError("No rates found for method: $(name)"))
    return result
end

function get_methods_by_expression(expr::Expression)
    methods = Set{Method}()
    for ((t, m), _) in DATABASE
        if t.expr == expr
            push!(methods, m)
        end
    end
    isempty(methods) && throw(NotFoundError("No methods found for expression: $(expr)"))
    return collect(methods)
end

# get_all_rates: returns the database constant
get_all_rates() = DATABASE

# get_rates: return all matching Rate entries for given template, method, measure
function get_rates(template_name::Symbol, method_name::Symbol, measure::Symbol)
    matches = Vector{Rate}()
    for ((t, m), rates) in DATABASE
        if t.name == template_name && m.name == method_name
            for r in rates
                if r.measure == measure
                    push!(matches, r)
                end
            end
        end
    end
    isempty(matches) && throw(
        NotFoundError(
            "No rate found for template=$(template_name), method=$(method_name), measure=$(measure)",
        ),
    )
    return matches
end

# listing functions
function list_templates()
    uniq_templates = Set{Template}()
    for ((t, _), _) in DATABASE
        push!(uniq_templates, t)
    end
    return collect(uniq_templates)
end

function list_methods()
    uniq_methods = Set{Method}()
    for ((_, m), _) in DATABASE
        push!(uniq_methods, m)
    end
    return collect(uniq_methods)
end

function list_measures(template_name::Symbol, method_name::Symbol)
    for ((t, m), rates) in DATABASE
        if t.name == template_name && m.name == method_name
            return [r.measure for r in rates]
        end
    end
    throw(
        NotFoundError(
            "No measures found for template=$(template_name), method=$(method_name)"
        ),
    )
end
