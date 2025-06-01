using Argo
using Documenter

DocMeta.setdocmeta!(Argo, :DocTestSetup, :(using Argo); recursive=true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules=[Argo],
    authors="Sofiane <sofiane.tanji@uclouvain.be>",
    repo="https://github.com/SofianeTanji/Argo.jl/blob/{commit}{path}#{line}",
    sitename="Argo.jl",
    format=Documenter.HTML(; canonical="https://SofianeTanji.github.io/Argo.jl"),
    pages=["index.md"; numbered_pages],
)

deploydocs(; repo="github.com/SofianeTanji/Argo.jl")
