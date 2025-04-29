"""
Macros for working with oracles, providing a user-friendly interface for
registering and associating oracles with functions.
"""

"""
    @oracle func_expr oracle_expr

Register an oracle for a function.

# Arguments
- `func_expr`: The function to register the oracle for (symbol or call expression)
- `oracle_expr`: The oracle type and optional implementation function

# Examples
```julia
# Register an evaluation oracle with implementation
@oracle f EvaluationOracle(x -> x^2 + 1)

# Register just the oracle type without implementation
@oracle g EvaluationOracle()
```
"""
macro oracle(func_expr, oracle_expr)
    # Extract function name
    func_name = if func_expr isa Symbol
        func_expr
    elseif func_expr.head == :call
        func_expr.args[1]
    else
        error("Invalid function expression")
    end

    # Parse oracle expression
    if oracle_expr.head == :call
        oracle_type = oracle_expr.args[1]

        if length(oracle_expr.args) > 1
            # Implementation provided
            implementation = oracle_expr.args[2]
            return :(register_oracle!(
                $(QuoteNode(func_name)),
                $(esc(oracle_type)),
                $(esc(implementation)),
            ))
        else
            # No implementation provided
            return :(register_oracle_type!($(QuoteNode(func_name)), $(esc(oracle_type))))
        end
    else
        error("Invalid oracle expression")
    end
end

"""
    @oracles func_expr oracle_exprs...

Register multiple oracles for a function in one go.

# Arguments
- `func_expr`: The function to register the oracles for (symbol or call expression)
- `oracle_exprs...`: The oracle types and optional implementation functions

# Examples
```julia
# Register multiple oracles with implementations
@oracles f EvaluationOracle(x -> x^2 + 1) DerivativeOracle(x -> 2x)
```
"""
macro oracles(func_expr, oracle_exprs...)
    # Extract function name
    func_name = if func_expr isa Symbol
        func_expr
    elseif func_expr.head == :call
        func_expr.args[1]
    else
        error("Invalid function expression")
    end

    result = Expr(:block)

    for oracle_expr in oracle_exprs
        if oracle_expr.head == :call
            oracle_type = oracle_expr.args[1]

            if length(oracle_expr.args) > 1
                # Implementation provided
                implementation = oracle_expr.args[2]
                push!(
                    result.args,
                    :(register_oracle!(
                        $(QuoteNode(func_name)),
                        $(esc(oracle_type)),
                        $(esc(implementation)),
                    )),
                )
            else
                # No implementation provided
                push!(
                    result.args,
                    :(register_oracle_type!($(QuoteNode(func_name)), $(esc(oracle_type)))),
                )
            end
        else
            error("Invalid oracle expression")
        end
    end

    return result
end

"""
    @clear_oracles func_expr

Clear all oracles registered for a function.

# Arguments
- `func_expr`: The function to clear oracles for (symbol or call expression)

# Examples
```julia
@clear_oracles f
```
"""
macro clear_oracles(func_expr)
    # Extract function name
    func_name = if func_expr isa Symbol
        func_expr
    elseif func_expr.head == :call
        func_expr.args[1]
    else
        error("Invalid function expression")
    end

    return :(clear_oracles!($(QuoteNode(func_name))))
end
