using Argo
using Argo.Language
using Test

@variable x::R()
@func f(R(), R())
@func g(R(), R())
expr = f(x) + g(x)
comp = f(g(x))