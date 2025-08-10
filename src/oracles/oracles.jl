module Oracles
using ..Language
abstract type Oracle end


struct EvaluationOracle <: Oracle
    f::Function
end

struct DerivativeOracle <: Oracle
    f::Function
end

struct ProximalOracle <: Oracle
    f::Function
end

include("utils.jl")

# === BEGIN MACROS === #
macro oracle(fn, defs...)
    ft_sym = esc(fn)
    exs = Expr(:block, :(local _ft = $ft_sym))
    for d in defs
        oracle_type = d.args[1]
        handler = d.args[2]
        push!(exs.args, :(_ft.oracles[$oracle_type] = $oracle_type($handler)))
    end
    return exs
end
# === END MACROS === #

# PUBLIC API
export Oracle, EvaluationOracle, DerivativeOracle,
    get_oracle, get_oracle_for_expression, @oracle

end