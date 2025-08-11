function moreau_envelope(expr::Language.Expression, λ::Float64)
    # For now, returns the original expression.
    # TODO: Implement the Moreau envelope logic.
    return expr
end

register_strategy!(moreau_envelope)
