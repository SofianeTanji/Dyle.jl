"""
    Templates.matching

Template matching system for Argo.jl.
This module provides functions to match expressions against templates.
"""

"""
    extract_functions(expr::Expression) -> Vector{Symbol}

Extract all function symbols used in an expression.

# Arguments
- `expr::Expression`: The expression to analyze

# Returns
- Vector of function symbols used in the expression

# Examples
```julia
@variable x::R() y::R()
@func f g
funcs = extract_functions(f(x) + g(y))  # Returns [:f, :g]
```
"""
function extract_functions(expr::Expression)
    functions = Symbol[]
    _extract_functions_helper!(functions, expr)
    return unique(functions)
end

# Helper function to recursively extract function symbols
function _extract_functions_helper!(functions::Vector{Symbol}, expr::FunctionCall)
    push!(functions, expr.name)
    for arg in expr.args
        _extract_functions_helper!(functions, arg)
    end
end

function _extract_functions_helper!(functions::Vector{Symbol}, expr::Variable)
    # Variables don't have function symbols
end

function _extract_functions_helper!(functions::Vector{Symbol}, expr::Addition)
    for term in expr.terms
        _extract_functions_helper!(functions, term)
    end
end

function _extract_functions_helper!(functions::Vector{Symbol}, expr::Subtraction)
    for term in expr.terms
        _extract_functions_helper!(functions, term)
    end
end

function _extract_functions_helper!(functions::Vector{Symbol}, expr::Composition)
    _extract_functions_helper!(functions, expr.outer)
    _extract_functions_helper!(functions, expr.inner)
end

function _extract_functions_helper!(functions::Vector{Symbol}, expr::Maximum)
    for term in expr.terms
        _extract_functions_helper!(functions, term)
    end
end

function _extract_functions_helper!(functions::Vector{Symbol}, expr::Minimum)
    for term in expr.terms
        _extract_functions_helper!(functions, term)
    end
end

"""
    matches_expression_structure(expr::Expression, template_expr::Expression) -> Bool

Check if an expression matches the structure of a template expression.
The match is based on the expression type and structure, ignoring specific
function names and variable names.

# Arguments
- `expr::Expression`: The expression to check
- `template_expr::Expression`: The template expression to match against

# Returns
- `true` if the expression matches the template structure, `false` otherwise
"""
function matches_expression_structure(expr::Expression, template_expr::Expression)
    # Different types don't match
    if typeof(expr) != typeof(template_expr)
        return false
    end

    # Handle different expression types
    if expr isa Variable
        # Variables always match - template might have different variable names
        return true
    elseif expr isa FunctionCall
        # For function calls, check the argument structure
        if length(expr.args) != length(template_expr.args)
            return false
        end

        # Check each argument recursively
        for i = 1:length(expr.args)
            if !matches_expression_structure(expr.args[i], template_expr.args[i])
                return false
            end
        end
        return true
    elseif expr isa Addition
        # For addition, check that the number of terms matches
        if length(expr.terms) != length(template_expr.terms)
            return false
        end

        # In a more complex implementation, we would check all permutations
        # For simplicity, we just check positional matches
        for i = 1:length(expr.terms)
            if !matches_expression_structure(expr.terms[i], template_expr.terms[i])
                return false
            end
        end
        return true
    elseif expr isa Subtraction
        # For subtraction, check that the number of terms matches
        if length(expr.terms) != length(template_expr.terms)
            return false
        end

        # Check each term - order matters for subtraction
        for i = 1:length(expr.terms)
            if !matches_expression_structure(expr.terms[i], template_expr.terms[i])
                return false
            end
        end
        return true
    elseif expr isa Composition
        # Check both outer and inner expressions
        return matches_expression_structure(expr.outer, template_expr.outer) &&
               matches_expression_structure(expr.inner, template_expr.inner)
    elseif expr isa Maximum || expr isa Minimum
        # For max/min, check that the number of terms matches
        if length(expr.terms) != length(template_expr.terms)
            return false
        end

        # Like addition, we would ideally check all permutations
        # For simplicity, we just check positional matches
        for i = 1:length(expr.terms)
            if !matches_expression_structure(expr.terms[i], template_expr.terms[i])
                return false
            end
        end
        return true
    end

    # Default case - should not reach here with well-formed expressions
    return false
end

