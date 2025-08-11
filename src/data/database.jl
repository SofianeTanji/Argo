module Database
using ..Oracles
using ..Properties
using ..Language

"""
A `Template` is a structure in the Argo framework. It includes:
   - `name`: A symbolic identifier for the template.
   - `num_components`: The number of components that the template expects.
   - `requirement`: A predicate function that checks if a set of properties
     satisfies the template's conditions.
   - `extract_constants`: a function that accepts the same vector of
   property sets and returns a named tuple mapping constant names to values or intervals.
"""
struct Template
  name::Symbol
  num_components::Int
  requirement::Function
  extract_constants::Function
end

"""
A `Method` is a structure in the Argo framework.
It includes:
   - `name`: A symbolic identifier for the method.
   - `template_names`: The name of the template(s) that this method solves.
   - `complexity`: a function taking a named tuple of constants
  (as returned by the corresponding template’s `extract_constants`)
  and returning a symbolic or numerical worst‑case complexity bound.
Additional method parameters (e.g. step‑size formulas) can be encoded
inside the `complexity` function’s closure.
"""
struct Method
  name::Symbol
  template_names::Vector{Symbol}
  complexity::Function
end

export Template, Method, match_methods

include("registry.jl")
include("matching.jl")
function __init__()
  local dir = dirname(@__FILE__)
  load_templates!(joinpath(dir, "templates"))
  load_methods!(joinpath(dir, "methods"))
end
export register_method!, register_template!
end