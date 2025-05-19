# removed invalid import; get_oracle_for_expression is defined in this module via include("combinations.jl")

# forward non-Symbol function names to recursive oracle lookup
function get_oracle(func::Expression, oracle_type::DataType)
    return get_oracle_for_expression(func, oracle_type)
end

# ===== Oracle Registry =====

# Main registry: maps (function_symbol, oracle_type) to oracle instances
const oracle_registry = Dict{Tuple{Symbol,DataType},Oracle}()

# Special combinations registry for operations that can't follow standard rules
const special_combination_registry = Dict{Tuple{DataType,Vector{Symbol},DataType},Function}()

"""
    register_oracle!(func::Symbol, oracle::Oracle)

Register an oracle for a function.
"""
function register_oracle!(func::Symbol, oracle::Oracle)
    oracle_type = typeof(oracle)
    oracle_registry[(func, oracle_type)] = oracle
    return oracle
end

"""
    get_oracle(func::Symbol, oracle_type::DataType)

Get an oracle for a function.
"""
# Note: Symbol dispatch is still needed for function-symbol lookups
function get_oracle(func::Symbol, oracle_type::DataType)
    return get(oracle_registry, (func, oracle_type), nothing)
end

"""
    has_oracle(func::Symbol, oracle_type::DataType)

Check if a function has an oracle of the specified type.
"""
function has_oracle(func::Symbol, oracle_type::DataType)
    return haskey(oracle_registry, (func, oracle_type))
end

"""
    clear_oracles!(func::Symbol)

Clear all oracles for a function.
"""
function clear_oracles!(func::Symbol)
    for key in collect(keys(oracle_registry))
        if key[1] == func
            delete!(oracle_registry, key)
        end
    end
    return nothing
end

# ===== Special Combinations =====

"""
    register_special_combination(op_type::DataType, funcs::Vector{Symbol},
                              oracle_type::DataType, handler::Function)

Register a special handler for combining oracles in specific expressions.
"""
function register_special_combination(
    op_type::DataType, funcs::Vector{Symbol}, oracle_type::DataType, handler::Function
)
    special_combination_registry[(op_type, funcs, oracle_type)] = handler
    return handler
end

"""
    get_special_combination(op_type::DataType, funcs::Vector{Symbol},
                         oracle_type::DataType)

Get a special combination handler if one exists.
"""
function get_special_combination(
    op_type::DataType, funcs::Vector{Symbol}, oracle_type::DataType
)
    return get(special_combination_registry, (op_type, funcs, oracle_type), nothing)
end

"""
    has_special_combination(op_type::DataType, funcs::Vector{Symbol},
                         oracle_type::DataType)

Check if a special combination handler exists.
"""
function has_special_combination(
    op_type::DataType, funcs::Vector{Symbol}, oracle_type::DataType
)
    return haskey(special_combination_registry, (op_type, funcs, oracle_type))
end
