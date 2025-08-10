using ..Database
using ..Properties

smooth_convex = Database.Template(
    :smooth_convex,
    1,
    parts -> begin
        length(parts) == 1 &&
            any(p -> p isa Properties.Smooth, parts[1]) &&
            any(p -> p isa Properties.Convex, parts[1])
    end,
    parts -> begin
        Lprop = first(filter(p -> p isa Properties.Smooth, parts[1]))
        return (smooth=(L=Lprop.interval,),)
    end,
)
Database.register_template!(smooth_convex)