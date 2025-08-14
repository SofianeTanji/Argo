# Annotations
export has_annotation, add_annotation, get_annotations, set_annotations

get_annotations(e::Expression) = e.annotations

function set_annotations(e::Expression, annotations)
    T = typeof(e)
    fields = fieldnames(T)

    # Create a new instance of the expression with the old handle and new annotations
    constructor_args = []
    for f in fields
        if f == :handle
            push!(constructor_args, e.handle)
        elseif f == :annotations
            push!(constructor_args, annotations)
        else
            push!(constructor_args, getfield(e, f))
        end
    end

    return T(constructor_args...)
end

has_annotation(e::Expression, key, val) = haskey(e.annotations, key) && e.annotations[key] == val
has_annotation(e::Expression, key) = haskey(e.annotations, key)

function add_annotation(e::Expression, key, val)
    new_annotations = copy(get_annotations(e))
    new_annotations[key] = val
    return set_annotations(e, new_annotations)
end

