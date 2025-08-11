function primal_dual(expr::Language.Expression)
    # For now, returns the original expression.
    # TODO: Implement the primal-dual reformulation logic.
    return expr
end

register_strategy!(primal_dual)
