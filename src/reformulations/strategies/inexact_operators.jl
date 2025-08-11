"""
Inexact operators: support creation of expressions with oracles that return approximate prox or gradient values.
"""
function inexact_operators(expr::Language.Expression)
    # For now, returns the original expression.
    # TODO: Implement the inexact operators logic.
    return expr
end

register_strategy!(inexact_operators)
