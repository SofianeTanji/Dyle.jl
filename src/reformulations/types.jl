"""
    Reformulation

A reformulated version of an expression carrying its inferred properties and oracles.

# Fields
- `expr::Expression`: The reformulated expression
- `properties::Set{Property}`: The mathematical properties of the expression
- `oracles::Dict{DataType,Any}`: Available computational oracles for the expression
"""
struct Reformulation
    expr::Expression
    properties::Set{Property}
    oracles::Dict{DataType,Any}
end

# Define equality for reformulations based on their expressions
import Base: ==, hash

# Two reformulations are equal if their expressions are equal
function ==(r1::Reformulation, r2::Reformulation)
    return r1.expr == r2.expr && r1.properties == r2.properties && r1.oracles == r2.oracles
end

# Hash function must be consistent with equality
function hash(r::Reformulation, h::UInt)
    return hash(
        string(r.expr) *
        " props: " *
        string(r.properties) *
        " oracles: " *
        string(r.oracles),
        h,
    )
end

"""
    Strategy

Abstract type for all reformulation strategies.
Each strategy represents a transformation that can be applied to an expression.
"""
abstract type Strategy end

"""
    (strategy::Strategy)(expr::Expression) -> Vector{Reformulation}

Apply a strategy to an expression to produce reformulations.
"""
function (strategy::Strategy)(expr::Expression)
    # Default implementation - override in concrete strategies
    return Vector{Reformulation}()
end

"""
    compute_reformulation_metadata(expr::Expression) -> Tuple{Set{Property}, Dict{DataType,Any}}

Compute the properties and oracles for a reformulated expression.

# Arguments
- `expr::Expression`: The expression to analyze

# Returns
- `Tuple{Set{Property}, Dict{DataType,Any}}`: Properties and oracles of the expression
"""
function compute_reformulation_metadata(expr::Expression)
    # Infer properties
    properties = infer_properties(expr)

    # Gather available oracles
    oracles = Dict{DataType,Any}()
    for oracle_type in [EvaluationOracle, DerivativeOracle, ProximalOracle]
        oracle = get_oracle_for_expression(expr, oracle_type)
        if oracle !== nothing
            oracles[oracle_type] = oracle
        end
    end

    return properties, oracles
end

"""
    create_reformulation(expr::Expression) -> Reformulation

Create a Reformulation object from an expression by computing its properties and oracles.

# Arguments
- `expr::Expression`: The expression to reformulate

# Returns
- `Reformulation`: The created reformulation
"""
function create_reformulation(expr::Expression)
    properties, oracles = compute_reformulation_metadata(expr)
    return Reformulation(expr, properties, oracles)
end
