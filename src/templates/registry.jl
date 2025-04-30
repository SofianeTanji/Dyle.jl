"""
    Templates.registry

Registry system for templates and methods in Dyle.jl.
"""

# Dictionary to store all registered templates
const optimization_templates = Dict{Symbol,OptimizationTemplate}()

"""
    register_template(name::Symbol, expression::Expression, description::String = "";
                     function_requirements::Vector{TemplateFunctionRequirement} = TemplateFunctionRequirement[],
                     assumptions::Dict{Symbol,Any} = Dict{Symbol,Any}()) -> OptimizationTemplate

Register an optimization template.

# Arguments
- `name::Symbol`: The name of the template (e.g., `:smooth_minimization`)
- `expression::Expression`: The expression pattern for the template
- `description::String`: A description of the template (optional)
- `function_requirements::Vector{TemplateFunctionRequirement}`: Required properties for functions (optional)
- `assumptions::Dict{Symbol,Any}`: Additional assumptions for this template (optional)

# Returns
- The created `OptimizationTemplate` object

# Examples
```julia
template = register_template(
    :smooth_minimization,
    f(x),
    "Minimization of a smooth convex function",
    function_requirements = [
        require_function(
            :f,
            "Smooth convex function",
            [Convex, Smooth],
            [EvaluationOracle, DerivativeOracle],
            Dict(:L => 1.0)
        )
    ]
)
```
"""
function register_template(
    name::Symbol,
    expression::Expression,
    description::String = "";
    function_requirements::Vector{TemplateFunctionRequirement} = TemplateFunctionRequirement[],
    assumptions::Dict{Symbol,Any} = Dict{Symbol,Any}(),
)
    if haskey(optimization_templates, name)
        error(
            "Template '$(name)' already exists. Use a different name or update the existing template.",
        )
    end

    # Create a new template without any methods initially
    template = OptimizationTemplate(
        name,
        description,
        expression,
        function_requirements,
        assumptions,
    )

    optimization_templates[name] = template
    return template
end

"""
    require_function(name::Symbol, description::String = "",
                   properties::Vector{DataType} = DataType[],
                   oracles::Vector{DataType} = DataType[],
                   parameters::Dict{Symbol,Any} = Dict{Symbol,Any}()) -> TemplateFunctionRequirement

Create a template function requirement specification.

# Arguments
- `name::Symbol`: The function name in the template
- `description::String`: Description of the function's role (optional)
- `properties::Vector{DataType}`: Required property types for the function (optional)
- `oracles::Vector{DataType}`: Required oracle types for the function (optional)
- `parameters::Dict{Symbol,Any}`: Parameters associated with the function (optional)

# Returns
- A `TemplateFunctionRequirement` object

# Examples
```julia
props = require_function(
    :f,
    "Smooth convex objective function",
    [Convex, Smooth],
    [EvaluationOracle, DerivativeOracle],
    Dict(:L => 1.0)
)
```
"""
function require_function(
    name::Symbol,
    description::String = "",
    properties::Vector{DataType} = DataType[],
    oracles::Vector{DataType} = DataType[],
    parameters::Dict{Symbol,Any} = Dict{Symbol,Any}(),
)
    return TemplateFunctionRequirement(name, description, properties, oracles, parameters)
end

"""
    create_method(name::String, description::String = "";
                 reference::String = "") -> OptimizationMethod

Create an optimization method object.

# Arguments
- `name::String`: The name of the method (e.g., "Gradient Descent")
- `description::String`: A description of the method (optional)
- `reference::String`: Reference to a paper or book (optional)

# Returns
- An `OptimizationMethod` object

# Examples
```julia
method = create_method(
    "Gradient Descent",
    "First-order method using gradients",
    reference = "Nesterov, Y. (2004). Introductory Lectures on Convex Optimization."
)
```
"""
function create_method(name::String, description::String = ""; reference::String = "")
    return OptimizationMethod(name, description, reference)
end

