"""
    match_methods(expr::Language.Expression) -> Vector{NamedTuple}

Match `expr` (using its top‑level additive terms, or itself if non‑additive)
against registered templates and methods. Returns a vector of named tuples
with keys `partition`, `template`, `method`, `constants`, `bound`, sorted
by increasing `bound`.
"""
function match_methods(expr::Language.Expression)
    results = []
    # Determine components (formerly produced by `partitions`) directly
    parts = expr isa Language.Addition ? expr.terms : [expr]
    # Infer properties for each component
    props = [Properties.infer_properties(comp) for comp in parts]
    # Try each registered template
    for tpl in TEMPLATES
        if length(props) == tpl.num_components && tpl.requirement(props)
            consts = tpl.extract_constants(props)
            # For each method that solves this template
            for m in METHODS
                if tpl.name in m.template_names
                    bound = m.complexity(consts)
                    push!(results, (
                        partition=parts,
                        template=tpl.name,
                        method=m.name,
                        constants=consts,
                        bound=bound,
                    ))
                end
            end
        end
    end
    sort!(results, by=x -> x.bound)
    return results
end