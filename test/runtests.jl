using Argo
using Test
using Aqua
using JET

@testset "Argo.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Argo)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(Argo; target_defined_modules = true)
    end
    # Write your tests here.
end
