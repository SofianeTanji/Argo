function commutativity(expr::Language.Expression)
    if expr isa Language.Addition
        sorted_terms = sort(expr.terms; by=t -> string(t))
        return Language.Addition(sorted_terms)
    else
        return expr
    end
end

register_strategy!(commutativity)
