"""
    parser(expr)

Parse a Julia expression into the Argo expression type system.

This parser converts Julia syntax into the internal expression representation.
It handles type annotations and space information within expressions.
"""

function parser(expr)
    return _parse(expr, Dict{Symbol,Any}())
end

"""
    _parse(expr, env)

Internal recursive parsing function that maintains an environment of
known variables and functions with their spaces.

Arguments:
- `expr`: The expression to parse
- `env`: A dictionary mapping symbols to their known space or function type
"""
function _parse(expr, env::Dict{Symbol,Any})
    if expr isa Symbol
        # A symbol could be a variable or function reference
        if haskey(env, expr)
            # We know about this symbol
            return env[expr]
        else
            # Unknown symbol - we can't assume its space
            error(
                "Cannot determine space for symbol '$expr'. Please use @variable or @func to declare it first.",
            )
        end
    elseif expr isa Expr
        if expr.head == :call
            func = expr.args[1]
            args = expr.args[2:end]

            # Handle each operator
            if func == :+
                parsed_args = [_parse(arg, env) for arg in args]

                # Check space compatibility
                if isempty(parsed_args)
                    error("Addition requires at least one term")
                end

                first_space = parsed_args[1].space
                for (i, arg) in enumerate(parsed_args[2:end])
                    if arg.space != first_space
                        error(
                            "Space mismatch in addition: term $(i+1) has space $(arg.space) but expected $(first_space)",
                        )
                    end
                end

                return Addition(parsed_args, first_space)

            elseif func == :-
                parsed_args = [_parse(arg, env) for arg in args]

                # Check space compatibility
                if isempty(parsed_args)
                    error("Subtraction requires at least one term")
                end

                first_space = parsed_args[1].space
                for (i, arg) in enumerate(parsed_args[2:end])
                    if arg.space != first_space
                        error(
                            "Space mismatch in subtraction: term $(i+1) has space $(arg.space) but expected $(first_space)",
                        )
                    end
                end

                return Subtraction(parsed_args, first_space)

            elseif func == :max
                parsed_args = [_parse(arg, env) for arg in args]

                # Check space compatibility
                if isempty(parsed_args)
                    error("Maximum requires at least one term")
                end

                first_space = parsed_args[1].space
                for (i, arg) in enumerate(parsed_args[2:end])
                    if arg.space != first_space
                        error(
                            "Space mismatch in maximum: term $(i+1) has space $(arg.space) but expected $(first_space)",
                        )
                    end
                end

                return Maximum(parsed_args, first_space)

            elseif func == :min
                parsed_args = [_parse(arg, env) for arg in args]

                # Check space compatibility
                if isempty(parsed_args)
                    error("Minimum requires at least one term")
                end

                first_space = parsed_args[1].space
                for (i, arg) in enumerate(parsed_args[2:end])
                    if arg.space != first_space
                        error(
                            "Space mismatch in minimum: term $(i+1) has space $(arg.space) but expected $(first_space)",
                        )
                    end
                end

                return Minimum(parsed_args, first_space)

            elseif func == :∘ || func == :compose
                if length(args) != 2
                    error("Composition requires exactly two arguments")
                end

                outer = _parse(args[1], env)
                inner = _parse(args[2], env)

                # For composition, ideally we'd check that inner.space matches outer's domain
                # and set the result.space to outer's codomain
                # This requires more type information than we might have
                if isa(outer, FunctionCall) && isa(inner, FunctionCall)
                    # We know both are function calls
                    if outer.space != inner.space
                        error(
                            "Space mismatch in composition: outer function expects $(outer.space) but inner function returns $(inner.space)",
                        )
                    end
                    return Composition(outer, inner, outer.space)
                else
                    # At least one is not a function call
                    # We can't determine space compatibility reliably
                    error(
                        "Cannot determine space compatibility for composition. Please ensure both expressions are function calls with compatible spaces.",
                    )
                end

            else
                # Handle function calls
                parsed_args = [_parse(arg, env) for arg in args]

                if func isa Symbol
                    # Case: f(x)
                    if haskey(env, func) && isa(env[func], FunctionType)
                        # We know this function's type
                        func_type = env[func]

                        # Check domain compatibility with first argument
                        if !isempty(parsed_args)
                            arg_space = parsed_args[1].space
                            if arg_space != func_type.domain
                                error(
                                    "Function $(func) expects argument in $(func_type.domain) but got $(arg_space)",
                                )
                            end
                        end

                        return FunctionCall(func, parsed_args, func_type.codomain)
                    else
                        # Unknown function - we can't determine its space
                        error(
                            "Cannot determine type for function '$func'. Please use @func to declare it first.",
                        )
                    end
                else
                    # Complex function expression like (f ∘ g)(x)
                    func_expr = _parse(func, env)

                    if isa(func_expr, Composition)
                        # Handle composition specially
                        if isempty(parsed_args)
                            error("Function call requires at least one argument")
                        end

                        # We need to check that the argument is compatible with the inner function's domain
                        # and the result space should be the outer function's codomain
                        # This would require more sophisticated space tracking
                        error(
                            "Complex function expressions like (f ∘ g)(x) require explicit space annotations.",
                        )
                    else
                        # Other complex function expression
                        error(
                            "Cannot parse complex function expression. Please break it down into simpler expressions with explicit space annotations.",
                        )
                    end
                end
            end
        elseif expr.head == :(::)
            # Handle type annotations within expressions
            base_expr = expr.args[1]
            type_expr = expr.args[2]

            # Parse the base expression
            result = _parse(base_expr, env)

            # Now handle the type annotation
            # This would require evaluating the type expression to get the space
            # For now, we'll just acknowledge it's a complex case
            error(
                "In-expression type annotations are not currently supported. Please use @variable or @func macros for type annotations.",
            )
        else
            error("Unsupported expression head: $(expr.head)")
        end
    else
        # Handle literals
        if expr isa Number
            # Numeric literals are in R
            return Literal(expr, R())
        else
            error("Unsupported literal: $(expr)")
        end
    end
end
