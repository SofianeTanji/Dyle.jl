"""
    Oracle{E<:Exactness}

Abstract type for all oracles, representing computational capabilities of functions.

Type parameter E specifies the exactness model (Exact or Inexact).
"""
abstract type Oracle{E<:Exactness} end

"""
    extract_oracle_type(oracle_type)

Extract the base oracle type from a parameterized type, instance, or type alias.
This handles all forms of oracle types consistently.

# Arguments
- `oracle_type`: The oracle type or instance to extract the base type from

# Returns
- The base oracle type (DataType)
"""
function extract_oracle_type(oracle_type)
    # Define a mapping from any oracle type to its base type
    oracle_types = Dict{Symbol,DataType}(
        :EvaluationOracle => EvaluationOracle,
        :DerivativeOracle => DerivativeOracle,
        :ProximalOracle => ProximalOracle,
        :LinearMinimizationOracle => LinearMinimizationOracle,
        :ConjugateEvaluationOracle => ConjugateEvaluationOracle,
        :StochasticGradientOracle => StochasticGradientOracle,
        :CoordinateGradientOracle => CoordinateGradientOracle,
    )

    # Helper function to extract the base name of a type
    function get_type_name(t)
        if t isa DataType
            return Symbol(t.name.name)
        elseif t isa UnionAll
            return Symbol(t.body.name.name)
        else
            return nothing
        end
    end

    if oracle_type isa Oracle
        # Handle oracle instance
        type_name = get_type_name(typeof(oracle_type))
        if type_name !== nothing && haskey(oracle_types, type_name)
            return oracle_types[type_name]
        end
    elseif isa(oracle_type, Type)
        # Handle type
        type_name = get_type_name(oracle_type)
        if type_name !== nothing && haskey(oracle_types, type_name)
            return oracle_types[type_name]
        end
    end

    # Fall back to the original type if we can't extract it
    return oracle_type
end

"""
    EvaluationOracle{E<:Exactness} <: Oracle{E}

Represents the ability to evaluate a function at a point.
Function signature for implementations: f(x) -> y

Type parameter E specifies the exactness model.
"""
struct EvaluationOracle{E<:Exactness} <: Oracle{E}
    exactness::E

    # Default constructor for exact oracle
    EvaluationOracle() = new{Exact}(Exact())

    # Constructor with explicit exactness
    EvaluationOracle(exactness::E) where {E<:Exactness} = new{E}(exactness)
end

"""
    DerivativeOracle{E<:Exactness} <: Oracle{E}

Represents the ability to compute derivatives (gradient, subgradient, etc.) of a function.
Function signature for implementations: f(x) -> ∇f(x)

Type parameter E specifies the exactness model.
"""
struct DerivativeOracle{E<:Exactness} <: Oracle{E}
    exactness::E

    # Default constructor for exact oracle
    DerivativeOracle() = new{Exact}(Exact())

    # Constructor with explicit exactness
    DerivativeOracle(exactness::E) where {E<:Exactness} = new{E}(exactness)
end

"""
    ProximalOracle{E<:Exactness} <: Oracle{E}

Represents the ability to compute the proximal operator of a function.
Function signature for implementations: f(x, λ) -> prox_λf(x)
    where prox_λf(x) = argmin_y { f(y) + (1/2λ)‖y-x‖² }

Type parameter E specifies the exactness model.
"""
struct ProximalOracle{E<:Exactness} <: Oracle{E}
    exactness::E

    # Default constructor for exact oracle
    ProximalOracle() = new{Exact}(Exact())

    # Constructor with explicit exactness
    ProximalOracle(exactness::E) where {E<:Exactness} = new{E}(exactness)
end

"""
    LinearMinimizationOracle{E<:Exactness} <: Oracle{E}

Represents the ability to minimize a linear function over the domain of another function.
Function signature for implementations: f(direction) -> argmin_x { <direction, x> | x ∈ dom(f) }

Type parameter E specifies the exactness model.
"""
struct LinearMinimizationOracle{E<:Exactness} <: Oracle{E}
    exactness::E

    # Default constructor for exact oracle
    LinearMinimizationOracle() = new{Exact}(Exact())

    # Constructor with explicit exactness
    LinearMinimizationOracle(exactness::E) where {E<:Exactness} = new{E}(exactness)
