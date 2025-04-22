"""
"""
function parser(expr)
    if expr isa Symbol
        return Variable(expr)
    elseif expr isa Expr
        if expr.head == :call
            func = expr.args[1]
            args = expr.args[2:end]

            # Handle each operator
            if func == :+
                return Addition([parser(arg) for arg in args])
            elseif func == :-
                return Subtraction([parser(arg) for arg in args])
            elseif func == :max
                return Maximum([parser(arg) for arg in args])
            elseif func == :min
                return Minimum([parser(arg) for arg in args])
            elseif func == :∘ || func == :compose
                if length(args) != 2
                    error("Composition requires exactly two arguments")
                end
                return Composition(parser(args[1]), parser(args[2]))
            else
                # Handle function calls
                if func isa Symbol # Case f(x)
                    return FunctionCall(func, [parser(arg) for arg in args])
                else
                    func_expr = parser(func)
                    if length(args) == 1 # (Case f ∘ g)(x)
                        return FunctionCall(func_expr, parser(args[1]))
                    else
                        error("Too many arguments for function call")
                    end
                end
            end
        else
            error("Invalid expression: $(expr.head)")
        end
    else
        error("Invalid expression: $(expr)")
    end
end
