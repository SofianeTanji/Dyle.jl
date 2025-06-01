module Language
include("spaces.jl")
include("expression_types.jl")
include("parser.jl")
include("macros.jl")

# === PUBLIC API === #

## Space
export Space, R, Rn

## AST node types
export Expression,
    Variable,
    FunctionType,
    FunctionCall,
    Addition,
    Subtraction,
    Composition,
    Maximum,
    Minimum

## Parser
export parser

# DSL macros
export @expression, @func, @variable, @space

# Overloaded operators
export |>

# Utility functions
export collect_variables, collect_function_names

"""
collect_variables(expr::Expression) -> Vector{Variable}

Collect all unique variables appearing anywhere in the expression tree.
"""
function collect_variables(expr::Expression)::Vector{Variable}
    vars = Set{Variable}()
    # Recursive helper function
    function _collect(e::Expression)
        if e isa Variable
            push!(vars, e)
        elseif e isa FunctionCall
            for arg in e.args
                _collect(arg)
            end
        elseif e isa Addition || e isa Subtraction || e isa Maximum || e isa Minimum
            for term in e.terms
                _collect(term)
            end
        elseif e isa Composition
            _collect(e.outer)
            _collect(e.inner)
        end
        # Other expression types (FunctionType, Literal, etc.) have no subexpressions to collect
    end
    _collect(expr)
    return collect(vars)
end

end
