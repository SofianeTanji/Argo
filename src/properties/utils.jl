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
        term_props = [infer_properties(t) for t in expr.terms]
        if all(props -> any(p -> p isa Convex, props), term_props)
            return Set{Property}(Convex())
        else
            return Set{Property}()
        end
    elseif expr isa Language.Composition
        return Set{Property}()    # composition rules omitted in this minimal version
    else
        return Set{Property}()
    end
end