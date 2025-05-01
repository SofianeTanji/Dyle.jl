"""
    Concrete implementations of the IOracleProvider interface.
"""

"""
    DefaultOracleProvider <: IOracleProvider

Default implementation of the IOracleProvider interface that uses the global oracle registry.
"""
struct DefaultOracleProvider <: IOracleProvider end

"""
    register_oracle(provider::DefaultOracleProvider, func_name::Symbol, oracle::Oracle)

Register an oracle for a function using the global registry.

# Arguments
- `provider::DefaultOracleProvider`: The oracle provider
- `func_name::Symbol`: The function name to register the oracle for
- `oracle::Oracle`: The oracle to register

# Returns
- The registered oracle
"""
function register_oracle(::DefaultOracleProvider, func_name::Symbol, oracle::Oracle)
    return register_oracle!(func_name, oracle)
end

"""
    get_oracle(provider::DefaultOracleProvider, func_name::Symbol, oracle_type::DataType)

Get an oracle of the specified type for a function using the global registry.

# Arguments
- `provider::DefaultOracleProvider`: The oracle provider
- `func_name::Symbol`: The function name to get the oracle for
- `oracle_type::DataType`: The type of oracle to get

# Returns
- The oracle if found, `nothing` otherwise
"""
function get_oracle(::DefaultOracleProvider, func_name::Symbol, oracle_type::DataType)
    return get_oracle(func_name, oracle_type)
end

"""
    has_oracle(provider::DefaultOracleProvider, func_name::Symbol, oracle_type::DataType)

Check if a function has an oracle of the specified type using the global registry.

# Arguments
- `provider::DefaultOracleProvider`: The oracle provider
- `func_name::Symbol`: The function name to check
- `oracle_type::DataType`: The type of oracle to check for

# Returns
- `true` if the function has the oracle type, `false` otherwise
"""
function has_oracle(::DefaultOracleProvider, func_name::Symbol, oracle_type::DataType)
    return has_oracle(func_name, oracle_type)
end

"""
    clear_oracles(provider::DefaultOracleProvider, func_name::Symbol)

Clear all oracles registered for the given function using the global registry.

# Arguments
- `provider::DefaultOracleProvider`: The oracle provider
- `func_name::Symbol`: The function name to clear oracles for
"""
function clear_oracles(::DefaultOracleProvider, func_name::Symbol)
    return clear_oracles!(func_name)
end

"""
    get_oracle_for_expression(provider::DefaultOracleProvider, expr::Expression, oracle_type::DataType)

Get an oracle for a composite expression using the global registry.

# Arguments
- `provider::DefaultOracleProvider`: The oracle provider
- `expr::Expression`: The expression to get the oracle for
- `oracle_type::DataType`: The type of oracle to get

# Returns
- A combined oracle for the expression if possible, `nothing` otherwise
"""
function get_oracle_for_expression(
    ::DefaultOracleProvider,
    expr::Expression,
    oracle_type::DataType,
)
    return get_oracle_for_expression(expr, oracle_type)
end

"""
    register_special_combination(provider::DefaultOracleProvider, op_type::DataType, funcs::Vector{Symbol},
                             oracle_type::DataType, handler::Function)

Register a special handler for combining oracles using the global registry.

# Arguments
- `provider::DefaultOracleProvider`: The oracle provider
- `op_type::DataType`: The operation type
- `funcs::Vector{Symbol}`: The function symbols involved
- `oracle_type::DataType`: The type of oracle to handle
- `handler::Function`: The handler function

# Returns
- The handler function
"""
function register_special_combination(
    ::DefaultOracleProvider,
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type::DataType,
    handler::Function,
)
    return register_special_combination(op_type, funcs, oracle_type, handler)
end

"""
    has_special_combination(provider::DefaultOracleProvider, op_type::DataType, funcs::Vector{Symbol},
                        oracle_type::DataType)

Check if a special combination handler exists using the global registry.

# Arguments
- `provider::DefaultOracleProvider`: The oracle provider
- `op_type::DataType`: The operation type
- `funcs::Vector{Symbol}`: The function symbols involved
- `oracle_type::DataType`: The type of oracle to check for

# Returns
- `true` if a special handler exists, `false` otherwise
"""
function has_special_combination(
    ::DefaultOracleProvider,
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type::DataType,
)
    return has_special_combination(op_type, funcs, oracle_type)
end

"""
    get_special_combination(provider::DefaultOracleProvider, op_type::DataType, funcs::Vector{Symbol},
                        oracle_type::DataType)

Get a special combination handler if one exists using the global registry.

# Arguments
- `provider::DefaultOracleProvider`: The oracle provider
- `op_type::DataType`: The operation type
- `funcs::Vector{Symbol}`: The function symbols involved
- `oracle_type::DataType`: The type of oracle to get the handler for

# Returns
- The handler function if found, `nothing` otherwise
"""
function get_special_combination(
    ::DefaultOracleProvider,
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type::DataType,
)
    return get_special_combination(op_type, funcs, oracle_type)
end
