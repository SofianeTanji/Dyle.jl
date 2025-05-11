"""
    Registry system for reformulation strategies.

    This file provides a mechanism to register, list, and apply reformulation strategies.
"""

# Dictionary to store registered strategies
const strategy_registry = Dict{Symbol,Strategy}()

"""
    register_strategy(name::Symbol, strategy::Strategy) -> Strategy

Register a reformulation strategy.

# Arguments
- `name::Symbol`: Name to identify the strategy
- `strategy::Strategy`: The strategy implementation

# Returns
- `Strategy`: The registered strategy
"""
function register_strategy(name::Symbol, strategy::Strategy)
    strategy_registry[name] = strategy
    return strategy
end

"""
    get_strategy(name::Symbol) -> Union{Strategy,Nothing}

Get a strategy by name.

# Arguments
- `name::Symbol`: Name of the strategy to retrieve

# Returns
- `Union{Strategy,Nothing}`: The requested strategy, or nothing if not found
"""
function get_strategy(name::Symbol)
    return get(strategy_registry, name, nothing)
end

"""
    has_strategy(name::Symbol) -> Bool

Check if a strategy exists.

# Arguments
- `name::Symbol`: Name of the strategy to check

# Returns
- `Bool`: True if the strategy exists, false otherwise
"""
function has_strategy(name::Symbol)
    return haskey(strategy_registry, name)
end

"""
    list_strategies() -> Vector{Symbol}

List all registered strategies.

# Returns
- `Vector{Symbol}`: Names of all registered strategies
"""
function list_strategies()
    return collect(keys(strategy_registry))
end

"""
    clear_strategies() -> Nothing

Clear all registered strategies.

# Returns
- `Nothing`
"""
function clear_strategies()
    empty!(strategy_registry)
    return nothing
end

"""
    apply_strategy(strategy_name::Symbol, expr::Expression) -> Vector{Reformulation}

Apply a named strategy to an expression.

# Arguments
- `strategy_name::Symbol`: Name of the strategy to apply
- `expr::Expression`: The expression to transform

# Returns
- `Vector{Reformulation}`: The resulting reformulations
"""
function apply_strategy(strategy_name::Symbol, expr::Expression)
    strategy = get_strategy(strategy_name)
    if strategy === nothing
        error("Strategy '$(strategy_name)' not found")
    end
    return strategy(expr)
end

"""
    apply_strategy(strategy::Strategy, expr::Expression) -> Vector{Reformulation}

Apply a strategy directly to an expression.

# Arguments
- `strategy::Strategy`: The strategy to apply
- `expr::Expression`: The expression to transform

# Returns
- `Vector{Reformulation}`: The resulting reformulations
"""
function apply_strategy(strategy::Strategy, expr::Expression)
    return strategy(expr)
end

"""
    apply_all_strategies(expr::Expression) -> Vector{Reformulation}

Apply all registered strategies to an expression.

# Arguments
- `expr::Expression`: The expression to transform

# Returns
- `Vector{Reformulation}`: The resulting reformulations
"""
function apply_all_strategies(expr::Expression)
    all_reformulations = Reformulation[]

    # Start with the original expression as its own reformulation
    original_reformulation = create_reformulation(expr)
    push!(all_reformulations, original_reformulation)

    # Apply each strategy
    for strategy_name in list_strategies()
        strategy = get_strategy(strategy_name)
        new_reformulations = strategy(expr)
        append!(all_reformulations, new_reformulations)
    end

    # Remove duplicates (based on expression equality)
    unique_reformulations = unique(r -> r.expr, all_reformulations)

    return unique_reformulations
end

"""
    generate_reformulations(expr::Expression; max_iterations::Int = 3) -> Vector{Reformulation}

Generate all possible reformulations by applying strategies repeatedly.

# Arguments
- `expr::Expression`: The expression to transform
- `max_iterations::Int`: Maximum number of successive transformations to apply

# Returns
- `Vector{Reformulation}`: All generated reformulations
"""
function generate_reformulations(expr::Expression; max_iterations::Int = 3)
    # Start with the original expression
    all_reformulations = [create_reformulation(expr)]
    current_expressions = [expr]

    # Apply strategies iteratively
    for i = 1:max_iterations
        new_expressions = Expression[]

        # Apply all strategies to all current expressions
        for current_expr in current_expressions
            for strategy_name in list_strategies()
                strategy = get_strategy(strategy_name)
                new_reformulations = strategy(current_expr)

                # Add new reformulations to the collection
                for reformulation in new_reformulations
                    if !any(r -> r.expr == reformulation.expr, all_reformulations)
                        push!(all_reformulations, reformulation)
                        push!(new_expressions, reformulation.expr)
                    end
                end
            end
        end

        # If no new expressions were generated, stop
        if isempty(new_expressions)
            break
        end

        # Update current expressions for the next iteration
        current_expressions = new_expressions
    end

    return all_reformulations
end
