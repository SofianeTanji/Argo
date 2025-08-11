function monotone_transform(expr::Language.Expression)
    # For now, returns the original expression.
    # TODO: Implement the monotone transformation logic.
    return expr
end

register_strategy!(monotone_transform)
