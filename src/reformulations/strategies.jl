# Registry for transformation strategies
const strategy_registry = Dict{Symbol,Function}()

"""
Register a new reformulation strategy.

Arguments:
- `name::Symbol`: Identifier for the strategy.
- `strat::Function`: Function taking an expression and returning one or more reformulated expressions.
"""
function register_strategy(name::Symbol, strat::Function)
    strategy_registry[name] = strat
    return strat
end

"""
Retrieve a registered strategy by name.
"""
function get_strategy(name::Symbol)
    if haskey(strategy_registry, name)
        return strategy_registry[name]
    else
        error("Strategy $(name) not found")
    end
end

"""
List all registered strategy names.
"""
function list_strategies()
    return collect(keys(strategy_registry))
end

"""
Apply a registered strategy to an expression.
"""
function apply_strategy(name::Symbol, expr)
    strat = get_strategy(name)
    return strat(expr)
end

# Export registry API
export register_strategy, get_strategy, list_strategies, apply_strategy

# Include built-in strategies
include("strategies/commutativity.jl")
include("strategies/structure_loss.jl")  # add structure-loss strategy
