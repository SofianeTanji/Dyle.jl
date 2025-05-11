# Properties Module

This directory implements a mathematical property algebra system for Argo.jl. It provides mechanisms to associate properties with functions and infer properties of composite expressions.

## Components

### Property Types (`types.jl`)

- `Property`: Abstract base type for all mathematical properties
- Concrete property implementations:
  - `Convex`: Convexity property
  - `StronglyConvex`: Strong convexity with parameter μ
  - `HypoConvex`: Hypoconvexity with parameter ρ
  - `Smooth`: Smoothness with Lipschitz gradient parameter L
  - `Lipschitz`: Lipschitz continuity with parameter M
  - `Linear`: Linear operators with eigenvalue bounds
  - `Quadratic`: Quadratic functions with eigenvalue bounds
  - `MonotonicallyIncreasing`: Monotonicity property

### Property Registry (`registry.jl`)

- Associates properties with function symbols
- Provides access and manipulation functions:
  - `register_property!`: Associates a property with a function
  - `get_properties`: Retrieves all properties of a function
  - `has_property`: Checks if a function has a specific property

### Property Inference (`inference.jl`)

- `infer_properties`: Derives properties of composite expressions
- Handles different expression types:
  - Variables (no inherent properties)
  - Function calls (properties from registry)
  - Composite expressions (derived via combination rules)

### Property Combination Rules (`combinations/`)

- `addition.jl`: Rules for property preservation under addition
- `subtraction.jl`: Rules for property preservation under subtraction
- `composition.jl`: Rules for property preservation under function composition
- `maximum.jl`: Rules for property preservation under maximum operation
- `minimum.jl`: Rules for property preservation under minimum operation

### DSL Macros (`macros.jl`)

- `@property`: Associates properties with functions

## Usage Example

```julia
using Argo.Properties

# Declare functions with properties
@func f(R(), R())
@property f StronglyConvex(1.0) Smooth(2.0)

# Create and analyze expressions
expr = f(x) + f(x)
properties = infer_properties(expr)
```

## Design Principles

The properties module follows these design principles:

- Mathematical soundness: Property inference preserves mathematical validity
- Extensibility: New properties can be added with minimal changes
- Composition: Property inference works on arbitrarily nested expressions
- Uncertainty handling: Interval arithmetic for rigorous bounds on parameters

## Extension Points

The system can be extended by:

1. Adding new property types in `types.jl`
2. Implementing combination rules for existing operations
3. Adding new combination rule files for additional operations
