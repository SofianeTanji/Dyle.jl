"""
Registry system for oracles. This allows associating oracle implementations with function symbols.
"""

# Main registry: maps function symbols to a dictionary of oracle types and their implementations
const oracle_registry = Dict{Symbol,Dict{DataType,Function}}()

"""
    register_oracle!(func_symbol::Symbol, oracle, implementation::Function)

Register an oracle implementation for a function.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle`: An instance or type of the oracle being registered
- `implementation::Function`: The function implementing the oracle

# Returns
- The registered implementation function

# Example
```julia
register_oracle!(:f, EvaluationOracle(), x -> x^2 + 1)
```
"""
function register_oracle!(func_symbol::Symbol, oracle, implementation::Function)
    # Handle both oracle instances and types
    if oracle isa Oracle
        # It's an oracle instance
        oracle_type = typeof(oracle)
        exactness_info = oracle.exactness
    else
        # It's an oracle type
        oracle_type = oracle
        exactness_info = nothing
    end

    if !haskey(oracle_registry, func_symbol)
        oracle_registry[func_symbol] = Dict{DataType,Function}()
    end

    # Store the implementation with the specific oracle type
    oracle_registry[func_symbol][oracle_type] = implementation

    # Also register metadata if exactness or other properties are specified
    if exactness_info isa Inexact
        # Extract the base type for metadata registration
        base_type = extract_oracle_type(oracle_type)

        # Create metadata with the exactness information
        metadata = OracleMetadata(exactness = exactness_info)

        # Register the metadata
        register_oracle_metadata!(func_symbol, base_type, metadata)
    end

    return implementation
end

"""
    register_oracle_type!(func_symbol::Symbol, oracle)

Register just the oracle type for a function, without an implementation.
This is useful for indicating that a function supports a type of oracle,
even if the implementation isn't provided directly.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle`: An instance or type of the oracle being registered

# Returns
- Nothing
"""
function register_oracle_type!(func_symbol::Symbol, oracle)
    # Handle both oracle instances and types
    if oracle isa Oracle
        # It's an oracle instance
        oracle_type = typeof(oracle)
        exactness_info = oracle.exactness
    else
        # It's an oracle type
        oracle_type = oracle
        exactness_info = nothing
    end

    if !haskey(oracle_registry, func_symbol)
        oracle_registry[func_symbol] = Dict{DataType,Function}()
    end

    # Register metadata if exactness or other properties are specified
    if exactness_info isa Inexact
        # Extract the base type for metadata registration
        base_type = extract_oracle_type(oracle_type)

        # Create metadata with the exactness information
        metadata = OracleMetadata(exactness = exactness_info)

        # Register the metadata
        register_oracle_metadata!(func_symbol, base_type, metadata)
    end

    return nothing
end

"""
    get_oracle(func_symbol::Symbol, oracle)

Get the oracle implementation for a function.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle`: An instance or type of the oracle to retrieve

# Returns
- The oracle implementation function if it exists, otherwise nothing
"""
function get_oracle(func_symbol::Symbol, oracle)
    # Handle both oracle instances and types
    if oracle isa Oracle
        # It's an oracle instance
        oracle_type = typeof(oracle)
    else
        # It's an oracle type
        oracle_type = oracle
    end

    if !haskey(oracle_registry, func_symbol) ||
       !haskey(oracle_registry[func_symbol], oracle_type)
        # Try to find a compatible oracle (e.g., an exact oracle can be used for an inexact request)
        return find_compatible_oracle(func_symbol, oracle)
    end

    return oracle_registry[func_symbol][oracle_type]
end

"""
    find_compatible_oracle(func_symbol::Symbol, oracle)

Find a compatible oracle implementation for a function.
This allows for substituting an exact oracle when an inexact one is requested.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle`: An instance or type of the requested oracle

# Returns
- A compatible oracle implementation function if it exists, otherwise nothing
"""
function find_compatible_oracle(func_symbol::Symbol, oracle)
    if !haskey(oracle_registry, func_symbol)
        return nothing
    end

    # Get oracle type and exactness information
    if oracle isa Oracle
        # It's an oracle instance
        oracle_type = typeof(oracle)
        exactness_info = oracle.exactness
    else
        # It's an oracle type
        oracle_type = oracle
        exactness_info = nothing
    end

    # Get the base oracle type without exactness parameter
    base_type = extract_oracle_type(oracle_type)

    # If an inexact oracle is requested, check if an exact one exists
    if exactness_info isa Inexact
        # Check for an exact version of the same oracle type
        for key in keys(oracle_registry[func_symbol])
            key_base = extract_oracle_type(key)
            if key_base == base_type && exactness_type(key) <: Exact
                return oracle_registry[func_symbol][key]
            end
        end
    end

    # No compatible oracle found
    return nothing
end

"""
    has_oracle(func_symbol::Symbol, oracle)

Check if a function has a registered oracle.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle`: An instance or type of the oracle to check for

# Returns
- `true` if the function has a matching oracle registered, `false` otherwise
"""
function has_oracle(func_symbol::Symbol, oracle)
    # Handle both oracle instances and types
    if oracle isa Oracle
        # It's an oracle instance
        oracle_type = typeof(oracle)
    else
        # It's an oracle type
        oracle_type = oracle
    end

    if !haskey(oracle_registry, func_symbol) ||
       !haskey(oracle_registry[func_symbol], oracle_type)
        # Check if a compatible oracle exists
        return find_compatible_oracle(func_symbol, oracle) !== nothing
    end

    return true
end

"""
    clear_oracles!(func_symbol::Symbol)

Clear all registered oracles for a function.

# Arguments
- `func_symbol::Symbol`: The symbol of the function

# Returns
- Nothing
"""
function clear_oracles!(func_symbol::Symbol)
    if haskey(oracle_registry, func_symbol)
        delete!(oracle_registry, func_symbol)
    end

    # Also clear any metadata
    clear_all_oracle_metadata!(func_symbol)

    return nothing
end
