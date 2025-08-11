module Properties
using ..Language
abstract type Property end

struct Interval{T<:Real}
    lo::T
    hi::T
    function Interval{T}(lo::T, hi::T) where {T<:Real}
        lo <= hi || error("Invalid interval: lower bound exceeds upper bound")
        new{T}(lo, hi)
    end
end
Interval(x::Real) = Interval{typeof(x)}(x, x)
Interval(lo::Real, hi::Real) = Interval{typeof(lo)}(lo, hi)
import Base: +, -, abs
function +(i1::Interval{T}, i2::Interval{T}) where {T<:Real}
    return Interval{T}(i1.lo + i2.lo, i1.hi + i2.hi)
end
function -(i1::Interval{T}, i2::Interval{T}) where {T<:Real}
    return Interval{T}(i1.lo - i2.hi, i1.hi - i2.lo)
end
function abs(i::Interval{T}) where {T<:Real}
    if i.lo <= 0 <= i.hi
        return Interval{T}(zero(T), max(abs(i.lo), abs(i.hi)))
    else
        return Interval{T}(min(abs(i.lo), abs(i.hi)), max(abs(i.lo), abs(i.hi)))
    end
end
negate_interval(i::Interval{T}) where {T<:Real} = Interval{T}(-i.hi, -i.lo)
min_interval(i1::Interval{T}, i2::Interval{T}) where {T<:Real} =
    Interval{T}(min(i1.lo, i2.lo), min(i1.hi, i2.hi))
max_interval(i1::Interval{T}, i2::Interval{T}) where {T<:Real} =
    Interval{T}(max(i1.lo, i2.lo), max(i1.hi, i2.hi))

include("types.jl")
include("utils.jl")
include("algebra.jl")

# === BEGIN MACROS === #
macro property(fn, props...)
    ft_sym = esc(fn)
    exs = Expr(:block, :(local _ft = $ft_sym))
    for p in props
        prop_type = p.args[1]
        args = p.args[2:end]
        call_expr = Expr(:call, esc(Expr(:., :Properties, QuoteNode(prop_type))), args...)
        push!(exs.args, :(set_property!(_ft, $call_expr)))
    end
    return exs
end
# === END MACROS === #

# PUBLIC API
export Property, Convex, Smooth, StronglyConvex, Hypoconvex,
    Lipschitz,
    MonotonicallyIncreasing,
    Linear,
    Quadratic,
    Interval,
    @property, get_properties, infer_properties

end