# === BEGIN NEGATION === #
negate_property(p::Convex) = nothing  # -f is concave
negate_property(p::StronglyConvex) = nothing  # -f is strongly concave
negate_property(p::Hypoconvex) = nothing
negate_property(p::Smooth) = Smooth(p.interval)
negate_property(p::Lipschitz) = Lipschitz(p.interval)
negate_property(p::MonotonicallyIncreasing) = nothing  # - f monotonically decreasing
negate_property(p::Linear) = begin
    if p.eigmin !== nothing && p.eigmax !== nothing
        new_min = negate_interval(p.eigmax)
        new_max = negate_interval(p.eigmin)
        return Linear(new_min, new_max)
    else
        return nothing
    end
end
negate_property(p::Quadratic) = begin
    if p.eigmin !== nothing && p.eigmax !== nothing
        new_min = negate_interval(p.eigmax)
        new_max = negate_interval(p.eigmin)
        return Quadratic(new_min, new_max)
    else
        return nothing
    end
end
# === END NEGATION === #
# === BEGIN ADDITION === #
function combine_addition(p1::Property, p2::Property)
    return nothing  # fallback
end
combine_addition(::Convex, ::Convex) = Convex()
combine_addition(::Convex, p2::StronglyConvex) = p2
combine_addition(p1::StronglyConvex, ::Convex) = p1
combine_addition(p1::StronglyConvex, p2::StronglyConvex) = StronglyConvex(p1.interval + p2.interval)
combine_addition(::Convex, p2::Hypoconvex) = p2
combine_addition(p1::Hypoconvex, ::Convex) = p1
combine_addition(::Convex, p2::Smooth) = Hypoconvex(p2.interval) # Smooth => Hypoconvex
combine_addition(p1::Smooth, p2::Convex) = combine_addition(p2, p1)
combine_addition(p1::Smooth, p2::Smooth) = Smooth(p1.interval + p2.interval)
function combine_addition(p1::StronglyConvex, p2::Smooth)
    diff = p1.interval - p2.interval
    # If the difference remains positive we retain strong convexity
    if diff.lo > 0
        return StronglyConvex(diff)
    elseif diff.lo == 0
        return Convex()
    else
        return Hypoconvex(abs(diff))
    end
end
combine_addition(p1::Smooth, p2::StronglyConvex) = combine_addition(p2, p1)
combine_addition(p1::Hypoconvex, p2::Smooth) = Hypoconvex(p1.interval + p2.interval)
combine_addition(p1::Smooth, p2::Hypoconvex) = combine_addition(p2, p1)
combine_addition(p1::Lipschitz, p2::Lipschitz) = Lipschitz(p1.interval + p2.interval)
function combine_addition(p1::Linear, p2::Linear)
    # Combine eigenvalue intervals if both are known
    eigmin = nothing
    eigmax = nothing
    if p1.eigmin !== nothing && p2.eigmin !== nothing && p2.eigmax !== nothing
        eigmin = Interval(p1.eigmin.lo + p2.eigmin.lo,
            p1.eigmin.hi + p2.eigmax.hi)
    end
    if p1.eigmax !== nothing && p2.eigmin !== nothing && p2.eigmax !== nothing
        eigmax = Interval(p1.eigmax.lo + p2.eigmin.lo,
            p1.eigmax.hi + p2.eigmax.hi)
    end
    return Linear(eigmin, eigmax)
end

function combine_addition(p1::Quadratic, p2::Quadratic)
    # Combine eigenvalue intervals if both are known
    eigmin = nothing
    eigmax = nothing
    if p1.eigmin !== nothing && p2.eigmin !== nothing && p2.eigmax !== nothing
        eigmin = Interval(p1.eigmin.lo + p2.eigmin.lo,
            p1.eigmin.hi + p2.eigmax.hi)
    end
    if p1.eigmax !== nothing && p2.eigmin !== nothing && p2.eigmax !== nothing
        eigmax = Interval(p1.eigmax.lo + p2.eigmin.lo,
            p1.eigmax.hi + p2.eigmax.hi)
    end
    return Quadratic(eigmin, eigmax)
end
function combine_addition(p1::Quadratic, p2::StronglyConvex)
    # Add quadratic (eigmin) and strongly convex: shift eigmin
    if p1.eigmin === nothing
        return combine_addition(Convex(), p2)
    end
    result_interval = p1.eigmin + p2.interval
    if result_interval.lo > 0
        return StronglyConvex(result_interval)
    elseif result_interval.lo == 0
        return Convex()
    else
        return Hypoconvex(abs(result_interval))
    end
