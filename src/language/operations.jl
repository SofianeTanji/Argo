struct FunctionCall <: Expression
    handle::Int
    func::FunctionType
    args::Vector{Expression}
    annotations::Dict{Any,Any}
    FunctionCall(handle::Int, func, args, annotations) = new(handle, func, args, annotations)
    FunctionCall(func, args, annotations) = new(next_handle(), func, args, annotations)
end
FunctionCall(func, args; annotations=Dict()) = FunctionCall(func, args, annotations)


struct Addition <: Expression
    handle::Int
    terms::Vector{Expression}
    annotations::Dict{Any,Any}
    Addition(handle::Int, terms, annotations) = new(handle, terms, annotations)
    Addition(terms, annotations) = new(next_handle(), terms, annotations)
end
Addition(terms; annotations=Dict()) = Addition(terms, annotations)

struct Composition <: Expression
    handle::Int
    outer::FunctionType
    inner::Expression
    annotations::Dict{Any,Any}
    Composition(handle::Int, outer, inner, annotations) = new(handle, outer, inner, annotations)
    Composition(outer, inner, annotations) = new(next_handle(), outer, inner, annotations)
end
Composition(outer, inner; annotations=Dict()) = Composition(outer, inner, annotations)

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
    handle::Int
    a::Expression
    b::Expression
    annotations::Dict{Any,Any}
    Subtraction(handle::Int, a, b, annotations) = new(handle, a, b, annotations)
    Subtraction(a, b, annotations) = new(next_handle(), a, b, annotations)
end
Subtraction(a, b; annotations=Dict()) = Subtraction(a, b, annotations)

struct Maximum <: Expression
    handle::Int
    terms::Vector{Expression}
    annotations::Dict{Any,Any}
    Maximum(handle::Int, terms, annotations) = new(handle, terms, annotations)
    Maximum(terms, annotations) = new(next_handle(), terms, annotations)
end
Maximum(terms; annotations=Dict()) = Maximum(terms, annotations)

struct Minimum <: Expression
    handle::Int
    terms::Vector{Expression}
    annotations::Dict{Any,Any}
    Minimum(handle::Int, terms, annotations) = new(handle, terms, annotations)
    Minimum(terms, annotations) = new(next_handle(), terms, annotations)
end
Minimum(terms; annotations=Dict()) = Minimum(terms, annotations)

struct Negation <: Expression
    handle::Int
    expr::Expression
    annotations::Dict{Any,Any}
    Negation(handle::Int, expr, annotations) = new(handle, expr, annotations)
    Negation(expr, annotations) = new(next_handle(), expr, annotations)
end
Negation(expr; annotations=Dict()) = Negation(expr, annotations)

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