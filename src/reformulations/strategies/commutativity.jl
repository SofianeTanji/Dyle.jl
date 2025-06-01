# Permutation helper for commutative operations
function __permute_terms(terms::Vector{T}) where {T}
    n = length(terms)
    if n <= 1
        return [copy(terms)]
    end
    result = Vector{Vector{T}}()
    for i in 1:n
        head = terms[i]
        rest = [terms[j] for j in 1:n if j != i]
        for perm in __permute_terms(rest)
            push!(result, [head; perm])
        end
    end
    return result
end

# Commutativity strategy: handles Addition, Maximum, Minimum
function commutativity_strategy(expr)
    if expr isa Addition
        perms = __permute_terms(expr.terms)
        return [Addition(p, expr.space) for p in perms]
    elseif expr isa Maximum
        perms = __permute_terms(expr.terms)
        return [Maximum(p, expr.space) for p in perms]
    elseif expr isa Minimum
        perms = __permute_terms(expr.terms)
        return [Minimum(p, expr.space) for p in perms]
    else
        return [expr]
    end
end

# Register under :commutativity
register_strategy(:commutativity, commutativity_strategy)
