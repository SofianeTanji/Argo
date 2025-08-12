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
    props::Set{Any}
    oracles::Dict{Any,Any}
end

include("operations.jl")

# === BEGIN MACROS === #
macro variable(expr)
    name = expr.args[1]
    call = expr.args[2]
    spacename = call.args[1]
    return quote
        $(esc(name)) = Language.Variable($(QuoteNode(name)),
            Language.Space($(QuoteNode(spacename)), nothing))
    end
end

macro func(call)
    fname = call.args[1]
    calls = call.args[2:end]
    dom_calls = calls[1:end-1]
    cod_call = calls[end]

    domain_spaces_expr = Expr(:vect, [:(Language.Space($(QuoteNode(c.args[1])), nothing)) for c in dom_calls]...)
    cod_space_expr = :(Language.Space($(QuoteNode(cod_call.args[1])), nothing))

    quote
        local domain_spaces = $(domain_spaces_expr)
        local cod_space = $(cod_space_expr)
        $(esc(fname)) = Language.FunctionType($(QuoteNode(fname)), domain_spaces, cod_space, Set{Any}(),
            Dict{Any,Any}())
    end
end
# === END MACROS === #

# PUBLIC API
export Space, Variable, FunctionType, FunctionCall,
    Addition, Composition, @variable, @func

Base.show(io::IO, var::Variable) = print(io, var.name)

"""
    @function(name, domain, codomain)

A macro to define a function type.
"""
function Base.show(io::IO, expr::Expression)
    if expr.head == :call
        print(io, expr.op.name, "(", join(expr.args, ", "), ")")
    elseif expr.head == :+
        print(io, join(expr.terms, " + "))
    else
        print(io, "Expression(", expr.head, ", ", expr.op, ", ", expr.args, ")")
    end
end

end