# Annotations
export has_annotation, add_annotation, get_annotations, set_annotations

get_annotations(e::Expression) = e.annotations

function set_annotations(e::Expression, annotations)
    fields = fieldnames(typeof(e))
    new_fields = Dict{Symbol,Any}()
    for f in fields
        if f == :annotations
            new_fields[f] = annotations
        else
            new_fields[f] = getfield(e, f)
        end
    end
    # We need to splat the dictionary into keyword arguments
    return typeof(e)(; new_fields...)
end

has_annotation(e::Expression, key, val) = haskey(e.annotations, key) && e.annotations[key] == val
has_annotation(e::Expression, key) = haskey(e.annotations, key)

function add_annotation(e::Expression, key, val)
    new_annotations = copy(get_annotations(e))
    new_annotations[key] = val
    return set_annotations(e, new_annotations)
end

