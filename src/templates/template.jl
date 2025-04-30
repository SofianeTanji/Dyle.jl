module Templates
using ..Language
using ..Properties
using ..Oracles

include("types.jl")
include("registry.jl")
include("matching.jl")
include("recommendation.jl")
include("macros.jl")

# === PUBLIC API === #

# Types
export ConvergenceMeasure, SuboptimalityGap, GradientNorm, DistanceToOptimum
export TemplateFunctionRequirement,
    OptimizationMethod, ConvergenceRate, OptimizationTemplate

# Registry functions
export register_template, require_function, create_method, create_rate
export add_method_to_template, get_template, list_templates, template_details

# Matching functions
export matches_template, find_matching_templates, get_function_mapping

# Recommendation functions
export recommend_methods, print_recommendations, rank_methods

# Macros
export @template, @require_function, @add_requirements
export @method, @rate, @add_method
export @template_details, @find_templates, @recommend

end
