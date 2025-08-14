# Minimal reproduction for annotation index issue

using Argo
using Argo.Language
using Argo.Reformulations: curvature_transfer, commutativity
using Test

# Define a simple expression with three terms
@variable x::R()
@func f(R(), R())
@func g(R(), R())
@func h(R(), R())

expr = f(x) + g(x) + h(x)

# 1. First curvature_transfer
ct1 = curvature_transfer(expr)
@info "ct1 count" length = length(ct1)
e1 = ct1[1]

# 2. First commutativity
c1 = commutativity(e1)[1]
@info "Picked first commuted expression" expr = c1

# Capture the initial annotation set for comparison
initial_ann = get_annotations(e1)[:curvature_transfer]
println("Initial annotation set: ", initial_ann)

# 3. Second curvature_transfer
ct2 = curvature_transfer(c1)
println("After second curvature_transfer, count = ", length(ct2))
for (i, r) in enumerate(ct2)
    new_ann = get_annotations(r)[:curvature_transfer]
    diff = setdiff(new_ann, initial_ann)
    println(" Reformulation #", i, " annotation set: ", new_ann)
    println("  New diff: ", diff)
end

# (Diagnostic only; remove strict assertion to inspect outputs)
#@test length(ct2) == 2
