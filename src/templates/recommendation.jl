"""
    Templates.recommendation

Recommendation system for optimization methods based on template matching.
"""

"""
    evaluate_rate_bound(rate::ConvergenceRate, template::OptimizationTemplate,
                       mapping::Dict{Symbol,Symbol}, iteration::Int, initial_measure::Float64) -> Float64

Evaluate the bound provided by a convergence rate at a specific iteration.

# Arguments
- `rate::ConvergenceRate`: The convergence rate to evaluate
- `template::OptimizationTemplate`: The template containing function requirements
- `mapping::Dict{Symbol,Symbol}`: Mapping from template functions to expression functions
- `iteration::Int`: The iteration number to evaluate at
- `initial_measure::Float64`: The initial value of the convergence measure

# Returns
- The computed bound value
"""
function evaluate_rate_bound(
    rate::ConvergenceRate,
    template::OptimizationTemplate,
    mapping::Dict{Symbol,Symbol},
    iteration::Int,
    initial_measure::Float64 = 1.0,
)
    # Extract parameter values from the registered functions
    params = Dict{Symbol,Any}()

    for (param_name, (template_func, prop_param)) in rate.parameter_references
        # Find the corresponding expression function
        if !haskey(mapping, template_func)
            error("Template function $(template_func) not found in mapping")
        end

        expr_func = mapping[template_func]

        # Find the requirement to get the parameter reference
        func_req = nothing
        for req in template.function_requirements
            if req.name == template_func
                func_req = req
                break
            end
        end

        if func_req === nothing || !haskey(func_req.parameters, prop_param)
            error("Parameter $(prop_param) not found for function $(template_func)")
        end

        # Get the actual value from the property of the expression function
        # This would need implementation specific to each property type
        prop_value = get_property_parameter(expr_func, prop_param)

        params[param_name] = prop_value
    end

    # Evaluate the bound function with the parameters
    return rate.bound_function(iteration, initial_measure, params)
end

"""
    get_property_parameter(func::Symbol, param_name::Symbol) -> Any

Get a parameter value from a function's property.
This is a placeholder that would need to be implemented for each property type.

# Arguments
- `func::Symbol`: The function symbol
- `param_name::Symbol`: The parameter name to retrieve

# Returns
- The parameter value
"""
function get_property_parameter(func::Symbol, param_name::Symbol)
    # This is a placeholder implementation
    # In a real implementation, we would:
    # 1. Check which property has this parameter (e.g., Smooth has L)
    # 2. Get that property from the function
    # 3. Extract the parameter value

    if param_name == :L
        # Try to get smoothness parameter
        if has_property(func, Smooth)
            smooth_prop = get_property(func, Smooth)
            # Access L from the Smooth property
            return smooth_prop.L !== nothing ? smooth_prop.L.upper : 1.0
        end
    elseif param_name == :μ
        # Try to get strong convexity parameter
        if has_property(func, StronglyConvex)
            sc_prop = get_property(func, StronglyConvex)
            # Access μ from the StronglyConvex property
            return sc_prop.μ !== nothing ? sc_prop.μ.lower : 0.1
        end
    end

    # Default value if parameter not found
    return 1.0
end

"""
    compare_rates(rate1::ConvergenceRate, rate2::ConvergenceRate,
                 template::OptimizationTemplate, mapping::Dict{Symbol,Symbol}) -> Int

Compare two convergence rates to determine which is better.
Returns negative for rate1 better, positive for rate2 better, 0 for equivalent.

# Arguments
- `rate1::ConvergenceRate`: First convergence rate
- `rate2::ConvergenceRate`: Second convergence rate
- `template::OptimizationTemplate`: The template containing function requirements
- `mapping::Dict{Symbol,Symbol}`: Mapping from template functions to expression functions

# Returns
- Negative if rate1 is better, positive if rate2 is better, 0 if equivalent
"""
function compare_rates(
    rate1::ConvergenceRate,
    rate2::ConvergenceRate,
    template::OptimizationTemplate,
    mapping::Dict{Symbol,Symbol},
)
    # If measures are different, we can't directly compare
    if rate1.measure != rate2.measure
        # For this simple implementation, we prioritize certain measures
        measures_priority =
            Dict(SuboptimalityGap => 1, GradientNorm => 2, DistanceToOptimum => 3)

        return measures_priority[rate1.measure] - measures_priority[rate2.measure]
    end

    # For the same measure, compare asymptotic behavior first
    # This is a simplified comparison based on common rate patterns
    rate_patterns = Dict(
        r"O\(1/k\)" => 3,      # Sublinear: 1/k
        r"O\(1/k\^2\)" => 2,    # Accelerated: 1/k²
        r"O\(ρ\^k\)" => 1,       # Linear: ρᵏ
    )

    rate1_priority = 4  # Default (worse than all recognized patterns)
    rate2_priority = 4

    for (pattern, priority) in rate_patterns
        if occursin(pattern, rate1.asymptotic_notation)
            rate1_priority = priority
        end
        if occursin(pattern, rate2.asymptotic_notation)
            rate2_priority = priority
        end
    end

    if rate1_priority != rate2_priority
        return rate1_priority - rate2_priority
    end

    # If asymptotic behavior is the same, compare actual bounds at a reference point
    # For example, iteration 100
    bound1 = evaluate_rate_bound(rate1, template, mapping, 100)
    bound2 = evaluate_rate_bound(rate2, template, mapping, 100)

    # Lower bound is better
    if bound1 < bound2
        return -1
    elseif bound1 > bound2
        return 1
    else
        return 0
    end
