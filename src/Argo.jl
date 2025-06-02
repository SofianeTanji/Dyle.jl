module Argo

include("language/language.jl")
include("properties/property.jl")
include("oracles/oracle.jl")
include("special_functions/special_functions.jl")
include("templates/template.jl")
include("database/database.jl")
include("reformulations/reformulation.jl")  # include reformulations and strategy registry

# Re-export modules for easier access
using .Language
using .Properties
using .Oracles
using .SpecialFunctions
using .Templates
using .Database
using .Reformulations  # includes register_strategy, get_strategy, list_strategies, apply_strategy

# Export module names
export Language, Properties, Oracles, SpecialFunctions, Templates, Database, Reformulations  # added Reformulations
export register_strategy,
    get_strategy, list_strategies, apply_strategy, generate_reformulations  # re-export strategy API at top level
export DATABASE,
    get_rates_by_template,
    get_rates_by_method,
    get_all_rates,
    get_rates,
    list_templates,
    list_methods,
    list_measures,
    NotFoundError
end
