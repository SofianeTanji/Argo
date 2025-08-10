using Revise
using Argo
using Argo.Language
using Test

@variable x::R()
@func f(R(), R())
@func g(R(), R())
expr = f(x) + g(x)
comp = f(g(x))

using Argo.Properties
@property f Convex() Smooth(2.0)
@property g Linear(Interval(5.0, 8.0), Interval(9.0, 15.0))
@property g Linear(Interval(2.0, 6.0), Interval(3.0, 7.0))

using Argo.Oracles
@oracle f EvaluationOracle(x -> 2x) DerivativeOracle(x -> 2)
@oracle g EvaluationOracle(x -> x + 1) DerivativeOracle(x -> 1)