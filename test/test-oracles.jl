using Argo
using Argo.Language
using Argo.Oracles
using Test

@testset "Oracles are combined properly" begin
    @variable x::R()
    @func f(R(), R())
    @func g(R(), R())

    @oracle f EvaluationOracle(x -> x^2) DerivativeOracle(x -> 2x)
    @oracle g EvaluationOracle(x -> x + 1) DerivativeOracle(x -> 1)

    f_eval = get_oracle(f, EvaluationOracle)
    @test f_eval.f(3) == 9

    g_deriv = get_oracle(g, DerivativeOracle)
    @test g_deriv.f(5) == 1

    add_expr_eval = get_oracle_for_expression(f(x) + g(x), EvaluationOracle)
    @test add_expr_eval.f(2) == (2^2 + (2 + 1))

    comp_expr_deriv = get_oracle_for_expression(f(g(x)), DerivativeOracle)
    # (g'(x) * f'(g(x))) = 1 * 2(x+1)
    @test comp_expr_deriv.f(3) == 2 * (3 + 1)

    sub_expr_eval = get_oracle_for_expression(f(x) - g(x), EvaluationOracle)
    @test sub_expr_eval.f(4) == (4^2 - (4 + 1))
end