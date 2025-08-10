using ..Database

gradient_descent = Database.Method(
    :gradient_descent_constant_step,
    [:smooth_convex, :smooth_stronglyconvex],
    consts -> begin
        # The returned value is a symbolic bound for demonstration.
        # In practice you would compute something like O(L/ε) or O(L/μ log(1/ε)).
        if haskey(consts, :strongly_convex)
            # strongly convex case: ratio of smoothness to strong convexity
            return consts.smooth.L.hi / consts.strongly_convex.μ.lo
        else
            # smooth convex case: use the smoothness constant
            return consts.smooth.L.hi
        end
    end,
)

Database.register_method!(gradient_descent)