end

"""
    rank_methods(expr::Expression, template_name::Symbol) -> Vector{Tuple{OptimizationMethod,ConvergenceRate}}

Rank the optimization methods for a specific template based on their convergence rates.

# Arguments
- `expr::Expression`: The expression to analyze
- `template_name::Symbol`: The template to use for ranking

# Returns
- Sorted vector of (method, rate) tuples from best to worst

# Examples
```julia
@variable x::R()
@func f
@property f Convex() Smooth(1.0)
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2*x)

ranked_methods = rank_methods(f(x), :smooth_minimization)
```
"""
function rank_methods(expr::Expression, template_name::Symbol)
    if !haskey(optimization_templates, template_name)
        error("Template '$(template_name)' does not exist.")
    end

    template = optimization_templates[template_name]

    # Check if the expression matches the template
    mapping = get_function_mapping(expr, template_name)
    if mapping === nothing
        error("Expression does not match template '$(template_name)'")
    end

    # Get the methods for this template
    methods = template.methods

    # If no methods, return empty list
    if isempty(methods)
        return Tuple{OptimizationMethod,ConvergenceRate}[]
    end

    # Sort methods by convergence rate (best first)
    sorted_methods =
        sort(methods, lt = (a, b) -> compare_rates(a[2], b[2], template, mapping) < 0)

    return sorted_methods
end

"""
    recommend_methods(expr::Expression) -> Dict{Symbol,Vector{Tuple{OptimizationMethod,ConvergenceRate}}}

Recommend optimization methods for a given expression based on all matching templates.

# Arguments
- `expr::Expression`: The expression to recommend methods for

# Returns
- Dictionary mapping template names to sorted lists of (method, rate) tuples

# Examples
```julia
@variable x::R()
@func f
@property f Convex() Smooth(1.0)
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2*x)

recommendations = recommend_methods(f(x))
```
"""
function recommend_methods(expr::Expression)
    # Find all matching templates
    matching_templates = find_matching_templates(expr)

    if isempty(matching_templates)
        return Dict{Symbol,Vector{Tuple{OptimizationMethod,ConvergenceRate}}}()
    end

    # Rank methods for each template
    recommendations = Dict{Symbol,Vector{Tuple{OptimizationMethod,ConvergenceRate}}}()

    for template_name in matching_templates
        recommendations[template_name] = rank_methods(expr, template_name)
    end

    return recommendations
end

"""
    print_recommendations(expr::Expression) -> Nothing

Print recommended optimization methods for an expression in a human-readable format.

# Arguments
- `expr::Expression`: The expression to recommend methods for

# Examples
```julia
@variable x::R()
@func f
@property f Convex() Smooth(1.0)
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2*x)

print_recommendations(f(x))
```
"""
function print_recommendations(expr::Expression)
    recommendations = recommend_methods(expr)

    if isempty(recommendations)
        println("No matching templates found for the given expression.")
        return
    end

    println("Recommended optimization methods:")
    for (template_name, methods) in recommendations
        template = optimization_templates[template_name]
        println("\nFrom template '$(template_name)' ($(template.description)):")

        if isempty(methods)
            println("  No methods registered for this template.")
            continue
        end

        for (i, (method, rate)) in enumerate(methods)
            println(
                "  $(i). $(method.name): $(rate.asymptotic_notation) convergence ($(rate.name))",
            )
            println("     $(method.description)")
            if !isempty(method.reference)
                println("     Reference: $(method.reference)")
            end

            # Print convergence measure
            measure_str = if rate.measure == SuboptimalityGap
                "function value gap"
            elseif rate.measure == GradientNorm
                "gradient norm"
            elseif rate.measure == DistanceToOptimum
                "distance to solution"
            end

            println("     Measures: $(measure_str)")

            # Print key conditions
            if !isempty(rate.conditions)
                cond_strs = ["$(k): $(v)" for (k, v) in rate.conditions]
                println("     Conditions: $(join(cond_strs, ", "))")
            end
        end
    end
end
