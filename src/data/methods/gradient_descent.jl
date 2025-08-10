using ..Database

gradient_descent = Database.Method(
    :gradient_descent_constant_step,
    [:smooth_convex, :smooth_stronglyconvex],
    consts -> begin
        if haskey(consts, :strongly_convex) # placeholder
            return consts.smooth.L.hi / consts.strongly_convex.μ.lo
        else
            # placeholder
            return consts.smooth.L.hi
        end
    end,
)

Database.register_method!(gradient_descent)