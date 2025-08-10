struct FunctionCall <: Expression
    func::FunctionType
    args::Vector{Expression}
end


struct Addition <: Expression
    terms::Vector{Expression}
end

struct Composition <: Expression
    outer::FunctionType
    inner::Expression
end

function (ft::FunctionType)(args::Expression...)
    if length(args) == 1 && isa(args[1], FunctionCall)
        return Composition(ft, args[1])
    else
        return FunctionCall(ft, collect(args))

    end
end

import Base: +
+(a::Expression, b::Expression) = Addition([a, b])
+(a::Addition, b::Expression) = Addition([a.terms..., b])
+(a::Expression, b::Addition) = Addition([a, b.terms...])
+(a::Addition, b::Addition) = Addition(vcat(a.terms, b.terms))
