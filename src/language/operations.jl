struct FunctionCall <: Expression
    func::FunctionType
    args::Vector{Expression}
    annotations::Dict{Any,Any}
    FunctionCall(func, args, annotations) = new(func, args, annotations)
    FunctionCall(func, args; annotations=Dict()) = new(func, args, annotations)
end


struct Addition <: Expression
    terms::Vector{Expression}
    annotations::Dict{Any,Any}
    Addition(terms, annotations) = new(terms, annotations)
    Addition(terms; annotations=Dict()) = new(terms, annotations)
end

struct Composition <: Expression
    outer::FunctionType
    inner::Expression
    annotations::Dict{Any,Any}
    Composition(outer, inner, annotations) = new(outer, inner, annotations)
    Composition(outer, inner; annotations=Dict()) = new(outer, inner, annotations)
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
    annotations::Dict{Any,Any}
    Subtraction(a, b, annotations) = new(a, b, annotations)
    Subtraction(a, b; annotations=Dict()) = new(a, b, annotations)
end

struct Maximum <: Expression
    terms::Vector{Expression}
    annotations::Dict{Any,Any}
    Maximum(terms, annotations) = new(terms, annotations)
    Maximum(terms; annotations=Dict()) = new(terms, annotations)
end

struct Minimum <: Expression
    terms::Vector{Expression}
    annotations::Dict{Any,Any}
    Minimum(terms, annotations) = new(terms, annotations)
    Minimum(terms; annotations=Dict()) = new(terms, annotations)
end

struct Negation <: Expression
    expr::Expression
    annotations::Dict{Any,Any}
    Negation(expr, annotations) = new(expr, annotations)
    Negation(expr; annotations=Dict()) = new(expr, annotations)
end

import Base: +, -, max, min
+(a::Expression, b::Expression) = Addition([a, b], merge(a.annotations, b.annotations))
+(a::Addition, b::Expression) = Addition([a.terms..., b], merge(a.annotations, b.annotations))
+(a::Expression, b::Addition) = Addition([a, b.terms...], merge(a.annotations, b.annotations))
+(a::Addition, b::Addition) = Addition(vcat(a.terms, b.terms), merge(a.annotations, b.annotations))

-(expr::Expression) = Negation(expr; annotations=expr.annotations)
-(neg::Negation) = neg.expr  # Double negation cancels out
-(add::Addition) = Addition([-(term) for term in add.terms]; annotations=add.annotations)

-(a::Expression, b::Expression) = a + (-b)
-(a::Addition, b::Expression) = a + (-b)
-(a::Expression, b::Addition) = a + (-b)
-(a::Addition, b::Addition) = a + (-b)

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

function Base.show(io::IO, add::Addition)
    print(io, join(add.terms, " + "))
end

function Base.show(io::IO, fc::FunctionCall)
    print(io, fc.func.name, "(", join(fc.args, ", "), ")")
end

function Base.show(io::IO, comp::Composition)
    print(io, comp.outer.name, "(", comp.inner, ")")
end

function Base.show(io::IO, neg::Negation)
    print(io, "-", neg.expr)
end

function Base.show(io::IO, m::Maximum)
    print(io, "max(", join(m.terms, ", "), ")")
end

function Base.show(io::IO, m::Minimum)
    print(io, "min(", join(m.terms, ", "), ")")
end