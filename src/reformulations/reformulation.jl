module Reformulations

import Base: ==, hash

using ..Language
using ..Properties
using ..Oracles
using ..Templates

include("strategies/structure_loss.jl")

export Reformulation, generate_reformulations

"""
    Reformulation(expr, properties, oracles)

A reformulated version of `expr` carrying its inferred properties and oracles.
"""
struct Reformulation
    expr::Expression
    properties::Set{Property}
    oracles::Dict{DataType,Any}
end

function ==(r1::Reformulation, r2::Reformulation)
    return r1.expr == r2.expr &&
           r1.properties == r2.properties &&
           (r1.oracles) == (r2.oracles)
end

isequal(r1::Reformulation, r2::Reformulation) = r1 == r2

function hash(r::Reformulation, h::UInt)
    return hash((
        string(r.expr), # FIXME: are there edge cases ?
        r.properties,
        r.oracles,
    ), h)
end


"""
    generate_reformulations(expr::Expression) -> Vector{Reformulation}

Apply all registered reformulation strategies to `expr`.
"""
function generate_reformulations(expr::Expression)
    # list each strategy function here as it is defined in the
    # strategies/*.jl files
    strategies = (structure_loss,)

    variants = unique(vcat([expr], _rebalance(expr)))

    return unique([s(v) for v in variants for s in strategies])
end

# internal: flatten nested Addition into a list of terms
function _flatten_add_terms(add::Addition)
    terms = Expression[]
    for t in add.terms
        if t isa Addition
            append!(terms, _flatten_add_terms(t))
        else
            push!(terms, t)
        end
    end
    return terms
end

# internal: generate all binary rebalances of an Addition node
function _rebalance(expr::Expression)::Vector{Expression}
    rebs = Expression[]
    if expr isa Addition
        flat = _flatten_add_terms(expr)
        n = length(flat)
        for k = 1:n-1
            left = Addition(flat[1:k], expr.space)
            right = Addition(flat[k+1:end], expr.space)
            push!(rebs, left, right)
            # also rebalance their subtrees
            for l in _rebalance(left), r in _rebalance(right)
                push!(rebs, l, r)
            end
        end
    end
    return unique(rebs)
end

end
