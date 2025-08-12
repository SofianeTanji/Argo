function structure_loss(expr::Language.Expression)
    # base case
    if expr isa Language.FunctionCall || expr isa Language.Variable
        return [expr]
    end

    var = find_variable(expr)
    if var === nothing
        return [expr]
    end

    # Infer the properties of the entire expression.
    props = Properties.infer_properties(expr)

    # Infer the codomain from the expression.
    codomain = Properties.infer_codomain(expr)

    # Create a new "collapsed" function type.
    collapsed_func = Language.FunctionType(
        :collapsed_function,
        [var.space],
        codomain,
        props,
        Dict(
            "EvaluationOracle" => Oracles.get_oracle_for_expression(expr, EvaluationOracle),
            "DerivativeOracle" => Oracles.get_oracle_for_expression(expr, DerivativeOracle),
            "ProximalOracle" => Oracles.get_oracle_for_expression(expr, ProximalOracle)
        ),
    )
    collapsed_expr = collapsed_func(var)
    return [collapsed_expr]
end

register_strategy!(structure_loss)
