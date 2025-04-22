module Language
include("expression_types.jl")
include("parser.jl")
include("macros.jl")

# === PUBLIC API === #

## AST node types
export Expression,
    Variable, FunctionCall, Addition, Substraction, Composition, Maximum, Minimum

## Parser
export parser

# DSL macros
export @expression, @func, @variable

# Overloaded operators
export ∘, |>

end
