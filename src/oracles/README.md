# Oracle Module

This directory implements the computational interface for mathematical functions in Argo.jl. It provides a flexible system for registering, combining, and using computational capabilities ("oracles") of functions.

## Components

### Core Types (`types.jl`)

- `Oracle`: Abstract base type for all oracle representations
- Concrete oracle implementations:
  - `EvaluationOracle`: Computes function values f(x)
  - `DerivativeOracle`: Computes derivatives/gradients ∇f(x)
  - `ProximalOracle`: Computes proximal operators prox_λf(x)

### Exactness System (`exactness.jl`)

- `Exactness`: Abstract type representing precision of computations
- `Exact`: Represents exact (analytical) computations
- `AbsoluteError`: Inexact computations with absolute error bounds
- `RelativeError`: Inexact computations with relative error bounds

### Cost Models (`cost_models.jl`)

- `CostModel`: Abstract type for computational complexity
- `ConstantCost`: Fixed computational cost
- `DimensionalCost`: Cost scaling with problem dimensions

### Registry (`registry.jl`)

- Registration system for associating oracles with functions
- Support for special combination handlers

### Combination Logic (`combinations.jl`)

- Rules for combining oracles of composite expressions
- Implementation of mathematical rules (e.g., chain rule)

### Macro Interface (`macros.jl`)

- `@oracle`: Register oracles for functions
- `@oracles`: Register multiple oracles at once
- `@clear_oracles`: Remove oracle registrations

## Usage Example

```julia
using Argo.Oracles

# Define functions with oracles
@func f(R(), R())
@func g(R(), R())

# Register evaluation and derivative oracles
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2*x)
@oracle g EvaluationOracle(x -> sin(x))
@oracle g DerivativeOracle(x -> cos(x))

# Create a composite expression
expr = f(x) + g(x)

# Get an oracle for the expression
eval_oracle = get_oracle_for_expression(expr, EvaluationOracle)
deriv_oracle = get_oracle_for_expression(expr, DerivativeOracle)

# Evaluate at a point
x_value = 2.0
f_plus_g = eval_oracle(x_value)      # Returns x^2 + sin(x)
f_plus_g_deriv = deriv_oracle(x_value)  # Returns 2*x + cos(x)
```

## Design Principles

The Oracle module follows these design principles:

- **Simplicity**: Direct, understandable implementations over complex type hierarchies
- **Composability**: Oracles combine naturally for composite expressions
- **Explicitness**: Clear relationships between mathematical operations and computational rules
- **Extensibility**: Easy to add new oracle types and combination rules

## Extension Points

The system can be extended by:

1. Adding new oracle types in `types.jl`
2. Implementing combination rules for existing operations in `combinations.jl`
3. Registering special combinations for complex cases
4. Expanding cost models for more sophisticated complexity analysis
