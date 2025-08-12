using Combinatorics

function commutativity(expr::Language.Expression)
    if expr isa Language.Addition
        if length(expr.terms) <= 1
            return [expr]
        end

        permuted_term_sets = permutations(expr.terms)

        return [Language.Addition(p) for p in permuted_term_sets]
    else
        return [expr]
    end
end

register_strategy!(commutativity)