end

"""
    ConjugateEvaluationOracle{E<:Exactness} <: Oracle{E}

Represents the ability to evaluate the Fenchel conjugate of a function.
Function signature for implementations: f(y) -> f*(y) = max_x { <x, y> - f(x) }

Type parameter E specifies the exactness model.
"""
struct ConjugateEvaluationOracle{E<:Exactness} <: Oracle{E}
    exactness::E

    # Default constructor for exact oracle
    ConjugateEvaluationOracle() = new{Exact}(Exact())

    # Constructor with explicit exactness
    ConjugateEvaluationOracle(exactness::E) where {E<:Exactness} = new{E}(exactness)
end

"""
    StochasticGradientOracle{E<:Exactness} <: Oracle{E}

Represents the ability to compute a stochastic gradient of a function.
Function signature for implementations: f(x, ξ) -> ∇f(x, ξ)
    where ξ is a random variable.

Type parameter E specifies the exactness model.
"""
struct StochasticGradientOracle{E<:Exactness} <: Oracle{E}
    exactness::E

    # Default constructor for exact oracle
    StochasticGradientOracle() = new{Exact}(Exact())

    # Constructor with explicit exactness
    StochasticGradientOracle(exactness::E) where {E<:Exactness} = new{E}(exactness)
end

"""
    CoordinateGradientOracle{E<:Exactness} <: Oracle{E}

Represents the ability to compute the gradient of a function with respect to a single coordinate.
Function signature for implementations: f(x, i) -> ∂f(x)/∂x_i

Type parameter E specifies the exactness model.
"""
struct CoordinateGradientOracle{E<:Exactness} <: Oracle{E}
    exactness::E

    # Default constructor for exact oracle
    CoordinateGradientOracle() = new{Exact}(Exact())

    # Constructor with explicit exactness
    CoordinateGradientOracle(exactness::E) where {E<:Exactness} = new{E}(exactness)
end

# Type aliases for common oracle variants
const ExactEvaluationOracle = EvaluationOracle{Exact}
const ExactDerivativeOracle = DerivativeOracle{Exact}
const ExactProximalOracle = ProximalOracle{Exact}
const ExactLinearMinimizationOracle = LinearMinimizationOracle{Exact}
const ExactConjugateEvaluationOracle = ConjugateEvaluationOracle{Exact}
const ExactStochasticGradientOracle = StochasticGradientOracle{Exact}
const ExactCoordinateGradientOracle = CoordinateGradientOracle{Exact}

# Type aliases for inexact oracles with absolute error
const InexactEvaluationOracle = EvaluationOracle{Inexact{AbsoluteError}}
const InexactDerivativeOracle = DerivativeOracle{Inexact{AbsoluteError}}
const InexactProximalOracle = ProximalOracle{Inexact{AbsoluteError}}
const InexactLinearMinimizationOracle = LinearMinimizationOracle{Inexact{AbsoluteError}}
const InexactConjugateEvaluationOracle = ConjugateEvaluationOracle{Inexact{AbsoluteError}}
const InexactStochasticGradientOracle = StochasticGradientOracle{Inexact{AbsoluteError}}
const InexactCoordinateGradientOracle = CoordinateGradientOracle{Inexact{AbsoluteError}}

# Utility functions for oracle types
is_exact(::Oracle{Exact}) = true
is_exact(::Oracle{<:Inexact}) = false

# Get the exactness type parameter
exactness_type(::Type{<:Oracle{E}}) where {E<:Exactness} = E
exactness_type(::Oracle{E}) where {E<:Exactness} = E

# Get the oracle type without exactness parameter
oracle_type(::Type{O}) where {O<:Oracle} = extract_oracle_type(O)
oracle_type(::O) where {O<:Oracle} = oracle_type(O)

# Backward compatibility for non-parameterized oracle types
# These are needed for compatibility with existing code
const SimpleEvaluationOracle = EvaluationOracle{Exact}
const SimpleDerivativeOracle = DerivativeOracle{Exact}
const SimpleProximalOracle = ProximalOracle{Exact}
const SimpleLinearMinimizationOracle = LinearMinimizationOracle{Exact}
const SimpleConjugateEvaluationOracle = ConjugateEvaluationOracle{Exact}
