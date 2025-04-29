"""
Metadata system for oracles.
This provides a way to store and retrieve information about oracles,
such as computational costs and error bounds.
"""

"""
    OracleMetadata

Stores metadata for an oracle.

Fields:
- `cost`: Computational cost model for the oracle
- `exactness`: Exactness information for the oracle
- `additional_info`: Dictionary for any additional metadata
"""
struct OracleMetadata
    cost::Union{CostModel,Nothing}
    exactness::Union{Exactness,Nothing}
    additional_info::Dict{Symbol,Any}

    # Default constructor
    OracleMetadata(;
        cost::Union{CostModel,Nothing} = nothing,
        exactness::Union{Exactness,Nothing} = nothing,
        additional_info::Dict{Symbol,Any} = Dict{Symbol,Any}(),
    ) = new(cost, exactness, additional_info)
end

# Registry for oracle metadata
const oracle_metadata_registry = Dict{Tuple{Symbol,DataType},OracleMetadata}()

"""
    register_oracle_metadata!(func_symbol::Symbol, oracle_type, metadata::OracleMetadata)

Register metadata for an oracle.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle_type`: The type of oracle (can be parameterized, type alias, or instance)
- `metadata::OracleMetadata`: The metadata to register

# Returns
- The registered metadata
"""
function register_oracle_metadata!(
    func_symbol::Symbol,
    oracle_type,
    metadata::OracleMetadata,
)
    # Extract the base type to use as the registry key
    base_type = extract_oracle_type(oracle_type)

    oracle_metadata_registry[(func_symbol, base_type)] = metadata
    return metadata
end

"""
    get_oracle_metadata(func_symbol::Symbol, oracle_type)

Get metadata for an oracle.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle_type`: The type of oracle (can be parameterized, type alias, or instance)

# Returns
- The oracle metadata if it exists, otherwise nothing
"""
function get_oracle_metadata(func_symbol::Symbol, oracle_type)
    # Extract the base type to use as the registry key
    base_type = extract_oracle_type(oracle_type)

    return get(oracle_metadata_registry, (func_symbol, base_type), nothing)
end

"""
    has_oracle_metadata(func_symbol::Symbol, oracle_type)

Check if an oracle has metadata.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle_type`: The type of oracle (can be parameterized, type alias, or instance)

# Returns
- `true` if the oracle has metadata, `false` otherwise
"""
function has_oracle_metadata(func_symbol::Symbol, oracle_type)
    # Extract the base type to use as the registry key
    base_type = extract_oracle_type(oracle_type)

    return haskey(oracle_metadata_registry, (func_symbol, base_type))
end

"""
    clear_oracle_metadata!(func_symbol::Symbol, oracle_type)

Clear metadata for an oracle.

# Arguments
- `func_symbol::Symbol`: The symbol of the function
- `oracle_type`: The type of oracle (can be parameterized, type alias, or instance)

# Returns
- Nothing
"""
function clear_oracle_metadata!(func_symbol::Symbol, oracle_type)
    # Extract the base type to use as the registry key
    base_type = extract_oracle_type(oracle_type)

    if haskey(oracle_metadata_registry, (func_symbol, base_type))
        delete!(oracle_metadata_registry, (func_symbol, base_type))
    end
    return nothing
end

"""
    clear_all_oracle_metadata!(func_symbol::Symbol)

Clear all metadata for a function.

# Arguments
- `func_symbol::Symbol`: The symbol of the function

# Returns
- Nothing
"""
function clear_all_oracle_metadata!(func_symbol::Symbol)
    for key in keys(oracle_metadata_registry)
        if key[1] == func_symbol
            delete!(oracle_metadata_registry, key)
        end
    end
    return nothing
end

# Metadata propagation functions for different expression types

