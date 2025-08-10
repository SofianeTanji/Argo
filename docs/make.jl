using Argo
using Documenter

DocMeta.setdocmeta!(Argo, :DocTestSetup, :(using Argo); recursive=true)

makedocs(;
    modules=[Argo],
    authors="Sofiane <sofiane.tanji@uclouvain.be> and contributors",
    sitename="Argo.jl",
    format=Documenter.HTML(;
        canonical="https://SofianeTanji.github.io/Argo.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SofianeTanji/Argo.jl",
    devbranch="main",
)
