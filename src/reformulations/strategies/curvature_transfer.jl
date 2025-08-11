function curvature_transfer(expr::Language.Expression, ρ::Float64)
    # For now, returns the original expression.
    # TODO: Implement the curvature transfer logic.
    return expr
end

register_strategy!(curvature_transfer)
