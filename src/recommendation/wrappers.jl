using ..Reformulations: generate_reformulations
using ..Database: get_methods_by_expression

"""
    which_methods(expr::Expression; unique::Bool=false)

Return matching methods for each reformulation of `expr`. If `unique=true`,
flatten and deduplicate all candidate methods into a single vector.
"""
function which_methods(expr::Expression; unique::Bool=false)
    all_reformulations = generate_reformulations(expr)
    results = []
    for reformulation in all_reformulations
        methods = get_methods_by_expression(reformulation)
        if !isempty(methods)
            push!(results, methods)
        end
    end
    if unique
        return unique(vcat(results...))
    else
        return results
    end
end

"""
    recommend(expr::Expression; unique::Bool=false, k::Union{Int, Nothing}=nothing)

Generate candidate methods for `expr` by reformulating and matching. Returns a nested vector of matches by default; set `unique=true` to flatten and deduplicate all candidates. If `k` is given, returns at most `k` candidates.
"""
function recommend(expr::Expression; unique::Bool=false, k::Union{Int,Nothing}=nothing)
    candidates = which_methods(expr; unique=unique)
    if k !== nothing && isa(candidates, AbstractVector)
        return candidates[1:min(k, length(candidates))]
    else
        return candidates
    end
end