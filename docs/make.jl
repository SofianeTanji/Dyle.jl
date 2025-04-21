using Dyle
using Documenter

DocMeta.setdocmeta!(Dyle, :DocTestSetup, :(using Dyle); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules = [Dyle],
    authors = "Sofiane <sofiane.tanji@uclouvain.be>",
    repo = "https://github.com/SofianeTanji/Dyle.jl/blob/{commit}{path}#{line}",
    sitename = "Dyle.jl",
    format = Documenter.HTML(; canonical = "https://SofianeTanji.github.io/Dyle.jl"),
    pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/SofianeTanji/Dyle.jl")