end
combine_addition(p1::StronglyConvex, p2::Quadratic) = combine_addition(p2, p1)
function combine_addition(p1::Quadratic, p2::Hypoconvex)
    if p1.eigmin === nothing
        return combine_addition(Convex(), p2)
    end
    # Determine whether quadratic eigenvalues dominate hypoconvexity
    if p1.eigmin.lo > 0
        return combine_addition(StronglyConvex(p1.eigmin), p2)
    elseif p1.eigmin.lo == 0 && p1.eigmin.hi == 0
        return combine_addition(Convex(), p2)
    else
        return combine_addition(Hypoconvex(abs(p1.eigmin)), p2)
    end
end
combine_addition(p1::Hypoconvex, p2::Quadratic) = combine_addition(p2, p1)
# === END ADDITION === #

# === BEGIN SUBTRACTION === #
function combine_subtraction(p1::Property, p2::Property)
    neg = negate_property(p2)
    if neg === nothing
        return nothing
    end
    return combine_addition(p1, neg)
end
# === END SUBTRACTION === #

# === BEGIN MAXIMUM === #
function combine_maximum(p1::Property, p2::Property)
    return nothing
end
function combine_maximum(::Convex, ::Convex)
    return Convex()
end
combine_maximum(p1::StronglyConvex, p2::StronglyConvex) = StronglyConvex(min_interval(p1.interval, p2.interval))
# === END MAXIMUM === #
# === BEGIN MINIMUM === #
function combine_minimum(p1::Property, p2::Property)
    return nothing
end
# === END MINIMUM === #
# === BEGIN COMPOSITION === #
function combine_composition(f::Property, g::Property)
    return nothing  # fallback
end
combine_composition(::Convex, ::Linear) = Convex()

function combine_composition(p1::Smooth, p2::Lipschitz)
    # Smooth ∘ Lipschitz: L_out * (L_in)^2
    new_lo = p1.interval.lo * (p2.interval.lo)^2
    new_hi = p1.interval.hi * (p2.interval.hi)^2
    return Smooth(Interval(new_lo, new_hi))
end
function combine_composition(p1::Lipschitz, p2::Lipschitz)
    # Lipschitz constants multiply
    new_lo = p1.interval.lo * p2.interval.lo
    new_hi = p1.interval.hi * p2.interval.hi
    return Lipschitz(Interval(new_lo, new_hi))
end
function combine_composition(p1::Hypoconvex, p2::Linear)
    # Hypoconvex ∘ linear: scale by eigmax^2
    if p2.eigmax === nothing
        return Hypoconvex(p1.interval)
    end
    new_lo = p1.interval.lo * (p2.eigmax.lo)^2
    new_hi = p1.interval.hi * (p2.eigmax.hi)^2
    return Hypoconvex(Interval(new_lo, new_hi))
end
function combine_composition(p1::StronglyConvex, p2::Linear)
    # StronglyConvex ∘ linear: if inner has positive smallest singular value
    if p2.eigmin === nothing
        return Convex()
    end
    if p2.eigmin.lo <= 0
        return Convex()
    end
    new_lo = p1.interval.lo + (p2.eigmin.lo)^2
    new_hi = p1.interval.hi + (p2.eigmin.hi)^2
    return StronglyConvex(Interval(new_lo, new_hi))
end

function combine_composition(p1::Smooth, p2::Linear)
    # Smooth ∘ linear: L_out + (eigmin)^2
    if p2.eigmin === nothing || p2.eigmax === nothing
        return Smooth(p1.interval)
    end
    new_lo = p1.interval.lo + (p2.eigmin.lo)^2
    new_hi = p1.interval.hi + (p2.eigmax.hi)^2
    return Smooth(Interval(new_lo, new_hi))
end

function combine_composition(p1::Lipschitz, p2::Linear)
    # Lipschitz ∘ linear: multiply by eigmax
    if p2.eigmax === nothing
        return Lipschitz(p1.interval)
    end
    new_lo = p1.interval.lo * p2.eigmax.lo
    new_hi = p1.interval.hi * p2.eigmax.hi
    return Lipschitz(Interval(new_lo, new_hi))
end
# === END COMPOSITION === #