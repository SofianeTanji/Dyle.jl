"""
    Oracles

This module provides computational access to mathematical functions through oracles.
An oracle represents a specific computational capability like evaluation, derivatives, or proximal operators.
"""
module Oracles

using ..Language

# Include all component files
include("exactness.jl")
include("cost_models.jl")
include("metadata.jl")
include("types.jl")
# Load oracle combination logic before registry so registry can reference it
include("combinations.jl")
include("registry.jl")
include("specials.jl")
include("macros.jl")

# ===== Exports =====

# Exactness types
export Exactness, Exact, AbsoluteError, RelativeError
export error_bound, is_relative_error

# Cost model
export CostModel, ConstantCost, DimensionalCost
export evaluate_cost
export constant_cost, linear_cost, quadratic_cost, cubic_cost

# Oracle types
export Oracle, EvaluationOracle, DerivativeOracle, ProximalOracle

# Registry functions
export register_oracle!, get_oracle, has_oracle, clear_oracles!

# Combination functions
export get_oracle_for_expression
export register_special_combination, has_special_combination, get_special_combination

# Macros
export @oracle, @oracles, @clear_oracles

# Initialize when the module is loaded
function __init__()
    # Initialize any necessary state or register standard functions
    register_special_functions()
    return register_special_combinations()
end

end
