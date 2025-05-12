# Reformulations Module

This directory implements transformations of Argo expressions into mathematically equivalent forms (reformulations) along with their inferred properties and oracles.

## Components

- **types.jl**
  Defines the `Reformulation` struct and the `Strategy` abstract type.
- **reformulation.jl**
  Public API:
  - Register and list strategies
  - Generate reformulations
- **strategies/**
  Built-in strategies (e.g. `rebalancing.jl`) and the strategy registry.

## Usage Example

```julia
using Argo.Reformulations

# Generate all available reformulations of `expr`
all_reforms = generate_reformulations(expr)

# Apply only the rebalancing strategy
reforms = apply_strategy(:rebalancing, expr)

# Inspect one reformulation
first_reform = first(all_reforms)
@show first_reform.expr, first_reform.properties, keys(first_reform.oracles)
```

## Design Principles

- **KISS**: Keep strategies focused and minimal.
- **Open/Closed**: Add new strategies without altering core code.
- **Single Responsibility**: Each strategy encapsulates a single transformation.

## Extension Points

1. **Add a strategy**
   - Create a file in `strategies/` defining a subtype of `Strategy`.
   - Call `register_strategy(:your_name, YourStrategy())`.
2. **Custom workflow**
   - Use `apply_all_strategies(expr)` to chain multiple transformations.