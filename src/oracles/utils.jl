function get_oracle(ft::Language.FunctionType, ::Type{T}) where {T<:Oracle}
    return get(ft.oracles, T, nothing)
end

function get_oracle_for_expression(expr::Language.Expression, ::Type{T}) where {T<:Oracle} # Combination logic is done here.
    if expr isa Language.FunctionCall
        if T === InexactProximalOracle
            prox = get_oracle(expr.func, ProximalOracle)
            if prox !== nothing
                return InexactProximalOracle(prox.f, nothing, nothing)
            end
            return get_oracle(expr.func, InexactProximalOracle)
        else
            return get_oracle(expr.func, T)
        end
    elseif expr isa Language.Negation
        inner_oracle = get_oracle_for_expression(expr.expr, T)
        if inner_oracle === nothing
            return nothing
        end
        if T === EvaluationOracle
            return EvaluationOracle(x -> -inner_oracle.f(x))
        elseif T === DerivativeOracle
            return DerivativeOracle(x -> -inner_oracle.f(x))
        else
            return nothing
        end
    elseif expr isa Language.Addition # Sum Rule.
        children = [get_oracle_for_expression(t, T) for t in expr.terms]
        if any(o -> o === nothing, children)
            return nothing
        end
        if T === EvaluationOracle
            return EvaluationOracle(x -> sum(o.f(x) for o in children))
        elseif T === DerivativeOracle
            return DerivativeOracle(x -> sum(o.f(x) for o in children))
        elseif T === ProximalOracle
            # Requires splitting algorithms yielding an inexact prox.
            return nothing
        elseif T === InexactProximalOracle
            # Return a generic inexact prox for the sum.
            return InexactProximalOracle( # Placeholder before recommendation.
                x -> error("Not yet implemented."),
                nothing,
                nothing,
            )
        else
            return nothing
        end

    elseif expr isa Language.Subtraction # Sum Rule.
        # Combine oracles for subtraction by difference.
        left = get_oracle_for_expression(expr.a, T)
        right = get_oracle_for_expression(expr.b, T)
        if left === nothing || right === nothing
            return nothing
        end
        if T === EvaluationOracle
            return EvaluationOracle(x -> left.f(x) - right.f(x))
        elseif T === DerivativeOracle
            return DerivativeOracle(x -> left.f(x) - right.f(x))
        elseif T === ProximalOracle || T === InexactProximalOracle
            return nothing
        else
            return nothing
        end

    elseif expr isa Language.Maximum # Only Evaluation is available.
        children = [get_oracle_for_expression(t, T) for t in expr.terms]
        if any(o -> o === nothing, children)
            return nothing
        end
        if T === EvaluationOracle
            return EvaluationOracle(x -> maximum(o.f(x) for o in children))
        else
            # Derivatives or proximals of maxima require subgradient calculus.
            return nothing
        end

    elseif expr isa Language.Minimum # Only Evaluation is available.
        children = [get_oracle_for_expression(t, T) for t in expr.terms]
        if any(o -> o === nothing, children)
            return nothing
        end
        if T === EvaluationOracle
            return EvaluationOracle(x -> minimum(o.f(x) for o in children))
        else
            return nothing
        end

    elseif expr isa Language.Composition # Eval easy, Derivative via chain rule.
        inner_eval = get_oracle_for_expression(expr.inner, EvaluationOracle)
        if inner_eval === nothing
            return nothing
        end
        if T === EvaluationOracle
            outer_eval = get_oracle(expr.outer, EvaluationOracle)
            if outer_eval === nothing
                return nothing
            end
            return EvaluationOracle(x -> outer_eval.f(inner_eval.f(x)))
        elseif T === DerivativeOracle
            # (f ∘ g)'(x) = g'(x) * f'(g(x))
            inner_deriv = get_oracle_for_expression(expr.inner, DerivativeOracle)
            outer_deriv = get_oracle(expr.outer, DerivativeOracle)
            if inner_deriv === nothing || outer_deriv === nothing
                return nothing
            end
            return DerivativeOracle(x -> inner_deriv.f(x) * outer_deriv.f(inner_eval.f(x)))
        elseif T === ProximalOracle || T === InexactProximalOracle # hard.
            return nothing
        else
            return nothing
        end
    else
        return nothing
    end
end