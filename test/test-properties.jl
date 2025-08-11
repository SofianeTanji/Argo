using Argo
using Argo.Language
using Argo.Properties
using Test

@testset "Properties are combined correctly" begin
    @variable x::R()
    @func f(R(), R())
    @func g(R(), R())

    @property f Convex() Smooth(1.0)
    @property g StronglyConvex(0.5)

    @test Convex() in get_properties(f)
    @test Smooth(1.0) in get_properties(f)

    inferred_add = infer_properties(f(x) + g(x))
    @test StronglyConvex(0.5) in inferred_add

    @property g Linear(2.0, 3.0)
    inferred_comp = infer_properties(f(g(x)))
    @test Smooth(Interval(1.0 + 2.0^2, 1.0 + 3.0^2)) in inferred_comp

    inferred_sub = infer_properties(f(x) - f(x))
    @test isempty(inferred_sub)

    # Test for (Smooth, Lipschitz) ∘ Lipschitz => Smooth
    @property f Smooth(2.0) Lipschitz(3.0)
    @property g Lipschitz(4.0)
    inferred_comp_lip = infer_properties(f(g(x)))
    @test Smooth(32.0) in inferred_comp_lip
end