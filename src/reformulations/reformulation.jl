module Reformulations

import Base: ==, hash

using ..Language
using ..Properties
using ..Oracles

include("types.jl")
include("strategies/registry.jl")
include("strategies/rebalancing.jl")

# === PUBLIC API === #
# Types
export Reformulation, Strategy, create_reformulation

# Registration functions
export register_strategy, list_strategies, clear_strategies

# Main functions
export generate_reformulations, apply_strategy, apply_all_strategies

end
