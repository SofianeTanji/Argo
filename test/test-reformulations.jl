using Argo
using Test

@testset "Reformulations" begin
    @testset "Commutativity" begin
        @variable x::R()
        @variable y::R()
        expr = y + x
        reformulated_exprs = Argo.Reformulations.commutativity(expr)
        @test reformulated_exprs isa Vector{Argo.Language.Addition}
        @test length(reformulated_exprs) == 2

        # Check that both permutations are present
        str_exprs = map(string, reformulated_exprs)
        @test "y + x" in str_exprs
        @test "x + y" in str_exprs
    end

    @testset "Rebalancing" begin
        @variable x::R()
        @variable y::R()
        @variable z::R()
        expr = x + y + z
        reformulated_exprs = Argo.Reformulations.rebalance(expr)

        @test reformulated_exprs isa Vector{Argo.Language.Expression}

        @test length(reformulated_exprs) == 4

        # we expect to find x + (y + z) in the results.
        found = false
        for e in reformulated_exprs
            if e isa Argo.Language.Addition && length(e.terms) == 2
                if e.terms[1] == x && e.terms[2] isa Argo.Language.Addition
                    nested_add = e.terms[2]
                    if nested_add.terms[1] == y && nested_add.terms[2] == z
                        found = true
                        break
                    end
                end
            end
        end
        @test found
    end
end
