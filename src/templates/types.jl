"""
    Templates.types

Core type definitions for the Templates module.
"""

using ..Language
using ..Properties
using ..Oracles

"""
    ConvergenceMeasure

Enumeration of different measures for convergence in optimization.

# Values
- `SuboptimalityGap`: Measures the distance to optimality in function value (f(x_k) - f*)
- `GradientNorm`: Measures the norm of the gradient (‖∇f(x_k)‖)
- `DistanceToOptimum`: Measures the distance to the optimal solution (‖x_k - x*‖)
"""
@enum ConvergenceMeasure begin
    SuboptimalityGap   # f(x_k) - f*
    GradientNorm       # ||∇f(x_k)||
    DistanceToOptimum  # ||x_k - x*||
end

"""
    TemplateFunctionRequirement

Structure specifying the required properties and oracles for a function in a template.

# Fields
- `name::Symbol`: The function name
- `description::String`: Description of the function's role in the template
- `required_properties::Vector{DataType}`: Required property types
- `required_oracles::Vector{DataType}`: Required oracle types
- `parameters::Dict{Symbol,Any}`: Associated parameters (e.g., smoothness constant)
"""
struct TemplateFunctionRequirement
    name::Symbol  # Function name
    description::String
    required_properties::Vector{DataType}  # Required property types
    required_oracles::Vector{DataType}     # Required oracle types
    parameters::Dict{Symbol,Any}           # Associated parameters
end

"""
    OptimizationMethod

Structure representing an optimization algorithm or method.

# Fields
- `name::String`: The name of the method (e.g., "Gradient Descent")
- `description::String`: A description of the method
- `reference::String`: Reference to a paper or book describing the method
"""
struct OptimizationMethod
    name::String
    description::String
    reference::String  # Paper or book reference
end

"""
    ConvergenceRate

Structure representing the convergence rate of an optimization method.

# Fields
- `name::String`: The name of the rate (e.g., "Linear", "Sublinear")
- `description::String`: A description of the convergence rate
- `measure::ConvergenceMeasure`: The measure used for convergence
- `bound_function::Function`: Function computing the upper bound on the convergence measure
- `asymptotic_notation::String`: Asymptotic bound in big-O notation (e.g., "O(1/k)", "O(ρᵏ)")
- `parameter_references::Dict{Symbol,Tuple{Symbol,Symbol}}`: References to template parameters (func_name, param_name)
- `conditions::Dict{Symbol,Any}`: Conditions for the rate to hold (e.g., step size choice)
"""
struct ConvergenceRate
    name::String
    description::String
    measure::ConvergenceMeasure
    bound_function::Function                          # (k, initial_measure, params) -> bound_value
    asymptotic_notation::String                       # e.g., "O(1/k)", "O(1/k²)", "O(ρᵏ)"
    parameter_references::Dict{Symbol,Tuple{Symbol,Symbol}}  # param_name => (func_name, param_name)
    conditions::Dict{Symbol,Any}                      # Conditions for the rate to hold
end

"""
    OptimizationTemplate

Structure representing a template for an optimization problem.

Templates match specific problem structures to applicable optimization methods
and their convergence rates.

# Fields
- `name::Symbol`: The name of the template (e.g., `:smooth_minimization`)
- `description::String`: A description of the template
- `expression::Expression`: The expression pattern for the template
- `function_requirements::Vector{TemplateFunctionRequirement}`: Required properties for functions
- `methods::Vector{Tuple{OptimizationMethod,ConvergenceRate}}`: Applicable methods and their rates
- `assumptions::Dict{Symbol,Any}`: Additional assumptions for this template
"""
struct OptimizationTemplate
    name::Symbol
    description::String
    expression::Expression
    function_requirements::Vector{TemplateFunctionRequirement}
    methods::Vector{Tuple{OptimizationMethod,ConvergenceRate}}
    assumptions::Dict{Symbol,Any}  # Additional assumptions for this template
end

# Constructor with empty methods
function OptimizationTemplate(
    name::Symbol,
    description::String,
    expression::Expression,
    function_requirements::Vector{TemplateFunctionRequirement},
    assumptions::Dict{Symbol,Any} = Dict{Symbol,Any}(),
)
    return OptimizationTemplate(
        name,
        description,
        expression,
        function_requirements,
        Tuple{OptimizationMethod,ConvergenceRate}[],
        assumptions,
    )
end
