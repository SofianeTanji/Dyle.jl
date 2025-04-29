abstract type Oracle end

"""
EvaluationOracle <: Oracle

Represents the ability to evaluate a function at a point.
Function signature for implementations: f(x) -> y
"""
struct EvaluationOracle <: Oracle end

"""
DerivativeOracle <: Oracle

Represents the ability to compute derivatives (gradient, subgradient, etc.) of a function.
Function signature for implementations: f(x) -> ∇f(x)
"""
struct DerivativeOracle <: Oracle end

"""
ProximalOracle <: Oracle

Represents the ability to compute the proximal operator of a function.
Function signature for implementations: f(x, λ) -> prox_λf(x)
    where prox_λf(x) = argmin_y { f(y) + (1/2λ)‖y-x‖² }
"""
struct ProximalOracle <: Oracle end

"""
LinearMinimizationOracle <: Oracle

Represents the ability to minimize a linear function over the domain of another function.
Function signature for implementations: f(direction) -> argmin_x { <direction, x> | x ∈ dom(f) }
"""
struct LinearMinimizationOracle <: Oracle end

"""
ConjugateEvaluationOracle <: Oracle

Represents the ability to evaluate the Fenchel conjugate of a function.
Function signature for implementations: f(y) -> f*(y) = max_x { <x, y> - f(x) }
"""
struct ConjugateEvaluationOracle <: Oracle end
