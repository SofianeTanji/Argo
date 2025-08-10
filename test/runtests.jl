using Argo
using Test
using Aqua
using JET

@testset "Argo.jl" begin
    # @testset "Code quality (Aqua.jl)" begin
    #     Aqua.test_all(Argo)
    # end
    # @testset "Code linting (JET.jl)" begin
    #     JET.test_package(Argo; target_defined_modules=true)
    # end
    # Write your tests here.
    for (root, dirs, files) in walkdir(@__DIR__)
        for file in files
            if isnothing(match(r"^test-.*\.jl$", file))
                continue
            end
            title = titlecase(replace(splitext(file[6:end])[1], "-" => " "))
            @testset "$title" begin
                include(file)
            end
        end
    end
end
