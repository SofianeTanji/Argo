const TEMPLATES = Template[]
const METHODS = Method[]

function register_template!(tpl::Template)
    push!(TEMPLATES, tpl)
    return tpl
end

function register_method!(method::Method)
    push!(METHODS, method)
    return method
end

list_templates() = copy(TEMPLATES)
list_methods() = copy(METHODS)

function load_templates!(dir::AbstractString)
    if isdir(dir)
        for (root, _, files) in walkdir(dir)
            for file in files
                if endswith(file, ".jl")
                    include(joinpath(root, file))
                end
            end
        end
    end
end

function load_methods!(dir::AbstractString)
    if isdir(dir)
        for (root, _, files) in walkdir(dir)
            for file in files
                if endswith(file, ".jl")
                    include(joinpath(root, file))
                end
            end
        end
    end
end
