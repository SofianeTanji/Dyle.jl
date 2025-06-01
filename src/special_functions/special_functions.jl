module SpecialFunctions

using ..Language
using ..Properties
using ..Oracles

# Include special function categories
include("norms.jl")

# Special function registry
const special_function_registry = Dict{Symbol,String}()

"""
    register_special_function(name::Symbol, description::String)

Register a special function with its description.

# Arguments
- `name::Symbol`: Name of the special function
- `description::String`: Description of what the function does

# Returns
- `Symbol`: The registered function name
"""
function register_special_function(name::Symbol, description::String)
    special_function_registry[name] = description
    return name
end

"""
    list_special_functions() -> Vector{Symbol}

List all registered special functions.

# Returns
- `Vector{Symbol}`: Names of all registered special functions
"""
function list_special_functions()
    return collect(keys(special_function_registry))
end

"""
    create_special_function(name::Symbol, args::Vector{Expression}) -> FunctionCall

Create a function call for a special function.

# Arguments
- `name::Symbol`: Name of the special function
- `args::Vector{Expression}`: Arguments to the function

# Returns
- `FunctionCall`: A function call expression for the special function
"""
function create_special_function(name::Symbol, args::Vector{Expression})
    # Create a FunctionType for the special function
    # For now, assume all special functions map R → R or Rⁿ → R
    input_space = length(args) == 1 ? args[1].space : R()
    output_space = R()

    func_type = FunctionType(name, input_space, output_space)
    return FunctionCall(func_type, args, output_space)
end

"""
    register_oracle_handler(func_name::Symbol, oracle_type::DataType, implementation::Function)

Register an oracle implementation for a special function.

# Arguments
- `func_name::Symbol`: Name of the special function
- `oracle_type::DataType`: Type of oracle (EvaluationOracle, DerivativeOracle, ProximalOracle)
- `implementation::Function`: The implementation function
"""
function register_oracle_handler(
    func_name::Symbol, oracle_type::DataType, implementation::Function
)
    oracle = oracle_type(implementation)
    Oracles.register_oracle!(func_name, oracle)
    return oracle
end

"""
    register_property_handler(func_name::Symbol, property_type::DataType, handler::Function)

Register a property inference handler for a special function.

# Arguments
- `func_name::Symbol`: Name of the special function
- `property_type::DataType`: Type of property to infer
- `handler::Function`: Function that infers the property
"""
function register_property_handler(
    func_name::Symbol, property_type::DataType, handler::Function
)
    # For now, we'll just register the base properties directly
    # In a more sophisticated system, this would integrate with property inference
    return nothing
end

"""
    initialize_special_functions()

Initialize all special functions by registering them.
"""
function initialize_special_functions()
    register_norm_functions()
    return nothing
end

# === PUBLIC API === #

# Registry functions
export register_special_function, list_special_functions, create_special_function
export register_oracle_handler, register_property_handler

# Special function constructors
export l1_norm, l2_norm

# Initialization
export initialize_special_functions

end
