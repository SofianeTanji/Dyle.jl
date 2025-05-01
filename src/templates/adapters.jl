"""
    Templates.Adapters

Contains adapter modules to provide clean interfaces between Templates and other modules.
"""
module Adapters

include("adapters/property_adapter.jl")
include("adapters/oracle_adapter.jl")

# Export the adapter modules
export PropertyAdapter, OracleAdapter

end # module
