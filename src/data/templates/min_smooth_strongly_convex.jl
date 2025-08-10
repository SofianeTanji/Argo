using ..Database
using ..Properties

smooth_stronglyconvex = Database.Template(
    :smooth_stronglyconvex,
    1,
    parts -> begin
        length(parts) == 1 &&
            any(p -> p isa Properties.Smooth, parts[1]) &&
            any(p -> p isa Properties.StronglyConvex, parts[1])
    end,
    parts -> begin
        Lprop = first(filter(p -> p isa Properties.Smooth, parts[1]))
        μprop = first(filter(p -> p isa Properties.StronglyConvex, parts[1]))
        return (
            smooth=(L=Lprop.interval,),
            strongly_convex=(μ=μprop.interval,)
        )
    end,
)
Database.register_template!(smooth_stronglyconvex)