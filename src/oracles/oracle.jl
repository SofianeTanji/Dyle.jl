module Oracles

using ..Language
using ..Properties

include("types.jl")
include("registry.jl")
include("combinations.jl")
include("macros.jl")
include("specials.jl")

# === PUBLIC API === #
export Oracle,
    EvaluationOracle,
    DerivativeOracle,
    ProximalOracle,
    LinearMinimizationOracle,
    ConjugateEvaluationOracle

# Registry functions
export register_oracle!, get_oracle, has_oracle, clear_oracles!

# Combination functions
export get_oracle_for_expression
export register_special_combination, has_special_combination, get_special_combination

# DSL macros
export @oracle, @oracles, @clear_oracles

# Initialize special functions
function __init__()
    register_special_functions()
end

end
