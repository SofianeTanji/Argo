function structure_loss(expr::Language.Expression)
    # not sure it is needed anymore.
    # need to check if the rebalancing automatically handles structure loss.
    return expr
end

register_strategy!(structure_loss)
