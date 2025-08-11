function structure_loss(expr::Language.Expression)
    # For now, returns the original expression.
    # TODO: Implement the structure loss logic.
    return expr
end

register_strategy!(structure_loss)
