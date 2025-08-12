function find_variable(expr::Language.Expression)
    if expr isa Language.Variable
        return expr
    elseif expr isa Language.FunctionCall
        for arg in expr.args
            var = find_variable(arg)
            if var !== nothing
                return var
            end
        end
    elseif expr isa Language.Addition
        for term in expr.terms
            var = find_variable(term)
            if var !== nothing
                return var
            end
        end
    elseif expr isa Language.Composition
        return find_variable(expr.inner)
    elseif expr isa Language.Maximum
        for term in expr.terms
            var = find_variable(term)
            if var !== nothing
                return var
            end
        end
    elseif expr isa Language.Minimum
        for term in expr.terms
            var = find_variable(term)
            if var !== nothing
                return var
            end
        end
    elseif expr isa Language.Negation
        return find_variable(expr.expr)
    elseif expr isa Language.Subtraction
        var = find_variable(expr.a)
        if var !== nothing
            return var
        end
        return find_variable(expr.b)
    end
    return nothing
end
