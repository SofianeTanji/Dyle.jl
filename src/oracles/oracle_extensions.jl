"""
Extension functions for oracle management using the IOracleProvider interface.
"""

# Global default provider instance
const global_oracle_provider = DefaultOracleProvider()

"""
    with_provider(func::Function, provider::IOracleProvider)

Execute a function with a specific oracle provider.

# Arguments
- `func::Function`: The function to execute with the provider
- `provider::IOracleProvider`: The oracle provider to use

# Returns
- The result of the function
"""
function with_provider(func::Function, provider::IOracleProvider)
    return func(provider)
end

"""
    get_oracle_with_provider(func_name::Symbol, oracle_type::DataType, provider::IOracleProvider)

Get an oracle using a specific provider.

# Arguments
- `func_name::Symbol`: The function name to get the oracle for
- `oracle_type::DataType`: The type of oracle to get
- `provider::IOracleProvider`: The oracle provider to use

# Returns
- The oracle if found, `nothing` otherwise
"""
function get_oracle_with_provider(
    func_name::Symbol,
    oracle_type::DataType,
    provider::IOracleProvider,
)
    return get_oracle(provider, func_name, oracle_type)
end

"""
    get_oracle_for_expression_with_provider(expr::Expression, oracle_type::DataType, provider::IOracleProvider)

Get an oracle for an expression using a specific provider.

# Arguments
- `expr::Expression`: The expression to get the oracle for
- `oracle_type::DataType`: The type of oracle to get
- `provider::IOracleProvider`: The oracle provider to use

# Returns
- A combined oracle for the expression if possible, `nothing` otherwise
"""
function get_oracle_for_expression_with_provider(
    expr::Expression,
    oracle_type::DataType,
    provider::IOracleProvider,
)
    return get_oracle_for_expression(provider, expr, oracle_type)
end

# Overload the existing global functions to use the default provider
# This maintains backward compatibility while using the new interface internally

function register_oracle!(func_name::Symbol, oracle::Oracle)
    return register_oracle(global_oracle_provider, func_name, oracle)
end

function get_oracle(func_name::Symbol, oracle_type::DataType)
    return get_oracle(global_oracle_provider, func_name, oracle_type)
end

function has_oracle(func_name::Symbol, oracle_type::DataType)
    return has_oracle(global_oracle_provider, func_name, oracle_type)
end

function clear_oracles!(func_name::Symbol)
    return clear_oracles(global_oracle_provider, func_name)
end

function get_oracle_for_expression(expr::Expression, oracle_type::DataType)
    return get_oracle_for_expression(global_oracle_provider, expr, oracle_type)
end

function register_special_combination(
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type::DataType,
    handler::Function,
)
    return register_special_combination(
        global_oracle_provider,
        op_type,
        funcs,
        oracle_type,
        handler,
    )
end

function has_special_combination(
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type::DataType,
)
    return has_special_combination(global_oracle_provider, op_type, funcs, oracle_type)
end

function get_special_combination(
    op_type::DataType,
    funcs::Vector{Symbol},
    oracle_type::DataType,
)
    return get_special_combination(global_oracle_provider, op_type, funcs, oracle_type)
end
