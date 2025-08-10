macro variable(expr)
    name = expr.args[1]
    call = expr.args[2]
    spacename = call.args[1]
    quote
        $(esc(name)) = Language.Variable(
            $(QuoteNode(name)),
            Language.Space($(QuoteNode(spacename)), nothing),
        )
    end
end

macro func(call)
    fname = call.args[1]
    calls = call.args[2:end]
    dom_calls = calls[1:end-1]
    cod_call = calls[end]

    domain_spaces_expr = Expr(:vect, [:(Language.Space($(QuoteNode(c.args[1])), nothing)) for c in dom_calls]...)
    cod_space_expr = :(Language.Space($(QuoteNode(cod_call.args[1])), nothing))

    quote
        local domain_spaces = $(domain_spaces_expr)
        local cod_space = $(cod_space_expr)
        $(esc(fname)) = Language.FunctionType($(QuoteNode(fname)), domain_spaces, cod_space)
    end
end