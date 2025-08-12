module Argo

include("language/language.jl")
include("properties/properties.jl")
include("oracles/oracles.jl")
include("data/database.jl")
include("reformulations/reformulations.jl")

using .Language, .Properties, .Oracles, .Data, .Reformulations

export recommend, @variable, @func, @property

"""
    recommend(expr::Language.Expression)

Analyzes an expression by generating reformulations and matching them against a
database of optimization methods and their performance guarantees.

Returns a sorted list of named tuples, each containing a viable method,
the formulation it applies to, and its theoretical performance bound.
"""
function recommend(expr::Language.Expression)
    # Set checks uniqueness (as long as string representations are correct).
    processed_strings = Set{String}()
    expressions_to_check = [expr]

    # fixed-point iteration to generate reformulations.
    # computes the orbit
    limit = 10
    for _ in 1:limit
        new_exprs_found = false
        current_exprs = copy(expressions_to_check)
        for e in current_exprs
            for s in Reformulations.list_strategies()
                # note: what about parametrized strategies?
                try
                    for new_e in s(e)
                        new_e_str = string(new_e)
                        if !(new_e_str in processed_strings)
                            push!(expressions_to_check, new_e)
                            push!(processed_strings, new_e_str)
                            new_exprs_found = true
                        end
                    end
                catch e
                    # Catch method errors if a strategy cannot be applied.
                    if e isa MethodError
                        continue
                    else
                        rethrow()
                    end
                end
            end
        end
        !new_exprs_found && break
    end

    # Match all unique formulations against the database
    all_results = []
    for e in expressions_to_check
        append!(all_results, Data.match_methods(e))
    end

    # Sort all collected results by their performance bound
    sort!(all_results, by=x -> x.bound)

    return all_results
end

end
