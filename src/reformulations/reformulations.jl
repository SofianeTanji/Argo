module Reformulations

using ..Language
using ..Properties
using ..Oracles

const STRATEGIES = Function[]

function register_strategy!(fun::Function)
    push!(STRATEGIES, fun)
    return fun
end

list_strategies() = copy(STRATEGIES)

function load_strategies!(dir::AbstractString)
    if isdir(dir)
        for (root, _, files) in walkdir(dir)
            for file in files
                if endswith(file, ".jl")
                    include(joinpath(root, file))
                end
            end
        end
    end
end

function __init__()
    local dir = dirname(@__FILE__)
    load_strategies!(joinpath(dir, "strategies"))
end

export list_strategies, register_strategy!

end