"""
Exactness types for oracles.
These types describe the level of precision of oracle computations.
"""

"""
Represents the exactness level of an oracle computation.
"""
abstract type Exactness end

"""
Exact computations with no error.
"""
struct Exact <: Exactness end

"""
Inexact computations with absolute error bounds.
"""
struct AbsoluteError <: Exactness
    ε::Float64

    function AbsoluteError(ε::Float64)
        ε >= 0 || error("Error bound must be non-negative")
        new(ε)
    end
end

"""
Inexact computations with relative error bounds.
"""
struct RelativeError <: Exactness
    ε::Float64

    function RelativeError(ε::Float64)
        ε >= 0 || error("Error bound must be non-negative")
        new(ε)
    end
end

"""
    error_bound(e::Exactness)

Get the error bound for an exactness specification.
"""
error_bound(::Exact) = 0.0
error_bound(e::AbsoluteError) = e.ε
error_bound(e::RelativeError) = e.ε

"""
    is_relative_error(e::Exactness)

Check if the error is relative.
"""
is_relative_error(::Exact) = false
is_relative_error(::AbsoluteError) = false
is_relative_error(::RelativeError) = true
