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

end
