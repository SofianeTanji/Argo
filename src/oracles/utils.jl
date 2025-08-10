function get_oracle(ft::Language.FunctionType, ::Type{T}) where {T<:Oracle}
    return get(ft.oracles, T, nothing)
end

function get_oracle_for_expression(expr::Language.Expression, ::Type{T}) where {T<:Oracle}
    if expr isa Language.FunctionCall
        return get_oracle(expr.func, T)
    elseif expr isa Language.Addition
        oracles = [get_oracle_for_expression(t, T) for t in expr.terms]
        if any(o -> o === nothing, oracles)
            return nothing
        end
        if T === EvaluationOracle
            return EvaluationOracle(x -> sum(o.f(x) for o in oracles))
        elseif T === DerivativeOracle
            return DerivativeOracle(x -> sum(o.f(x) for o in oracles))
        end
    elseif expr isa Language.Composition
        inner = get_oracle_for_expression(expr.inner, T)
        outer = get_oracle(expr.outer, T)
        if inner !== nothing && outer !== nothing
            if T === EvaluationOracle
                return EvaluationOracle(x -> outer.f(inner.f(x)))
            elseif T === DerivativeOracle
                return nothing    # chain rule omitted in this version
            end
        end
    end
    return nothing
end