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

# Register an inexact evaluation oracle
@oracle g DerivativeOracle(Inexact(0.01))(x -> 2*x + 0.01*randn())

# Register just the oracle type without implementation
@oracle h EvaluationOracle()
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

        # Case 1: No arguments - just the oracle type
        if length(oracle_expr.args) == 1
            return quote
                let oracle_instance = $(esc(oracle_type))()
                    register_oracle_type!($(QuoteNode(func_name)), oracle_instance)
                end
            end

            # Case 2: With arguments
        elseif length(oracle_expr.args) == 2
            arg = oracle_expr.args[2]

            # Case 2a: Implementation function - EvaluationOracle(x -> x^2)
            if arg isa Expr && arg.head == :->
                return quote
                    let oracle_instance = $(esc(oracle_type))(),
                        implementation = $(esc(arg))

                        register_oracle!(
                            $(QuoteNode(func_name)),
                            oracle_instance,
                            implementation,
                        )
                    end
                end

                # Case 2b: Inexact specification - EvaluationOracle(Inexact(0.01))
            elseif arg isa Expr && arg.head == :call
                return quote
                    let oracle_instance = $(esc(oracle_type))($(esc(arg)))
                        register_oracle_type!($(QuoteNode(func_name)), oracle_instance)
                    end
                end

                # Case 2c: Other argument (treat as implementation)
            else
                return quote
                    let oracle_instance = $(esc(oracle_type))(),
                        implementation = $(esc(arg))

                        register_oracle!(
                            $(QuoteNode(func_name)),
                            oracle_instance,
                            implementation,
                        )
                    end
                end
            end
        end

        # Case 3: Inexact with implementation
        # This handles call expressions like: DerivativeOracle(Inexact(AbsoluteError(0.1)))(x -> 2*x)
        # which get parsed in a special way by Julia's macro system
        if length(oracle_expr.args) >= 2 &&
           isa(oracle_expr.args[1], Symbol) &&
           isa(oracle_expr.args[2], Expr) &&
           oracle_expr.args[2].head == :call

            # Extract the exactness specification
            oracle_name = oracle_expr.args[1]
            exactness_expr = oracle_expr.args[2]

            # Implementation might be the 3rd argument or not present
            if length(oracle_expr.args) >= 3 &&
               isa(oracle_expr.args[3], Expr) &&
               oracle_expr.args[3].head == :->
                implementation = oracle_expr.args[3]

                return quote
                    let oracle_instance = $(esc(oracle_name))($(esc(exactness_expr))),
                        implementation = $(esc(implementation))

                        register_oracle!(
                            $(QuoteNode(func_name)),
                            oracle_instance,
                            implementation,
                        )
                    end
                end
            else
                # No implementation
                return quote
                    let oracle_instance = $(esc(oracle_name))($(esc(exactness_expr)))
                        register_oracle_type!($(QuoteNode(func_name)), oracle_instance)
                    end
                end
            end
        end
    end

    # If we get here, the oracle expression format is not recognized
    error("Invalid oracle expression: $(string(oracle_expr))")
end

"""
    @oracle func_expr oracle_expr cost_expr

Register an oracle for a function with a cost model.

# Arguments
- `func_expr`: The function to register the oracle for (symbol or call expression)
- `oracle_expr`: The oracle type and optional implementation function
- `cost_expr`: The cost model expression

# Examples
```julia
# Register an evaluation oracle with a cost model
@oracle f EvaluationOracle(x -> x^2 + 1) linear_cost(:n)
```
"""
macro oracle(func_expr, oracle_expr, cost_expr)
    # Extract function name
    func_name = if func_expr isa Symbol
        func_expr
    elseif func_expr.head == :call
        func_expr.args[1]
    else
        error("Invalid function expression")
    end

    # First register the oracle
    register_expr = Expr(
        :macrocall,
        Symbol("@oracle"),
        LineNumberNode(@__LINE__, @__FILE__),
        func_name,
        oracle_expr,
    )

    # Then register the cost model
    cost_registration = quote
        let base_type = extract_oracle_type($(esc(oracle_expr.args[1]))),
            cost = $(esc(cost_expr))

            register_oracle_metadata!(
                $(QuoteNode(func_name)),
                base_type,
                OracleMetadata(cost = cost),
            )
        end
    end

    return quote
        $register_expr
        $cost_registration
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
            # We reuse the @oracle macro logic for each oracle
            oracle_macro_expr = Expr(
                :macrocall,
                Symbol("@oracle"),
                LineNumberNode(@__LINE__, @__FILE__),
                func_name,
                oracle_expr,
            )
            push!(result.args, oracle_macro_expr)
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
