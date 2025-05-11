"""
    @variable name[::space]...

Create variable expressions with optional space annotations.
Without a space annotation, variables default to the real space R().

Examples:
```julia
@variable x y            # Default to R()
@variable z::R3          # z is in R^3
```
"""
macro variable(exprs...)
    result = Expr(:block)

    for expr in exprs
        # Check if this is a type annotation expr::Space
        if Meta.isexpr(expr, :(::), 2)
            # Extract the variable name and space
            var_name = expr.args[1]
            space_expr = expr.args[2]
            push!(
                result.args,
                :($(esc(var_name)) = Variable($(QuoteNode(var_name)), $(esc(space_expr)))),
            )
        else
            # No space annotation, use default R()
            push!(result.args, :($(esc(expr)) = Variable($(QuoteNode(expr)), R())))
        end
    end

    return result
end

"""
    @func name[(domain, codomain)]...

Define function symbols with domain and codomain annotations.
Without annotations, functions default to R() → R().

Examples:
```julia
@func f g                 # Default to R() → R()
@func h(R3, R)            # h: R^3 → R
@func p(Rn(:n), R())      # p: R^n → R
```
"""
macro func(exprs...)
    result = Expr(:block)

    for expr in exprs
        if Meta.isexpr(expr, :call)
            # Format: f(domain, codomain)
            fname = expr.args[1]
            if length(expr.args) >= 3
                domain = expr.args[2]
                codomain = expr.args[3]
                push!(
                    result.args,
                    :(
                        $(esc(fname)) = FunctionType(
                            $(QuoteNode(fname)),
                            $(esc(domain)),
                            $(esc(codomain)),
                        )
                    ),
                )
            elseif length(expr.args) == 2 && Meta.isexpr(expr.args[2], :tuple, 2)
                # Format: f((domain, codomain))
                domain = expr.args[2].args[1]
                codomain = expr.args[2].args[2]
                push!(
                    result.args,
                    :(
                        $(esc(fname)) = FunctionType(
                            $(QuoteNode(fname)),
                            $(esc(domain)),
                            $(esc(codomain)),
                        )
                    ),
                )
            else
                # Default to R→R
                push!(
                    result.args,
                    :($(esc(fname)) = FunctionType($(QuoteNode(fname)), R(), R())),
                )
            end
        else
            # Simple name with no type info
            push!(result.args, :($(esc(expr)) = FunctionType($(QuoteNode(expr)), R(), R())))
        end
    end

    return result
end

"""
    @expression expr

Parse a Julia expression into the Argo expression type system.
"""
macro expression(expr)
    return :(parser($(QuoteNode(expr))))
end

# Export the → operator for documentation purposes only
# We won't use it directly in macro syntax
"""→(domain, codomain)

Operator for defining function types: Domain → Codomain.
Used primarily for display.
"""
→(domain::Space, codomain::Space) = (domain, codomain)
