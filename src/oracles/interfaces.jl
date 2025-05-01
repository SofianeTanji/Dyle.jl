"""
    IOracleProvider

An interface for providing oracle-related functionality.
This abstraction allows oracle retrieval and composition without exposing internal implementation details.
"""
abstract type IOracleProvider end

"""
    register_oracle(provider::IOracleProvider, func_name::Symbol, oracle::Oracle)

Register an oracle for a function.
Returns the oracle for chaining.

# Arguments
- `provider::IOracleProvider`: The oracle provider
- `func_name::Symbol`: The function name to register the oracle for
- `oracle::Oracle`: The oracle to register

# Returns
- The registered oracle
"""
function register_oracle end

"""
    get_oracle(provider::IOracleProvider, func_name::Symbol, oracle_type::DataType)

Get an oracle of the specified type for a function.

# Arguments
- `provider::IOracleProvider`: The oracle provider
- `func_name::Symbol`: The function name to get the oracle for
- `oracle_type::DataType`: The type of oracle to get (e.g., EvaluationOracle)

# Returns
- The oracle if found, `nothing` otherwise
"""
function get_oracle end

"""
    has_oracle(provider::IOracleProvider, func_name::Symbol, oracle_type::DataType)

Check if a function has an oracle of the specified type.

# Arguments
- `provider::IOracleProvider`: The oracle provider
- `func_name::Symbol`: The function name to check
- `oracle_type::DataType`: The type of oracle to check for

# Returns
- `true` if the function has the oracle type, `false` otherwise
"""
function has_oracle end

"""
    clear_oracles(provider::IOracleProvider, func_name::Symbol)

Clear all oracles registered for the given function.

# Arguments
- `provider::IOracleProvider`: The oracle provider
- `func_name::Symbol`: The function name to clear oracles for
"""
function clear_oracles end

"""
    get_oracle_for_expression(provider::IOracleProvider, expr::Expression, oracle_type::DataType)

Get an oracle for a composite expression by combining the oracles of its components.

# Arguments
- `provider::IOracleProvider`: The oracle provider
- `expr::Expression`: The expression to get the oracle for
- `oracle_type::DataType`: The type of oracle to get

# Returns
- A combined oracle for the expression if possible, `nothing` otherwise
"""
function get_oracle_for_expression end

"""
    register_special_combination(provider::IOracleProvider, op_type::DataType, funcs::Vector{Symbol},
                             oracle_type::DataType, handler::Function)

Register a special handler for combining oracles in specific expressions.

# Arguments
- `provider::IOracleProvider`: The oracle provider
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the operation
- `oracle_type::DataType`: The type of oracle to handle
- `handler::Function`: The function that handles the special case

# Returns
- The handler function
"""
function register_special_combination end

"""
    has_special_combination(provider::IOracleProvider, op_type::DataType, funcs::Vector{Symbol},
                        oracle_type::DataType)

Check if a special combination handler exists.

# Arguments
- `provider::IOracleProvider`: The oracle provider
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the operation
- `oracle_type::DataType`: The type of oracle to check for

# Returns
- `true` if a special handler exists, `false` otherwise
"""
function has_special_combination end

"""
    get_special_combination(provider::IOracleProvider, op_type::DataType, funcs::Vector{Symbol},
                        oracle_type::DataType)

Get a special combination handler if one exists.

# Arguments
- `provider::IOracleProvider`: The oracle provider
- `op_type::DataType`: The operation type (e.g., Addition, Composition)
- `funcs::Vector{Symbol}`: The function symbols involved in the operation
- `oracle_type::DataType`: The type of oracle to get the handler for

# Returns
- The handler function if found, `nothing` otherwise
"""
function get_special_combination end
