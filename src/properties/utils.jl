function get_properties(ft::Language.FunctionType)
    return Set{Property}(p for p in ft.props if p isa Property)
end

function set_property!(fn::Language.FunctionType, p::Property)
    filter!(prop -> typeof(prop) != typeof(p), fn.props)
    push!(fn.props, p)
end

function infer_properties(expr::Language.Expression)
    if expr isa Language.Variable
        return Set{Property}()
    elseif expr isa Language.FunctionCall
        return get_properties(expr.func)

    elseif expr isa Language.Addition
        props_list = [infer_properties(t) for t in expr.terms]
        acc = props_list[1]
        for props in props_list[2:end]
            new_acc = Set{Property}()
            for p1 in acc, p2 in props
                combined = combine_addition(p1, p2)
                if combined !== nothing
                    push!(new_acc, combined)
                end
            end
            acc = new_acc
        end
        return acc

    elseif expr isa Language.Subtraction
        p1s = infer_properties(expr.a)
        p2s = infer_properties(expr.b)
        result = Set{Property}()
        for p1 in p1s, p2 in p2s
            combined = combine_subtraction(p1, p2)
            if combined !== nothing
                push!(result, combined)
            end
        end
        return result

    elseif expr isa Language.Maximum
        props_list = [infer_properties(t) for t in expr.terms]
        acc = props_list[1]
        for props in props_list[2:end]
            new_acc = Set{Property}()
            for p1 in acc, p2 in props
                combined = combine_maximum(p1, p2)
                if combined !== nothing
                    push!(new_acc, combined)
                end
            end
            acc = new_acc
        end
        return acc

    elseif expr isa Language.Minimum
        props_list = [infer_properties(t) for t in expr.terms]
        acc = props_list[1]
        for props in props_list[2:end]
            new_acc = Set{Property}()
            for p1 in acc, p2 in props
                combined = combine_minimum(p1, p2)
                if combined !== nothing
                    push!(new_acc, combined)
                end
            end
            acc = new_acc
        end
        return acc

    elseif expr isa Language.Composition
        p_outer = get_properties(expr.outer)
        p_inner = infer_properties(expr.inner)
        result = Set{Property}()
        for po in p_outer, pi in p_inner
            combined = combine_composition(po, pi)
            if combined !== nothing
                push!(result, combined)
            end
        end
        return result

    else
        return Set{Property}()
    end
end