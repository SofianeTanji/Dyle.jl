"""
    Oracles

This module provides a system for representing and computing with oracles.

An oracle represents a computational capability of a function, such as:
- Evaluation: Computing f(x)
- Gradient/Derivative: Computing ∇f(x)
- Proximal: Computing prox_λf(x) = argmin_y { f(y) + (1/2λ)‖y-x‖² }

The module includes:
- A type system for different oracle types
- Error bounds and inexactness modeling
- Cost models for computational complexity
- A registry system for associating oracles with functions
- Combination rules for composite expressions
- Metadata tracking for oracle properties
"""

module Oracles

using ..Language
using ..Properties
# Exactness types
include("exactness.jl")
export Exactness, Exact, Inexact, AbsoluteError, RelativeError
export is_exact, error_bound, is_relative_error

# Cost model system
include("cost_models.jl")
export CostModel, ConstantCost, DimensionalCost, CompositeCost
export evaluate_cost
export constant_cost, linear_cost, quadratic_cost, cubic_cost, exponential_cost

# Oracle metadata system
include("metadata.jl")
export OracleMetadata
export register_oracle_metadata!, get_oracle_metadata, has_oracle_metadata
export clear_oracle_metadata!, clear_all_oracle_metadata!
export get_metadata_for_expression

# Oracle types
include("types.jl")
export Oracle
export EvaluationOracle, DerivativeOracle, ProximalOracle
export LinearMinimizationOracle, ConjugateEvaluationOracle
export StochasticGradientOracle, CoordinateGradientOracle
export is_exact, exactness_type, oracle_type

# Type aliases for common oracle variants
export ExactEvaluationOracle, ExactDerivativeOracle, ExactProximalOracle
export ExactLinearMinimizationOracle, ExactConjugateEvaluationOracle
export ExactStochasticGradientOracle, ExactCoordinateGradientOracle
export InexactEvaluationOracle, InexactDerivativeOracle, InexactProximalOracle
export InexactLinearMinimizationOracle, InexactConjugateEvaluationOracle
export InexactStochasticGradientOracle, InexactCoordinateGradientOracle

# For compatibility with existing code
export SimpleEvaluationOracle, SimpleDerivativeOracle, SimpleProximalOracle
export SimpleLinearMinimizationOracle, SimpleConjugateEvaluationOracle

# Registry functions
include("registry.jl")
export register_oracle!, register_oracle_type!, get_oracle, has_oracle, clear_oracles!

# Combination functions
include("combinations.jl")
export get_oracle_for_expression
export register_special_combination, has_special_combination, get_special_combination

# Special oracle implementations
include("specials.jl")
export register_special_functions, register_special_combinations

# DSL macros
include("macros.jl")
export @oracle, @oracles, @clear_oracles

# Initialize special functions when the module is loaded
function __init__()
    register_special_functions()
    register_special_combinations()
end

end
