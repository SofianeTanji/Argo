module Language
abstract type Expression end

struct Space
    name::Symbol
    dim::Union{Int,Nothing}
end

struct Variable <: Expression
    name::Symbol
    space::Space
end

struct FunctionType
    name::Symbol
    domain::Vector{Space}
    codomain::Space
end

include("operations.jl")
include("macros.jl")

export Space, Variable, FunctionType, FunctionCall,
    Addition, Composition, @variable, @func
end