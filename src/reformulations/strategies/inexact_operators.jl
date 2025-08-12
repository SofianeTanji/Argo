function inexact_operators(expr::Language.Expression)
    # Not sure it is still required because now inexact prox is automatically deduced in Oracles module.
    return expr
end

register_strategy!(inexact_operators)
