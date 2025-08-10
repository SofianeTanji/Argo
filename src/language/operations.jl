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
    if length(args) == 1
        arg = args[1]
        if arg isa FunctionCall || arg isa Composition
            return Composition(ft, arg)
        end
    end
    return FunctionCall(ft, collect(args))
end

struct Subtraction <: Expression
    a::Expression
    b::Expression
end

struct Maximum <: Expression
    terms::Vector{Expression}
end

struct Minimum <: Expression
    terms::Vector{Expression}
end

struct Negation <: Expression
    expr::Expression
end

import Base: +, -, max, min
+(a::Expression, b::Expression) = Addition([a, b])
+(a::Addition, b::Expression) = Addition([a.terms..., b])
+(a::Expression, b::Addition) = Addition([a, b.terms...])
+(a::Addition, b::Addition) = Addition(vcat(a.terms, b.terms))

-(expr::Expression) = Negation(expr)
-(neg::Negation) = neg.expr  # Double negation cancels out
-(add::Addition) = Addition([-(term) for term in add.terms])

-(a::Expression, b::Expression) = Addition([a, -b])
-(a::Addition, b::Expression) = Addition([a.terms..., -b])
-(a::Expression, b::Addition) = Addition([a, [-(term) for term in b.terms]...])
-(a::Addition, b::Addition) = Addition([a.terms..., [-(term) for term in b.terms]...])

function max(a::Expression, b::Expression)
    if a isa Maximum && b isa Maximum
        return Maximum(vcat(a.terms, b.terms))
    elseif a isa Maximum
        return Maximum(vcat(a.terms, [b]))
    elseif b isa Maximum
        return Maximum(vcat([a], b.terms))
    else
        return Maximum([a, b])
    end
end

function min(a::Expression, b::Expression)
    if a isa Minimum && b isa Minimum
        return Minimum(vcat(a.terms, b.terms))
    elseif a isa Minimum
        return Minimum(vcat(a.terms, [b]))
    elseif b isa Minimum
        return Minimum(vcat([a], b.terms))
    else
        return Minimum([a, b])
    end
end