"""
    create_rate(name::String, description::String, measure::ConvergenceMeasure,
               bound_function::Function, asymptotic_notation::String;
               parameter_references::Dict{Symbol,Tuple{Symbol,Symbol}} = Dict{Symbol,Tuple{Symbol,Symbol}}(),
               conditions::Dict{Symbol,Any} = Dict{Symbol,Any}()) -> ConvergenceRate

Create a convergence rate object for an optimization method.

# Arguments
- `name::String`: The name of the rate (e.g., "Linear", "Sublinear")
- `description::String`: A description of the convergence rate
- `measure::ConvergenceMeasure`: The measure used for convergence
- `bound_function::Function`: Function computing the upper bound on the convergence measure
- `asymptotic_notation::String`: Asymptotic bound in big-O notation (e.g., "O(1/k)", "O(ρᵏ)")
- `parameter_references::Dict{Symbol,Tuple{Symbol,Symbol}}`: References to template parameters (optional)
- `conditions::Dict{Symbol,Any}`: Conditions for the rate to hold (optional)

# Returns
- A `ConvergenceRate` object

# Examples
```julia
rate = create_rate(
    "Sublinear",
    "Sublinear convergence for gradient descent",
    SuboptimalityGap,
    (k, initial_gap, params) -> (params[:L] / (2 * k)) * initial_gap,
    "O(1/k)",
    parameter_references = Dict(:L => (:f, :L)),
    conditions = Dict(:step_size => "1/L")
)
```
"""
function create_rate(
    name::String,
    description::String,
    measure::ConvergenceMeasure,
    bound_function::Function,
    asymptotic_notation::String;
    parameter_references::Dict{Symbol,Tuple{Symbol,Symbol}} = Dict{
        Symbol,
        Tuple{Symbol,Symbol},
    }(),
    conditions::Dict{Symbol,Any} = Dict{Symbol,Any}(),
)
    return ConvergenceRate(
        name,
        description,
        measure,
        bound_function,
        asymptotic_notation,
        parameter_references,
        conditions,
    )
end

"""
    add_method_to_template(template_name::Symbol, method::OptimizationMethod,
                          rate::ConvergenceRate) -> OptimizationTemplate

Add an optimization method and its convergence rate to a template.

# Arguments
- `template_name::Symbol`: The name of the template to add to
- `method::OptimizationMethod`: The optimization method to add
- `rate::ConvergenceRate`: The convergence rate of the method

# Returns
- The updated `OptimizationTemplate` object

# Examples
```julia
add_method_to_template(
    :smooth_minimization,
    create_method("Gradient Descent", "Standard gradient descent"),
    create_rate("Sublinear", "Sublinear convergence", SuboptimalityGap, bound_func, "O(1/k)")
)
```
"""
function add_method_to_template(
    template_name::Symbol,
    method::OptimizationMethod,
    rate::ConvergenceRate,
)
    if !haskey(optimization_templates, template_name)
        error("Template '$(template_name)' does not exist.")
    end

    template = optimization_templates[template_name]

    # Check if the method already exists with the SAME performance measure
    for (existing_method, existing_rate) in template.methods
        if existing_method.name == method.name && existing_rate.measure == rate.measure
            error(
                "Method '$(method.name)' with measure '$(rate.measure)' already exists for template '$(template_name)'.",
            )
        end
    end

    # Add the method and rate to the template
    methods = copy(template.methods)
    push!(methods, (method, rate))

    # Create an updated template
    updated_template = OptimizationTemplate(
        template.name,
        template.description,
        template.expression,
        template.function_requirements,
        methods,
        template.assumptions,
    )

    optimization_templates[template_name] = updated_template
    return updated_template
end

"""
    get_template(name::Symbol) -> OptimizationTemplate

Get a specific template by name.

# Arguments
- `name::Symbol`: The name of the template to retrieve

# Returns
- The requested `OptimizationTemplate` object

# Throws
- Error if the template does not exist

# Examples
```julia
template = get_template(:smooth_minimization)
```
"""
function get_template(name::Symbol)
    if !haskey(optimization_templates, name)
        error("Template '$(name)' does not exist.")
    end
    return optimization_templates[name]
end

"""
    list_templates() -> Nothing

List all available optimization templates.

# Examples
```julia
list_templates()
```
"""
function list_templates()
    if isempty(optimization_templates)
        println("No templates registered.")
    else
        println("Available optimization templates:")
        for (name, template) in optimization_templates
            println("  - $(name): $(template.description)")
        end
    end
end

"""
    template_details(name::Symbol)

Fetches the `OptimizationTemplate` registered under `name`,
prints its components (description, pattern, requirements, methods, assumptions)
and returns the template object.
"""
function template_details(name::Symbol)
    tmpl = get_template(name)  # this is your registry lookup
    println("Template: ", tmpl.name)
    println("  Description: ", tmpl.description)
    println("  Pattern:    ", tmpl.expression)
    println("  Requirements:")
    for req in tmpl.function_requirements
        println(
            "    • func=$(req.name), props=$(req.required_properties), oracles=$(req.required_oracles), params=$(req.parameters)",
        )
    end
    println("  Methods:")
    for m in tmpl.methods
        @show m
        println("    • ", m[1].name, ": ", m[1].description)
    end
    println("  Assumptions: ", tmpl.assumptions)
    return tmpl
end
