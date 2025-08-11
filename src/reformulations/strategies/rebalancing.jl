function rebalance(expr::Language.Expression)
    if expr isa Language.Addition
        terms = expr.terms
        n = length(terms)
        parts = Language.Expression[]
        push!(parts, expr)
        for k in 1:n-1
            left = Language.Addition(terms[1:k])
            right = Language.Addition(terms[k+1:end])
            push!(parts, left + right)
        end
        return parts
    else
        return [expr]
    end
end

register_strategy!(rebalance)
