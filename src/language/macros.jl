macro variable(names...)
    result = Expr(:block)
    for name in names
        push!(result.args, :($(esc(name)) = Variable($(QuoteNode(name)))))
    end
    return result
end

macro func(names...)
    result = Expr(:block)
    for name in names
        push!(result.args, :($(esc(name)) = $(QuoteNode(name))))
    end
    return result
end

macro expression(expr)
    return :(parser($(QuoteNode(expr))))
end
