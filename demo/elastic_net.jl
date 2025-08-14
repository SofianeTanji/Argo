using Revise
using Argo
using Argo.Properties
using Argo.Oracles

@variable x::R(:d)

@func logistic_loss(R(:d), R())
@func l1_norm(R(:d), R())
@func l2_norm_sq(R(:d), R())

@property logistic_loss Smooth(1.0)
@property logistic_loss Convex()

using Argo.Oracles
@oracle logistic_loss EvaluationOracle(x -> 1 / (1 + exp(-x)))
@oracle logistic_loss DerivativeOracle(x -> x)

@property l1_norm Convex()
@property l1_norm Lipschitz(1.0)
@oracle l1_norm EvaluationOracle(x -> max(0, x))
@oracle l1_norm DerivativeOracle(x -> sign(x))
@oracle l1_norm ProximalOracle(x -> x)

@property l2_norm_sq Smooth(2.0)
@property l2_norm_sq StronglyConvex(2.0)
@oracle l2_norm_sq EvaluationOracle(x -> x^2)
@oracle l2_norm_sq DerivativeOracle(x -> 2 * x)
@oracle l2_norm_sq ProximalOracle(x -> x / (1 + 2 * x))

# Combine the functions into a single expression.
expr = logistic_loss(x) + l1_norm(x) + l2_norm_sq(x)

println("Original Expression: ", expr)
println("-"^40)
println("Finding best methods for elastic-net problem...")
println("-"^40)

# Call the main recommend function to get a sorted list of applicable methods.
recommendations, all_reformulations = recommend(expr)
all_reformulations
# 4. Display the results
# ======================

if isempty(recommendations)
    println("No methods found for the given problem and its reformulations.")
    println("This is expected if the database is empty.")
else
    println("Recommended methods, sorted by best performance bound:")
    for rec in recommendations
        println("  - Method: ", rec.method)
        println("    - Formulation: ", rec.partition)
        println("    - Template: ", rec.template)
        println("    - Bound: ", rec.bound)
        println("-"^20)
    end
end
