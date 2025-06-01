module Argo

include("language/language.jl")
include("properties/property.jl")
include("oracles/oracle.jl")
include("special_functions/special_functions.jl")
include("templates/template.jl")
include("reformulations/reformulation.jl")  # include reformulations and strategy registry

# Re-export modules for easier access
using .Language
using .Properties
using .Oracles
using .SpecialFunctions
using .Templates
using .Reformulations  # includes register_strategy, get_strategy, list_strategies, apply_strategy

# Export module names
export Language, Properties, Oracles, SpecialFunctions, Templates, Reformulations  # added Reformulations
export register_strategy,
    get_strategy, list_strategies, apply_strategy, generate_reformulations  # re-export strategy API at top level
end
