"""
Macro interface for oracles.
Provides convenient macros for registering and managing oracles.
"""

"""
    @oracle func oracle_expr

Register an oracle for a function.

Examples:
```julia
@oracle f EvaluationOracle(x -> x^2)
@oracle g DerivativeOracle(x -> 2*x)
@oracle h EvaluationOracle(x -> x^3, AbsoluteError(0.01))
```
"""
macro oracle(func, oracle_expr)
    # Extract function name
    func_name = isa(func, Symbol) ? func : func.args[1]

    # Parse oracle expression
    if oracle_expr.head != :call || length(oracle_expr.args) < 2
        error("Invalid oracle expression: $(string(oracle_expr))")
    end

    oracle_type = oracle_expr.args[1]
    implementation = oracle_expr.args[2]

    # Check for exactness specification
    if length(oracle_expr.args) >= 3
        exactness = oracle_expr.args[3]
        return quote
            let implementation = $(esc(implementation)), exactness = $(esc(exactness))
                oracle = $(esc(oracle_type))(implementation, exactness)
                register_oracle!($(QuoteNode(func_name)), oracle)
            end
        end
    else
        return quote
            let implementation = $(esc(implementation))
                oracle = $(esc(oracle_type))(implementation)
                register_oracle!($(QuoteNode(func_name)), oracle)
            end
        end
    end
end

"""
    @oracle func oracle_expr cost_expr

Register an oracle with a cost model.

Examples:
```julia
@oracle f EvaluationOracle(x -> x^2) linear_cost(:n)
```
"""
macro oracle(func, oracle_expr, cost_expr)
    # Extract function name
    func_name = isa(func, Symbol) ? func : func.args[1]

    # Parse oracle expression
    if oracle_expr.head != :call || length(oracle_expr.args) < 2
        error("Invalid oracle expression: $(string(oracle_expr))")
    end

    oracle_type = oracle_expr.args[1]
    implementation = oracle_expr.args[2]

    # Check for exactness specification
    if length(oracle_expr.args) >= 3
        exactness = oracle_expr.args[3]
        return quote
            let implementation = $(esc(implementation)),
                exactness = $(esc(exactness)),
                cost = $(esc(cost_expr))

                metadata = OracleMetadata(cost = cost, exactness = exactness)
                oracle = $(esc(oracle_type))(implementation, metadata)
                register_oracle!($(QuoteNode(func_name)), oracle)
            end
        end
    else
        return quote
            let implementation = $(esc(implementation)), cost = $(esc(cost_expr))

                metadata = OracleMetadata(cost = cost)
                oracle = $(esc(oracle_type))(implementation, metadata)
                register_oracle!($(QuoteNode(func_name)), oracle)
            end
        end
    end
end

"""
    @oracles func oracle_exprs...

Register multiple oracles for a function.

Examples:
```julia
@oracles f EvaluationOracle(x -> x^2) DerivativeOracle(x -> 2*x)
```
"""
macro oracles(func, oracle_exprs...)
    # Extract function name
    func_name = isa(func, Symbol) ? func : func.args[1]

    result = Expr(:block)

    for oracle_expr in oracle_exprs
        if oracle_expr.head == :call
            # Create an @oracle expression for each oracle
            oracle_macro = Expr(
                :macrocall,
                Symbol("@oracle"),
                LineNumberNode(@__LINE__, @__FILE__),
                func_name,
                oracle_expr,
            )
            push!(result.args, oracle_macro)
        else
            error("Invalid oracle expression: $(string(oracle_expr))")
        end
    end

    return result
end

"""
    @clear_oracles func

Clear all oracles for a function.

Examples:
```julia
@clear_oracles f
```
"""
macro clear_oracles(func)
    # Extract function name
    func_name = isa(func, Symbol) ? func : func.args[1]

    return :(clear_oracles!($(QuoteNode(func_name))))
end
