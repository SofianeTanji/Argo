struct Convex <: Property end

struct Smooth <: Property
    interval::Interval{<:Real}
end
Smooth(L::Real) = Smooth(Interval(L))
Smooth(lo::Real, hi::Real) = Smooth(Interval(lo, hi))

struct StronglyConvex <: Property
    interval::Interval{<:Real}
end
StronglyConvex(μ::Real) = StronglyConvex(Interval(μ))
StronglyConvex(lo::Real, hi::Real) = StronglyConvex(Interval(lo, hi))

struct Hypoconvex <: Property
    interval::Interval{<:Real}
end
Hypoconvex(μ::Real) = Hypoconvex(Interval(μ))
Hypoconvex(lo::Real, hi::Real) = Hypoconvex(Interval(lo, hi))

struct Lipschitz <: Property
    interval::Interval{<:Real}
end
Lipschitz(L::Real) = Lipschitz(Interval(L))
Lipschitz(lo::Real, hi::Real) = Lipschitz(Interval(lo, hi))

struct MonotonicallyIncreasing <: Property end
struct Linear <: Property
    eigmin::Union{Interval,Nothing}
    eigmax::Union{Interval,Nothing}
end
Linear(; eigmin=nothing, eigmax=nothing) = Linear(eigmin, eigmax)
Linear(eigmin::Real, eigmax::Real) = Linear(Interval(eigmin), Interval(eigmax))
Linear(eigmin::Real) = Linear(Interval(eigmin), nothing)

struct Quadratic <: Property
    eigmin::Union{Interval,Nothing}
    eigmax::Union{Interval,Nothing}
end
Quadratic(; eigmin=nothing, eigmax=nothing) = Quadratic(eigmin, eigmax)
Quadratic(eigmin::Real, eigmax::Real) = Quadratic(Interval(eigmin), Interval(eigmax))
Quadratic(eigmin::Real) = Quadratic(Interval(eigmin), nothing)
