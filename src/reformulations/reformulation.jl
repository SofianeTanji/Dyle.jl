module Reformulations

using ..Language
using ..Properties
using ..Oracles
using Base: hash

export Reformulation, create_reformulation  # helper function for building Reformulation

"""
A Reformulation pairs an expression with its inferred properties and computational oracles.
"""
struct Reformulation
    expr::Expression
    properties::Set{Property}
    oracles::Dict{DataType,Any}
end

"""
Construct a Reformulation with no properties or oracles yet.
"""
function Reformulation(expr::Expression)
    return Reformulation(expr, Set{Property}(), Dict{DataType,Any}())
end

# Equality: two reformulations are equal if all fields match
function Base.:(==)(r1::Reformulation, r2::Reformulation)
    return r1.expr == r2.expr && r1.properties == r2.properties && r1.oracles == r2.oracles
end

# Hash: combine hashes of all fields
function Base.hash(r::Reformulation, h::UInt)
    h = hash(r.expr, h)
    h = hash(r.properties, h)
    h = hash(r.oracles, h)
    return h
end

"""
Create a full Reformulation by inferring properties and gathering oracles for an expression.
"""
function create_reformulation(expr)
    props = infer_properties(expr)
    oracles = Dict{DataType,Any}()
    for oracle_type in (EvaluationOracle, DerivativeOracle, ProximalOracle)
        oracle = get_oracle(expr, oracle_type)
        if oracle !== nothing
            oracles[oracle_type] = oracle
        end
    end
    return Reformulation(expr, props, oracles)
end

include("strategies.jl")  # register strategy code into Reformulations
export register_strategy, get_strategy, list_strategies, apply_strategy

export generate_reformulations  # orbit exploration

"""
Generate all unique reformulations by applying registered strategies.

Arguments:
- `expr`: initial expression (any subtype)
- `max_iterations`: maximum breadth-first steps (default=1)
- `strategies_to_apply`: list of strategy names to use (default=all)
"""
function generate_reformulations(
    expr; max_iterations::Int=1, strategies_to_apply::Vector{Symbol}=list_strategies()
)
    # Track seen expressions and results
    seen_exprs = Set{Expression}([expr])
    results = Vector{Reformulation}([])
    queue = [expr]
    iter = 0
    while !isempty(queue) && iter < max_iterations
        current_expr = popfirst!(queue)
        for name in strategies_to_apply
            for new_expr in apply_strategy(name, current_expr)
                if !(new_expr in seen_exprs)
                    # New unique expression
                    push!(seen_exprs, new_expr)
                    push!(queue, new_expr)
                    push!(results, create_reformulation(new_expr))
                end
            end
        end
        iter += 1
    end
    return results
end

end # module Reformulations