"""
    propagate_metadata_addition(expr::Addition, oracle_type)

Propagate metadata for addition expressions.

# Arguments
- `expr::Addition`: The addition expression
- `oracle_type`: The type of oracle

# Returns
- The propagated metadata if possible, otherwise nothing
"""
function propagate_metadata_addition(expr::Addition, oracle_type)
    # For addition, we can add costs and take the maximum error bound
    total_cost = nothing
    max_exactness = nothing
    additional_info = Dict{Symbol,Any}()

    # Extract the base type to use for metadata lookup
    base_type = extract_oracle_type(oracle_type)

    for term in expr.terms
        if term isa FunctionCall
            metadata = get_oracle_metadata(term.name, base_type)
            if metadata === nothing
                return nothing
            end

            # Combine costs
            if metadata.cost !== nothing
                if total_cost === nothing
                    total_cost = metadata.cost
                else
                    total_cost = total_cost + metadata.cost
                end
            end

            # Take maximum error bound
            if metadata.exactness !== nothing
                if max_exactness === nothing
                    max_exactness = metadata.exactness
                elseif metadata.exactness isa Inexact && max_exactness isa Inexact
                    # Take the maximum error bound
                    if error_bound(metadata.exactness) > error_bound(max_exactness)
                        max_exactness = metadata.exactness
                    end
                elseif metadata.exactness isa Inexact
                    max_exactness = metadata.exactness
                end
            end
        else
            # For non-function call terms, try to get metadata recursively
            term_metadata = get_metadata_for_expression(term, base_type)
            if term_metadata === nothing
                return nothing
            end

            # Combine costs
            if term_metadata.cost !== nothing
                if total_cost === nothing
                    total_cost = term_metadata.cost
                else
                    total_cost = total_cost + term_metadata.cost
                end
            end

            # Take maximum error bound
            if term_metadata.exactness !== nothing
                if max_exactness === nothing
                    max_exactness = term_metadata.exactness
                elseif term_metadata.exactness isa Inexact && max_exactness isa Inexact
                    # Take the maximum error bound
                    if error_bound(term_metadata.exactness) > error_bound(max_exactness)
                        max_exactness = term_metadata.exactness
                    end
                elseif term_metadata.exactness isa Inexact
                    max_exactness = term_metadata.exactness
                end
            end
        end
    end

    # Create propagated metadata
    return OracleMetadata(
        cost = total_cost,
        exactness = max_exactness,
        additional_info = additional_info,
    )
end

"""
    propagate_metadata_composition(expr::Composition, oracle_type)

Propagate metadata for composition expressions.

# Arguments
- `expr::Composition`: The composition expression
- `oracle_type`: The type of oracle

# Returns
- The propagated metadata if possible, otherwise nothing
"""
function propagate_metadata_composition(expr::Composition, oracle_type)
    # Extract the base type to use for metadata lookup
    base_type = extract_oracle_type(oracle_type)

    # For composition (f ∘ g), metadata propagation depends on the oracle type
    if base_type == EvaluationOracle
        # For evaluation, costs add and errors compound
        outer_metadata = nothing
        inner_metadata = nothing

        if expr.outer isa FunctionCall
            outer_metadata = get_oracle_metadata(expr.outer.name, base_type)
        else
            outer_metadata = get_metadata_for_expression(expr.outer, base_type)
        end

        if expr.inner isa FunctionCall
            inner_metadata = get_oracle_metadata(expr.inner.name, base_type)
        else
            inner_metadata = get_metadata_for_expression(expr.inner, base_type)
        end

        if outer_metadata === nothing || inner_metadata === nothing
            return nothing
        end

        # Combine costs (simplistic model: just add them)
        combined_cost = nothing
        if outer_metadata.cost !== nothing && inner_metadata.cost !== nothing
            combined_cost = outer_metadata.cost + inner_metadata.cost
        end

        # Combine exactness (simplistic model: if either is inexact, the result is inexact with summed error)
        combined_exactness = Exact()
        if outer_metadata.exactness isa Inexact || inner_metadata.exactness isa Inexact
            outer_error = error_bound(outer_metadata.exactness)
            inner_error = error_bound(inner_metadata.exactness)
            combined_exactness = Inexact(outer_error + inner_error)
        end

        return OracleMetadata(
            cost = combined_cost,
            exactness = combined_exactness,
            additional_info = Dict{Symbol,Any}(),
        )
    elseif base_type == DerivativeOracle
        # For derivatives, the chain rule applies and costs/errors propagate differently
        # This is a simplified implementation
        return nothing
    else
        # For other oracle types, propagation rules may be more complex
        return nothing
    end
end

"""
    get_metadata_for_expression(expr::Expression, oracle_type)

Get metadata for an expression.

# Arguments
- `expr::Expression`: The expression to get metadata for
- `oracle_type`: The type of oracle

# Returns
- The metadata if possible, otherwise nothing
"""
function get_metadata_for_expression(expr::Expression, oracle_type)
    # Extract the base type for consistent handling
    base_type = extract_oracle_type(oracle_type)

    # Dispatch based on expression type
    if expr isa FunctionCall
        return get_oracle_metadata(expr.name, base_type)
    elseif expr isa Addition
        return propagate_metadata_addition(expr, base_type)
    elseif expr isa Composition
        return propagate_metadata_composition(expr, base_type)
    elseif expr isa Subtraction
        # Similar to addition but for subtraction
        return nothing
    elseif expr isa Maximum || expr isa Minimum
        # For max/min expressions, metadata propagation is more complex
        return nothing
    else
        # Other expression types would need their own propagation rules
        return nothing
    end
end
