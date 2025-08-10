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

include("types.jl")
include("utils.jl")

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
export Property, Convex, Smooth, StronglyConvex,
    @property, get_properties, infer_properties

end