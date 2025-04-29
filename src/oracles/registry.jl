"""
Registry system for oracles. This allows associating oracle implementations with function symbols.
"""

# Main registry: maps function symbols to a dictionary of oracle types and their implementations
const oracle_registry = Dict{Symbol,Dict{Type{<:Oracle},Function}}()

"""
    register_oracle!(func_symbol::Symbol, ::Type{T}, implementation::Function) where {T<:Oracle}

Register an oracle implementation for a function.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `::Type{T}`: The type of oracle being registered
- `implementation::Function`: The function implementing the oracle

# Returns
- The registered implementation function

# Example
```julia
register_oracle!(:f, EvaluationOracle, x -> x^2 + 1)
```
"""
function register_oracle!(
    func_symbol::Symbol,
    ::Type{T},
    implementation::Function,
) where {T<:Oracle}
    if !haskey(oracle_registry, func_symbol)
        oracle_registry[func_symbol] = Dict{Type{<:Oracle},Function}()
    end
    oracle_registry[func_symbol][T] = implementation
    return implementation
end

"""
    register_oracle_type!(func_symbol::Symbol, ::Type{T}) where {T<:Oracle}

Register just the oracle type for a function, without an implementation.
This is useful for indicating that a function supports a type of oracle,
even if the implementation isn't provided directly.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `::Type{T}`: The type of oracle being registered

# Returns
- Nothing
"""
function register_oracle_type!(func_symbol::Symbol, ::Type{T}) where {T<:Oracle}
    if !haskey(oracle_registry, func_symbol)
        oracle_registry[func_symbol] = Dict{Type{<:Oracle},Function}()
    end
    # We don't add an implementation, just mark that this oracle type is supported
    return nothing
end

"""
    get_oracle(func_symbol::Symbol, oracle_type::Type{<:Oracle})

Get the oracle implementation for a function.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle_type::Type{<:Oracle}`: The type of oracle to retrieve

# Returns
- The oracle implementation function if it exists, otherwise nothing
"""
function get_oracle(func_symbol::Symbol, oracle_type::Type{<:Oracle})
    if !haskey(oracle_registry, func_symbol) ||
       !haskey(oracle_registry[func_symbol], oracle_type)
        return nothing
    end
    return oracle_registry[func_symbol][oracle_type]
end

"""
    has_oracle(func_symbol::Symbol, oracle_type::Type{<:Oracle})

Check if a function has a registered oracle of the specified type.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle_type::Type{<:Oracle}`: The type of oracle to check for

# Returns
- `true` if the function has the oracle type registered, `false` otherwise
"""
function has_oracle(func_symbol::Symbol, oracle_type::Type{<:Oracle})
    return haskey(oracle_registry, func_symbol) &&
           haskey(oracle_registry[func_symbol], oracle_type)
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
    return nothing
end