"""
    create_function_mapping(expr::Expression, template::OptimizationTemplate) -> Dict{Symbol,Symbol}

Create a mapping between template function symbols and the actual expression function symbols.
Returns `nothing` if a consistent mapping cannot be created.

# Arguments
- `expr::Expression`: The expression to analyze
- `template::OptimizationTemplate`: The template to match against

# Returns
- Dictionary mapping template function symbols to expression function symbols, or `nothing` if no mapping is possible
"""
function create_function_mapping(expr::Expression, template::OptimizationTemplate)
    # First check for structural match
    if !matches_expression_structure(expr, template.expression)
        return nothing
    end

    # Extract function symbols from both expressions
    template_funcs = extract_functions(template.expression)
    expr_funcs = extract_functions(expr)

    # If the number of functions doesn't match, mapping is impossible
    if length(template_funcs) != length(expr_funcs)
        return nothing
    end

    # Try to build a mapping
    mapping = Dict{Symbol,Symbol}()
    used_expr_funcs = Set{Symbol}()

    for t_func in template_funcs
        # Find the matching function in the expression
        found_match = false

        for e_func in expr_funcs
            # Skip already mapped functions
            if e_func in used_expr_funcs
                continue
            end

            # Check if this function satisfies the requirements
            if meets_function_requirements(e_func, t_func, template)
                mapping[t_func] = e_func
                push!(used_expr_funcs, e_func)
                found_match = true
                break
            end
        end

        # If no match found for this template function, mapping is impossible
        if !found_match
            return nothing
        end
    end

    return mapping
end

"""
    meets_function_requirements(expr_func::Symbol, template_func::Symbol, template::OptimizationTemplate) -> Bool

Check if an expression function meets the requirements specified for a template function.

# Arguments
- `expr_func::Symbol`: The function symbol in the expression
- `template_func::Symbol`: The function symbol in the template
- `template::OptimizationTemplate`: The template containing the requirements

# Returns
- `true` if the function meets all requirements, `false` otherwise
"""
function meets_function_requirements(
    expr_func::Symbol,
    template_func::Symbol,
    template::OptimizationTemplate,
)
    # Find the requirements for this template function
    requirements = nothing
    for req in template.function_requirements
        if req.name == template_func
            requirements = req
            break
        end
    end

    # If no specific requirements, any function is acceptable
    if requirements === nothing
        return true
    end

    # Check required properties
    for prop_type in requirements.required_properties
        if !has_property(expr_func, prop_type)
            return false
        end
    end

    # Check required oracles
    for oracle_type in requirements.required_oracles
        if !has_oracle(expr_func, oracle_type)
            return false
        end
    end

    # All requirements met
    return true
end

"""
    matches_template(expr::Expression, template_name::Symbol) -> Bool

Check if an expression matches a specific template.

# Arguments
- `expr::Expression`: The expression to check
- `template_name::Symbol`: The name of the template to match against

# Returns
- `true` if the expression matches the template, `false` otherwise

# Examples
```julia
@variable x::R()
@func f
@property f Convex() Smooth(1.0)
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2*x)

matches_template(f(x), :smooth_minimization)  # Returns true if template exists and matches
```
"""
function matches_template(expr::Expression, template_name::Symbol)
    if !haskey(optimization_templates, template_name)
        error("Template '$(template_name)' does not exist.")
    end

    template = optimization_templates[template_name]

    # Create a mapping between template functions and expression functions
    mapping = create_function_mapping(expr, template)

    # If mapping is nothing, the expression doesn't match
    return mapping !== nothing
end

"""
    find_matching_templates(expr::Expression) -> Vector{Symbol}

Find all templates that match an expression.

# Arguments
- `expr::Expression`: The expression to find matching templates for

# Returns
- Vector of template names (symbols) that match the expression

# Examples
```julia
@variable x::R()
@func f
@property f Convex() Smooth(1.0)
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2*x)

templates = find_matching_templates(f(x))  # Returns all matching templates
```
"""
function find_matching_templates(expr::Expression)
    matching_templates = Symbol[]

    for (name, _) in optimization_templates
        if matches_template(expr, name)
            push!(matching_templates, name)
        end
    end

    return matching_templates
end

"""
    get_function_mapping(expr::Expression, template_name::Symbol) -> Dict{Symbol,Symbol}

Get the mapping between template function symbols and expression function symbols.
This is useful for retrieving parameter values from the mapped functions.

# Arguments
- `expr::Expression`: The expression to analyze
- `template_name::Symbol`: The name of the template to match against

# Returns
- Dictionary mapping template function symbols to expression function symbols, or `nothing` if no mapping is possible

# Examples
```julia
@variable x::R()
@func f g
@property f Convex() Smooth(1.0)

mapping = get_function_mapping(f(x) + g(x), :composite_minimization)  # Returns e.g. Dict(:h => :f, :p => :g)
```
"""
function get_function_mapping(expr::Expression, template_name::Symbol)
    if !haskey(optimization_templates, template_name)
        error("Template '$(template_name)' does not exist.")
    end

    template = optimization_templates[template_name]
    return create_function_mapping(expr, template)
end
