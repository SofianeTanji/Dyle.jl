"""
    Templates.macros

Macro interface for template and method definition in Dyle.jl.
"""

"""
    @template(name, description, expr)

Macro for defining optimization templates.

# Arguments
- `name`: Symbol representing the template name
- `description`: String describing the template
- `expr`: Expression pattern for the template

# Examples
```julia
@variable x::R()
@func f

@template(:smooth_convex_min, "Smooth convex minimization", f(x))
```
"""
macro template(name, description, expr)
    return quote
        register_template($(esc(name)), $(esc(expr)), $(esc(description)))
    end
end

"""
    @require_function(func_name, description, properties, oracles, parameters)

Macro for defining function requirements in templates.

# Arguments
- `func_name`: Symbol representing the function name
- `description`: String describing the function's role
- `properties`: Vector of required property types
- `oracles`: Vector of required oracle types
- `parameters`: Dictionary of parameters associated with the function

# Examples
```julia
req = @require_function(
    :f,
    "Objective function",
    [Convex, Smooth],
    [EvaluationOracle, DerivativeOracle],
    Dict(:L => 1.0)
)
```
"""
macro require_function(
    func_name,
    description,
    properties,
    oracles,
    parameters = :(Dict{Symbol,Any}()),
)
    return quote
        require_function(
            $(esc(func_name)),
            $(esc(description)),
            $(esc(properties)),
            $(esc(oracles)),
            $(esc(parameters)),
        )
    end
end

"""
    @add_requirements(template_name, requirements...)

Macro for adding function requirements to a template.

# Arguments
- `template_name`: Symbol representing the template name
- `requirements...`: TemplateFunctionRequirement objects to add

# Examples
```julia
@add_requirements(
    :smooth_convex_min,
    @require_function(:f, "Objective function", [Convex, Smooth], [EvaluationOracle, DerivativeOracle])
)
```
"""
macro add_requirements(template_name, requirements...)
    reqs_expr = Expr(:vect)
    for req in requirements
        push!(reqs_expr.args, esc(req))
    end

    return quote
        # Get the template
        template = get_template($(esc(template_name)))

        # Create a new template with the additional requirements
        updated_template = OptimizationTemplate(
            template.name,
            template.description,
            template.expression,
            vcat(template.function_requirements, $(reqs_expr)),
            template.methods,
            template.assumptions,
        )

        # Update the registry
        optimization_templates[template.name] = updated_template
        updated_template
    end
end

"""
    @method(name, description, template_name, reference="")

Macro for creating an optimization method.

# Arguments
- `name`: String representing the method name
- `description`: String describing the method
- `template_name`: Symbol representing the template to add the method to
- `reference`: Optional reference string

# Examples
```julia
@method("Gradient Descent", "First-order method using gradients", :smooth_convex_min)
```
"""
macro method(name, description, template_name, reference = "")
    return quote
        create_method($(esc(name)), $(esc(description)), reference = $(esc(reference)))
    end
end

"""
    @rate(name, description, measure, bound_func, asymptotic, parameter_refs={}, conditions={})

Macro for creating a convergence rate.

# Arguments
- `name`: String representing the rate name
- `description`: String describing the rate
- `measure`: ConvergenceMeasure enum value
- `bound_func`: Function computing the bound
- `asymptotic`: String representing asymptotic notation
- `parameter_refs`: Dictionary mapping parameter names to (function, property parameter) tuples
- `conditions`: Dictionary of conditions for the rate to hold

# Examples
```julia
@rate(
    "Sublinear",
    "Sublinear 1/k convergence",
    SuboptimalityGap,
    (k, initial, params) -> params[:L]/(2*k) * initial,
    "O(1/k)",
    Dict(:L => (:f, :L)),
    Dict(:step_size => "1/L")
)
```
"""
macro rate(
    name,
    description,
    measure,
    bound_func,
    asymptotic,
    parameter_refs = :(Dict{Symbol,Tuple{Symbol,Symbol}}()),
    conditions = :(Dict{Symbol,Any}()),
)
    return quote
        create_rate(
            $(esc(name)),
            $(esc(description)),
            $(esc(measure)),
            $(esc(bound_func)),
            $(esc(asymptotic)),
            parameter_references = $(esc(parameter_refs)),
            conditions = $(esc(conditions)),
        )
    end
end

"""
    @add_method(template_name, method, rate)

Macro for adding a method with its convergence rate to a template.

# Arguments
- `template_name`: Symbol representing the template name
- `method`: OptimizationMethod object or macro call to @method
- `rate`: ConvergenceRate object or macro call to @rate

# Examples
```julia
@add_method(
    :smooth_convex_min,
    @method("Gradient Descent", "Standard gradient descent", :smooth_convex_min),
    @rate(
        "Sublinear",
        "Sublinear 1/k convergence",
        SuboptimalityGap,
        (k, initial, params) -> params[:L]/(2*k) * initial,
        "O(1/k)",
        Dict(:L => (:f, :L)),
        Dict(:step_size => "1/L")
    )
)
```
"""
macro add_method(template_name, method, rate)
    return quote
        add_method_to_template($(esc(template_name)), $(esc(method)), $(esc(rate)))
    end
end

"""
    @template_details(name)

Macro for printing detailed information about a template.

# Arguments
- `name`: Symbol representing the template name

# Examples
```julia
@template_details(:smooth_convex_min)
```
"""
macro template_details(name)
    return quote
        template_details($(esc(name)))
    end
end

"""
    @find_templates(expr)

Macro for finding templates that match an expression.

# Arguments
- `expr`: Expression to match against templates

# Examples
```julia
@variable x::R()
@func f
templates = @find_templates(f(x))
```
"""
macro find_templates(expr)
    return quote
        find_matching_templates($(esc(expr)))
    end
end

"""
    @recommend(expr)

Macro for printing optimization method recommendations for an expression.

# Arguments
- `expr`: Expression to recommend methods for

# Examples
```julia
@variable x::R()
@func f
@recommend(f(x))
```
"""
macro recommend(expr)
    return quote
        print_recommendations($(esc(expr)))
    end
end
