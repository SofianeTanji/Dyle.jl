"""Space
Base type for all spaces in the system.
"""
abstract type Space end

"""R <: Space
Represents the real number space (scalar).
"""
struct R <: Space end

"""Rn <: Space
Represents the n-dimensional real vector space.

Fields:
- `n::Union{Int,Symbol}`: The dimension of the space, which can be either:
  - An integer for a concrete dimension (e.g., R³)
  - A symbol for a parametric dimension (e.g., Rⁿ where n is a parameter)
"""
struct Rn <: Space
    n::Union{Int,Symbol}

    function Rn(n::Int)
        n > 0 || error("Dimension must be positive")
        new(n)
    end

    # Allow symbolic dimensions
    Rn(n::Symbol) = new(n)
end

# Equality for spaces
import Base: ==
==(::R, ::R) = true
==(a::Rn, b::Rn) = a.n == b.n
==(::R, ::Rn) = false
==(::Rn, ::R) = false

# String representation
import Base: show
show(io::IO, ::R) = print(io, "ℝ")
show(io::IO, r::Rn) = print(io, "ℝ^", r.n)
