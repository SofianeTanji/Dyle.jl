module Argo

include("language/language.jl")
include("properties/property.jl")
include("oracles/oracle.jl")
include("templates/template.jl")
include("reformulations/reformulation.jl")

# Re-export modules for easier access
using .Language
using .Properties
using .Oracles
using .Templates
using .Reformulations

# Export module names
export Language, Properties, Oracles, Templates, Reformulations
end
