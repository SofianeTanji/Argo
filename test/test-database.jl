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

    # Test that we can match a method
    results = match_methods(f(x))
    @test length(results) == 1
    @test results[1].method == :gradient_descent_constant_step
end

@testset "Sorting" begin
    # Create a dummy template and two methods with different bounds
    t_sort = Template(
        :t_sort,
        1,
        parts -> begin
            length(parts) == 1 &&
                any(p -> p isa Properties.Smooth, parts[1])
        end,
        parts -> begin
            Lprop = first(filter(p -> p isa Properties.Smooth, parts[1]))
            return (smooth=(L=Lprop.interval,),)
        end,
    )
    m_fast = Argo.Database.Method(
        :FastMethod,
        [:t_sort],
        p -> 1.0, # Faster
    )
    m_mid = Argo.Database.Method(
        :MidMethod,
        [:t_sort],
        p -> 5.0, # Mid-speed
    )
    m_slow = Argo.Database.Method(
        :SlowMethod,
        [:t_sort],
        p -> 10.0, # Slower
    )

    # Register them
    empty!(Argo.Database.METHODS)
    empty!(Argo.Database.TEMPLATES)
    register_template!(t_sort)
    register_method!(m_mid)
    register_method!(m_slow)
    register_method!(m_fast)

    # Define a problem that matches the template
    @variable x::R()
    @func f(R(), R())
    @property f Smooth(1.0)

    # Match and test order
    results = match_methods(f(x))
    @test length(results) == 3
    @test results[1].method == :FastMethod
    @test results[2].method == :MidMethod
    @test results[3].method == :SlowMethod
end