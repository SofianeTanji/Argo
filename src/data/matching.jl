"""
    partitions(expr::Language.Expression) -> Vector{Vector{Language.Expression}}

Generate candidate partitions of an expression for template matching.
A partition is represented as a vector of `Expression`s, where each
element is one component of the problem.  For example, an addition
`f + g + h` can be partitioned as `[f, g, h]`, `[f + g, h]`,
`[f, g + h]`, and `[f + g + h]`.  Non‑additive expressions yield a
single partition containing the expression itself.
"""
function partitions(expr::Language.Expression)
    if expr isa Language.Addition
        terms = expr.terms
        n = length(terms)
        parts = Vector{Vector{Language.Expression}}()
        # each term separately
        push!(parts, terms)
        # two-group partitions
        for k in 1:n-1
            group1 = Language.Addition(terms[1:k])
            group2 = Language.Addition(terms[k+1:end])
            push!(parts, [group1, group2])
        end
        # single component (the whole sum)
        push!(parts, [expr])
        return parts
    else
        return [[expr]]
    end
end

"""
    match_methods(expr::Language.Expression) -> Vector{NamedTuple}

Match an optimisation problem against known templates and methods.
This function enumerates partitions, tests each template’s
requirement, extracts constants, and evaluates the complexity
function of any applicable methods.  Each match is returned as a
named tuple with keys `partition`, `template`, `method`, `constants`
and `bound`.  If no matches are found, an empty vector is returned.
"""
function match_methods(expr::Language.Expression)
    results = []
    for part in partitions(expr)
        # Infer properties for each component in the partition
        props = [Properties.infer_properties(comp) for comp in part]
        # Try each registered template
        for tpl in TEMPLATES
            if length(props) == tpl.num_components && tpl.requirement(props)
                consts = tpl.extract_constants(props)
                # For each method that solves this template
                for m in METHODS
                    if tpl.name in m.template_names
                        bound = m.complexity(consts)
                        push!(results, (
                            partition=part,
                            template=tpl.name,
                            method=m.name,
                            constants=consts,
                            bound=bound,
                        ))
                    end
                end
            end
        end
    end
    sort!(results, by=x -> x.bound)
    return results
end