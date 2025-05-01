"""
    OracleAdapter

Adapter module to bridge the Templates and Oracles modules.
This provides a clean interface for Templates to work with Oracles without tight coupling.
"""
module OracleAdapter

using ...Language
using ...Oracles

"""
    meets_oracle_requirements(func_name::Symbol, required_oracles::Vector{DataType},
                           provider::IOracleProvider = DefaultOracleProvider())

Check if a function meets all the specified oracle requirements.

# Arguments
- `func_name::Symbol`: The function name to check
- `required_oracles::Vector{DataType}`: Oracle types that the function must have
- `provider::IOracleProvider`: (Optional) The oracle provider to use

# Returns
- `true` if the function meets all requirements, `false` otherwise
"""
function meets_oracle_requirements(
    func_name::Symbol,
    required_oracles::Vector{DataType},
    provider::IOracleProvider = DefaultOracleProvider(),
)
    # If no oracles required, automatically passes
    isempty(required_oracles) && return true

    # Check that the function has each required oracle
    for oracle_type in required_oracles
        if !has_oracle(provider, func_name, oracle_type)
            return false
        end
    end

    return true
end

"""
    get_oracle_for_function(func_name::Symbol, oracle_type::DataType,
                         provider::IOracleProvider = DefaultOracleProvider())

Get an oracle for a function.

# Arguments
- `func_name::Symbol`: The function name to get the oracle for
- `oracle_type::DataType`: The type of oracle to get
- `provider::IOracleProvider`: (Optional) The oracle provider to use

# Returns
- The oracle if found, `nothing` otherwise
"""
function get_oracle_for_function(
    func_name::Symbol,
    oracle_type::DataType,
    provider::IOracleProvider = DefaultOracleProvider(),
)
    return get_oracle(provider, func_name, oracle_type)
end

"""
    get_oracle_for_expr(expr::Expression, oracle_type::DataType,
                     provider::IOracleProvider = DefaultOracleProvider())

Get an oracle for an expression.

# Arguments
- `expr::Expression`: The expression to get the oracle for
- `oracle_type::DataType`: The type of oracle to get
- `provider::IOracleProvider`: (Optional) The oracle provider to use

# Returns
- A combined oracle for the expression if possible, `nothing` otherwise
"""
function get_oracle_for_expr(
    expr::Expression,
    oracle_type::DataType,
    provider::IOracleProvider = DefaultOracleProvider(),
)
    return get_oracle_for_expression(provider, expr, oracle_type)
end

"""
    get_oracle_metadata(func_name::Symbol, oracle_type::DataType,
                     provider::IOracleProvider = DefaultOracleProvider())

Get the metadata for a function's oracle.

# Arguments
- `func_name::Symbol`: The function name to get the oracle metadata for
- `oracle_type::DataType`: The type of oracle to get metadata for
- `provider::IOracleProvider`: (Optional) The oracle provider to use

# Returns
- The oracle metadata if found, `nothing` otherwise
"""
function get_oracle_metadata(
    func_name::Symbol,
    oracle_type::DataType,
    provider::IOracleProvider = DefaultOracleProvider(),
)
    oracle = get_oracle(provider, func_name, oracle_type)
    return oracle !== nothing ? oracle.metadata : nothing
end

"""
    get_cost_model(func_name::Symbol, oracle_type::DataType,
                provider::IOracleProvider = DefaultOracleProvider())

Get the cost model for a function's oracle.

# Arguments
- `func_name::Symbol`: The function name to get the cost model for
- `oracle_type::DataType`: The type of oracle to get the cost model for
- `provider::IOracleProvider`: (Optional) The oracle provider to use

# Returns
- The cost model if found, `nothing` otherwise
"""
function get_cost_model(
    func_name::Symbol,
    oracle_type::DataType,
    provider::IOracleProvider = DefaultOracleProvider(),
)
    metadata = get_oracle_metadata(func_name, oracle_type, provider)
    return metadata !== nothing ? metadata.cost : nothing
end

"""
    get_exactness(func_name::Symbol, oracle_type::DataType,
               provider::IOracleProvider = DefaultOracleProvider())

Get the exactness for a function's oracle.

# Arguments
- `func_name::Symbol`: The function name to get the exactness for
- `oracle_type::DataType`: The type of oracle to get the exactness for
- `provider::IOracleProvider`: (Optional) The oracle provider to use

# Returns
- The exactness if found, `nothing` otherwise
"""
function get_exactness(
    func_name::Symbol,
    oracle_type::DataType,
    provider::IOracleProvider = DefaultOracleProvider(),
)
    metadata = get_oracle_metadata(func_name, oracle_type, provider)
    return metadata !== nothing ? metadata.exactness : nothing
end

end # module
