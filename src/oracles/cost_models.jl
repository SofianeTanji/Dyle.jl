"""
Cost model system for oracles.
These types describe the computational complexity of oracle computations.
"""

"""
    CostModel

Represents the computational cost of an oracle.
"""
abstract type CostModel end

"""
Constant cost independent of problem dimensions.
"""
struct ConstantCost <: CostModel
    value::Float64
    ConstantCost(value::Float64 = 1.0) = new(value)
end

"""
Cost that scales with problem dimensions.
"""
struct DimensionalCost <: CostModel
    dimensions::Dict{Symbol,Float64}  # dimension => exponent
    coefficient::Float64

    function DimensionalCost(dimensions::Dict{Symbol,Float64}, coefficient::Float64 = 1.0)
        coefficient >= 0 || error("Coefficient must be non-negative")
        new(dimensions, coefficient)
    end

    # Convenience constructor for single dimension
    function DimensionalCost(dim::Symbol, exponent::Float64, coefficient::Float64 = 1.0)
        coefficient >= 0 || error("Coefficient must be non-negative")
        new(Dict(dim => exponent), coefficient)
    end
end

"""
    evaluate_cost(cost::CostModel, dims::Dict{Symbol, Int})

Evaluate the cost with given dimension values.
"""
evaluate_cost(cost::ConstantCost, dims::Dict{Symbol,Int} = Dict{Symbol,Int}()) = cost.value

function evaluate_cost(cost::DimensionalCost, dims::Dict{Symbol,Int})
    result = cost.coefficient
    for (dim, exp) in cost.dimensions
        haskey(dims, dim) || error("Dimension $dim not provided")
        result *= dims[dim]^exp
    end
    return result
end

# Common cost factories
constant_cost() = ConstantCost(1.0)
linear_cost(dim::Symbol) = DimensionalCost(dim, 1.0)
quadratic_cost(dim::Symbol) = DimensionalCost(dim, 2.0)
cubic_cost(dim::Symbol) = DimensionalCost(dim, 3.0)

# Cost operators
Base.:+(c1::ConstantCost, c2::ConstantCost) = ConstantCost(c1.value + c2.value)

function Base.:+(c1::DimensionalCost, c2::DimensionalCost)
    # If same dimensions with same exponents, add coefficients
    if c1.dimensions == c2.dimensions
        return DimensionalCost(c1.dimensions, c1.coefficient + c2.coefficient)
    end

    # Otherwise, combine dimensions
    result_dims = copy(c1.dimensions)
    for (dim, exp) in c2.dimensions
        if haskey(result_dims, dim)
            # Handle case where dimensions match but exponents differ
            if abs(result_dims[dim] - exp) < 1e-10
                result_dims[dim] = exp  # Keep the exponent
            else
                # Different exponents - defer to caller to handle
                return [c1, c2]  # Return array to indicate can't simplify
            end
        else
            result_dims[dim] = exp
        end
    end

    # Common case: dimensions are disjoint or same exponents
    return DimensionalCost(result_dims, c1.coefficient + c2.coefficient)
end

Base.:+(c1::ConstantCost, c2::DimensionalCost) = [c1, c2]  # Can't simplify
Base.:+(c1::DimensionalCost, c2::ConstantCost) = [c1, c2]  # Can't simplify

function Base.:*(c1::ConstantCost, c2::ConstantCost)
    return ConstantCost(c1.value * c2.value)
end

function Base.:*(c1::ConstantCost, c2::DimensionalCost)
    return DimensionalCost(c2.dimensions, c2.coefficient * c1.value)
end

Base.:*(c1::DimensionalCost, c2::ConstantCost) = c2 * c1

function Base.:*(c1::DimensionalCost, c2::DimensionalCost)
    # Combine dimensions by adding exponents
    result_dims = copy(c1.dimensions)
    for (dim, exp) in c2.dimensions
        result_dims[dim] = get(result_dims, dim, 0.0) + exp
    end

    return DimensionalCost(result_dims, c1.coefficient * c2.coefficient)
end
