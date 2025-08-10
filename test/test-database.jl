using Argo
using Argo.Language
using Argo.Properties
using Argo.Database
using Test

@testset "Database Matching" begin
    # Define a problem: min f(x)
    @variable x::R()
    @func f(R(), R())

    # Assign properties to f that match the :smooth_stronglyconvex template
    @property f Smooth(10.0) StronglyConvex(2.0)

    # Find applicable methods and their complexities using the correct function
    matches = Database.match_methods(f(x))

    @test !isempty(matches)

    # We expect one match for this simple problem
    @test length(matches) == 1
    match = first(matches)

    # Check the fields of the returned named tuple
    @test match.template == :smooth_stronglyconvex
    @test match.method == :gradient_descent_constant_step

    # Check that constants were extracted with the correct nested structure
    @test haskey(match.constants, :smooth) && haskey(match.constants, :strongly_convex)
    @test match.constants.smooth.L == Argo.Properties.Interval(10.0)
    @test match.constants.strongly_convex.μ == Argo.Properties.Interval(2.0)

    # Check the complexity bound calculation (L.hi / μ.lo)
    # L=10.0, μ=2.0 -> bound = 10.0 / 2.0 = 5.0
    @test match.bound == 5.0
end