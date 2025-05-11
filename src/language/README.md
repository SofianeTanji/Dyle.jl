# Language Module

This directory implements the core expression representation system for Argo.jl. It provides the foundational types and operations for building, manipulating, and inspecting mathematical expressions.

## Components

### Core Types (`expression_types.jl`)

- `Expression`: Abstract base type for all expression representations
- Concrete types for various expression forms:
  - `Variable`: Named mathematical variables
  - `FunctionCall`: Function applications
  - `Addition`: Sum of expressions
  - `Subtraction`: Difference of expressions
  - `Composition`: Function composition
  - `Maximum`/`Minimum`: Operations for taking maximums/minimums

### Spaces (`spaces.jl`)

- `Space`: Abstract type representing mathematical spaces
- `R`: Real number space (scalars)
- `Rn`: n-dimensional real vector space

### Parser (`parser.jl`)

- Transforms Julia expressions into Argo expression objects
- Handles type checking and space compatibility verification
- Constructs the appropriate expression trees

### DSL Macros (`macros.jl`)

- `@variable`: Declares variables with optional space annotations
- `@func`: Declares functions with domain/codomain specifications
- `@expression`: Parses Julia expressions into Argo expressions

## Usage Example

```julia
using Argo.Language

# Define variables and functions
@variable x::R()
@variable v::Rn(3)
@func f(R(), R())

# Create expressions
expr = f(x) + f(x)
```

## Design Principles

The language module follows these design principles:

- Type safety: Expressions carry space information to catch domain/codomain mismatches
- Composability: Expression objects can be combined with standard operators
- Inspectability: Expressions can be traversed and analyzed
- Mathematical fidelity: The representation closely mirrors mathematical notation

## Extension Points

New expression types can be added by:

1. Creating a new subtype of `Expression`
2. Implementing required methods (`show`, space compatibility)
3. Adding appropriate operator overloads if needed
