"""
    Registry system for reformulation strategies.

    This file provides a mechanism to register, list, and apply reformulation strategies.
"""

# Dictionary to store registered strategies
const strategy_registry = Dict{Symbol,Strategy}()

"""
    push_unique!(reformulations::Vector{Reformulation}, seen::Set{String}, expr::Expression) -> Bool

Add a reformulation to the collection if its string representation is unique.

# Arguments
- `reformulations`: Collection to add the reformulation to
- `seen`: Set of already seen string representations
- `expr`: Expression to add as a reformulation

# Returns
- `Bool`: Whether the reformulation was unique and added
"""
function push_unique!(
    reformulations::Vector{Reformulation}, seen::Set{String}, expr::Expression
)
    repr = string(expr)
    if !(repr in seen)
        push!(reformulations, create_reformulation(expr))
        push!(seen, repr)
        return true
    end
    return false
end

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
    # Use a more strict approach to ensure true uniqueness
    seen = Set{UInt}()
    unique_reformulations = Reformulation[]

    for reform in all_reformulations
        hash_val = hash(reform.expr)
        if !(hash_val in seen)
            push!(unique_reformulations, reform)
            push!(seen, hash_val)
        end
    end

    return unique_reformulations
end

"""
    generate_reformulations(expr::Expression; max_iterations::Int = 1) -> Vector{Reformulation}

Generate all possible reformulations by applying strategies repeatedly.

# Arguments
- `expr::Expression`: The expression to transform
- `max_iterations::Int`: Maximum number of successive transformations to apply

# Returns
- `Vector{Reformulation}`: All generated reformulations
"""
function generate_reformulations(expr::Expression; max_iterations::Int=1)
    # Start with the original expression
    all_reformulations = [create_reformulation(expr)]
    current_expressions = [expr]

    # Global tracking of seen expressions across all iterations
    seen_expressions = Set{String}([string(expr)])

    # Track which strategies have been applied to each expression
    # Use string representations for more reliable uniqueness
    strategy_applied = Dict{String,Set{Symbol}}(string(expr) => Set{Symbol}())

    # Apply strategies iteratively
    for i in 1:max_iterations
        new_expressions = Expression[]

        for current_expr in current_expressions
            expr_str = string(current_expr)

            # Get or initialize applied set for this expression
            applied = get!(strategy_applied, expr_str, Set{Symbol}())

            for strategy_name in list_strategies()
                # Skip if this strategy was already applied to this expression
                if strategy_name in applied
                    continue
                end

                # Mark strategy as applied to this expression
                push!(applied, strategy_name)

                # Apply the strategy
                strategy = get_strategy(strategy_name)
                new_reformulations = strategy(current_expr)
                # Add new reformulations uniquely
                for reformulation in new_reformulations
                    new_str = string(reformulation.expr)
                    if !(new_str in seen_expressions)
                        push!(all_reformulations, reformulation)
                        push!(new_expressions, reformulation.expr)
                        push!(seen_expressions, new_str)
                        # Initialize the applied-set for this new expression
                        strategy_applied[new_str] = Set{Symbol}()
                    end
                end
            end
        end

        # Stop early if no new expressions were found
        isempty(new_expressions) && break
        current_expressions = new_expressions
    end

    return all_reformulations
end