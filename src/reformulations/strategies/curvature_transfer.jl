function curvature_transfer(expr::Language.Expression, ρ::Float64=1.0)
    if expr isa Language.Addition && length(expr.terms) >= 2
        reformulations = Language.Expression[]
        var = find_variable(expr)
        if var === nothing
            return [expr]
        end

        q_func = Language.FunctionType(
            :q,
            [var.space],
            Language.Space(:R, 1),
            Set([Properties.Quadratic(eigmin=ρ, eigmax=ρ)]),
            Dict( # Placeholders for oracles
                "EvaluationOracle" => x -> -1,
                "DerivativeOracle" => x -> x,
                "ProximalOracle" => x -> x
            ),
        )
        q_call = q_func(var)

        for i in 1:length(expr.terms)
            for j in (i+1):length(expr.terms)
                new_terms = copy(expr.terms)
                new_terms[i] = new_terms[i] + q_call
                new_terms[j] = new_terms[j] - q_call
                new_expr = Language.Addition(new_terms)
                push!(reformulations, new_expr)
            end
        end
        return reformulations
    else
        return [expr]
    end
end

register_strategy!(curvature_transfer)
