using Argo
using Argo.Language
using Argo.Properties
using Argo.Oracles
using Test

@variable x::R()
@func f(R(), R())
@func g(R(), R())
expr = f(x) + g(x)
comp = f(g(x))

@property f Convex() Smooth(2.0)
@property g Linear(Interval(5.0, 8.0), Interval(9.0, 15.0))
@property g Linear(Interval(2.0, 6.0), Interval(3.0, 7.0))

@oracle f EvaluationOracle(x -> 2x) DerivativeOracle(x -> 2)
@oracle g EvaluationOracle(x -> x + 1) DerivativeOracle(x -> 1)

@testset "Argo Language Tests" begin
    @testset "Expression Evaluation" begin
        @test expr isa Language.Addition
        @test comp isa Language.Composition
    end
end

@testset "Argo Properties" begin
    @test Convex() in get_properties(f)
    @test Smooth(2.0) in get_properties(f)

    g_props = get_properties(g)
    @test length(g_props) == 1
    g_linear_prop = first(g_props)
    @test g_linear_prop isa Properties.Linear
    @test g_linear_prop.eigmin == Properties.Interval(2.0, 6.0)
    @test g_linear_prop.eigmax == Properties.Interval(3.0, 7.0)
end

@testset "Argo Oracles" begin
    f_eval = get_oracle(f, EvaluationOracle)
    f_deriv = get_oracle(f, DerivativeOracle)
    @test f_eval isa Oracles.EvaluationOracle
    @test f_deriv isa Oracles.DerivativeOracle
    @test f_eval.f(3.0) == 6.0
    @test f_deriv.f(3.0) == 2.0

    g_eval = get_oracle(g, EvaluationOracle)
    g_deriv = get_oracle(g, DerivativeOracle)
    @test g_eval.f(3.0) == 4.0
    @test g_deriv.f(3.0) == 1.0
end
