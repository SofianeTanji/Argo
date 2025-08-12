function rebalance(expr::Language.Expression)
    if !(expr isa Language.Addition)
        return [expr]
    end

    terms = expr.terms
    n = length(terms)
    if n <= 1
        return [expr]
    end

    results = Language.Expression[]
    # Generate all 2^(n-1) partitions
    for i in 0:2^(n-1)-1
        new_terms = []
        current_sum = terms[1]
        for j in 1:(n-1)
            if (i >> (j - 1)) & 1 == 1
                # Split point
                push!(new_terms, current_sum)
                current_sum = terms[j+1]
            else
                # Merge point
                current_sum = current_sum + terms[j+1]
            end
        end
        push!(new_terms, current_sum)

        if length(new_terms) > 1
            push!(results, Language.Addition(new_terms))
        else
            push!(results, new_terms[1])
        end
    end

    return results
end

register_strategy!(rebalance)