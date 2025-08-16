module Argo

include("language/language.jl")
include("properties/properties.jl")
include("oracles/oracles.jl")
include("data/database.jl")
include("reformulations/reformulations.jl")

using .Language, .Properties, .Oracles, .Database, .Reformulations

export recommend, @variable, @func, @property

"""
    recommend(expr::Language.Expression)

Analyzes an expression by generating reformulations and matching them against a
database of optimization methods and their performance guarantees.

Returns a sorted list of named tuples, each containing a viable method,
the formulation it applies to, and its theoretical performance bound.
"""
function recommend(expr::Language.Expression)
    processed_strings = Set{String}()
    queue = [expr] # FIFO
    discovered = [expr]
    push!(processed_strings, string(expr))

    while !isempty(queue)
        current = popfirst!(queue)
        for s in Reformulations.list_strategies()
            # note: what about parametrized strategies?
            try
                for new_e in s(current)
                    new_e_str = string(new_e)
                    if !(new_e_str in processed_strings)
                        push!(queue, new_e)
                        push!(discovered, new_e)
                        push!(processed_strings, new_e_str)
                    end
                end
            catch err
                if err isa MethodError
                    continue
                else
                    rethrow()
                end
            end
        end
    end

    all_results = []
    for e in discovered
        append!(all_results, Database.match_methods(e))
    end

    sort!(all_results, by=x -> x.bound)

    return all_results, discovered
end

end
