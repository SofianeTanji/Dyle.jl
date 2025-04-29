"""
Cost model system for oracles.
These types describe the computational complexity of oracle computations.
"""

abstract type CostModel end

"""
    ConstantCost <: CostModel

Represents fixed computational cost, independent of problem dimensions.
"""
struct ConstantCost <: CostModel
    value::Float64

    ConstantCost(value::Float64 = 1.0) = new(value)
end

"""
    DimensionalCost <: CostModel

Represents computational cost that scales with problem dimensions.

Fields:
- `dim_symbols`: Dictionary mapping dimension symbols to exponents
- `coefficient`: Scaling coefficient for the cost
"""
struct DimensionalCost <: CostModel
    dim_symbols::Dict{Symbol,Float64}
    coefficient::Float64

    function DimensionalCost(dim_symbols::Dict{Symbol,Float64}, coefficient::Float64 = 1.0)
        coefficient >= 0 || error("Coefficient must be non-negative")
        new(dim_symbols, coefficient)
    end

    # Convenience constructor for single dimension
    function DimensionalCost(dim::Symbol, exponent::Float64, coefficient::Float64 = 1.0)
        coefficient >= 0 || error("Coefficient must be non-negative")
        new(Dict(dim => exponent), coefficient)
    end
end

"""
    CompositeCost <: CostModel

Represents a combination of multiple cost models.

Fields:
- `components`: Vector of component cost models
- `operation`: Function that combines component costs (e.g., +, max)
"""
struct CompositeCost <: CostModel
    components::Vector{CostModel}
    operation::Function

    function CompositeCost(components::Vector{CostModel}, operation::Function)
        isempty(components) && error("Components list cannot be empty")
        new(components, operation)
    end
end

# Operator overloading for cost models

# Addition of cost models
function Base.:+(c1::ConstantCost, c2::ConstantCost)
    return ConstantCost(c1.value + c2.value)
end

function Base.:+(c1::DimensionalCost, c2::DimensionalCost)
    # If both costs involve the same dimensions with same exponents,
    # we can simply add the coefficients
    if c1.dim_symbols == c2.dim_symbols
        return DimensionalCost(c1.dim_symbols, c1.coefficient + c2.coefficient)
    end

    # Otherwise, create a composite cost
    return CompositeCost([c1, c2], +)
end

function Base.:+(c1::ConstantCost, c2::DimensionalCost)
    return CompositeCost([c1, c2], +)
end

function Base.:+(c1::DimensionalCost, c2::ConstantCost)
    return c2 + c1
end

function Base.:+(c1::CompositeCost, c2::CostModel)
    if c1.operation === +
        return CompositeCost([c1.components..., c2], +)
    end
    return CompositeCost([c1, c2], +)
end

function Base.:+(c1::CostModel, c2::CompositeCost)
    return c2 + c1
end

function Base.:+(c1::CompositeCost, c2::CompositeCost)
    if (c1.operation === +) && (c2.operation === +)
        return CompositeCost([c1.components..., c2.components...], +)
    end
    return CompositeCost([c1, c2], +)
end

# Multiplication of cost models
function Base.:*(c1::ConstantCost, c2::ConstantCost)
    return ConstantCost(c1.value * c2.value)
end

function Base.:*(c1::ConstantCost, c2::DimensionalCost)
    return DimensionalCost(c2.dim_symbols, c2.coefficient * c1.value)
end

function Base.:*(c1::DimensionalCost, c2::ConstantCost)
    return c2 * c1
end

function Base.:*(c1::DimensionalCost, c2::DimensionalCost)
    # Combine dimension symbols by adding their exponents
    combined_dims = Dict{Symbol,Float64}()

    # Add dimensions from c1
    for (dim, exp) in c1.dim_symbols
        combined_dims[dim] = get(combined_dims, dim, 0.0) + exp
    end

    # Add dimensions from c2
    for (dim, exp) in c2.dim_symbols
        combined_dims[dim] = get(combined_dims, dim, 0.0) + exp
    end

    return DimensionalCost(combined_dims, c1.coefficient * c2.coefficient)
end

function Base.:*(c1::CompositeCost, c2::CostModel)
    if c1.operation === *
        return CompositeCost([c1.components..., c2], *)
    end
    return CompositeCost([c1, c2], *)
end

function Base.:*(c1::CostModel, c2::CompositeCost)
    return c2 * c1
end

function Base.:*(c1::CompositeCost, c2::CompositeCost)
    if (c1.operation === *) && (c2.operation === *)
        return CompositeCost([c1.components..., c2.components...], *)
    end
    return CompositeCost([c1, c2], *)
end

# Evaluation of cost models
function evaluate_cost(cost::ConstantCost, dims::Dict{Symbol,Int} = Dict{Symbol,Int}())
    return cost.value
end

function evaluate_cost(cost::DimensionalCost, dims::Dict{Symbol,Int})
    result = cost.coefficient
    for (dim, exp) in cost.dim_symbols
        haskey(dims, dim) || error("Dimension $dim not provided")
        result *= dims[dim]^exp
    end
    return result
end

function evaluate_cost(cost::CompositeCost, dims::Dict{Symbol,Int})
    component_costs = [evaluate_cost(c, dims) for c in cost.components]
    return cost.operation(component_costs)
end

# Common cost models
constant_cost() = ConstantCost(1.0)
linear_cost(dim::Symbol) = DimensionalCost(dim, 1.0)
quadratic_cost(dim::Symbol) = DimensionalCost(dim, 2.0)
cubic_cost(dim::Symbol) = DimensionalCost(dim, 3.0)
exponential_cost(dim::Symbol) = DimensionalCost(Dict(dim => 1.0), 2.0)  # O(2^n)
