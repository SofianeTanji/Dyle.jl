"""
Exactness type system for oracles.
These types describe the level of exactness (precision) of oracle computations.
"""

abstract type Exactness end

"""
    Exact <: Exactness

Represents oracles that provide exact (analytically precise) computations.
"""
struct Exact <: Exactness end

"""
Error specification base type for inexact oracles.
"""
abstract type ErrorSpec end

"""
    AbsoluteError <: ErrorSpec

Represents an absolute error bound.
Error is bounded by a fixed value: |f(x) - f̂(x)| ≤ ε
"""
struct AbsoluteError <: ErrorSpec
    ε::Float64

    function AbsoluteError(ε::Float64)
        ε >= 0 || error("Error bound must be non-negative")
        new(ε)
    end
end

"""
    RelativeError <: ErrorSpec

Represents a relative error bound.
Error is bounded relative to true value: |f(x) - f̂(x)| ≤ ε⋅|f(x)|
"""
struct RelativeError <: ErrorSpec
    ε::Float64

    function RelativeError(ε::Float64)
        ε >= 0 || error("Error bound must be non-negative")
        new(ε)
    end
end

"""
    Inexact{E<:ErrorSpec} <: Exactness

Represents oracles with inexact (approximate) computations with error bounds.
"""
struct Inexact{E<:ErrorSpec} <: Exactness
    error_spec::E

    # Convenience constructor for absolute error
    Inexact(ε::Float64) = new{AbsoluteError}(AbsoluteError(ε))

    # Generic constructor
    Inexact(error_spec::E) where {E<:ErrorSpec} = new{E}(error_spec)
end

# Convenient functions for checking exactness
is_exact(::Exact) = true
is_exact(::Inexact) = false

# Get error bound (may not be meaningful for Exact types)
error_bound(::Exact) = 0.0
error_bound(inexact::Inexact{AbsoluteError}) = inexact.error_spec.ε
error_bound(inexact::Inexact{RelativeError}) = inexact.error_spec.ε

# Check if error is relative
is_relative_error(::Exact) = false
is_relative_error(::Inexact{AbsoluteError}) = false
is_relative_error(::Inexact{RelativeError}) = true
