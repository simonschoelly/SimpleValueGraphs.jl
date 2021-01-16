using Documenter, SimpleValueGraphs

DocMeta.setdocmeta!(SimpleValueGraphs, :DocTestSetup, :(using SimpleValueGraphs); recursive=true)
makedocs(
    sitename = "SimpleValueGraphs.jl",
    authors = "Simon Schoelly",
    modules = [SimpleValueGraphs],
    pages = [
        "Home" => "index.md",
       # "Introduction" => "introduction.md",
        "Basics" => [
            "Graph types" => "graphtypes.md", # TODO add constructors here, or in separate file
            "Accessing graphs" => "access.md",
            "Modifying graphs" => "modification.md",
            "Matrices" => "matrices.md",
        ],
      #  "AbstractValGraph interface" => "abstractgraph.md",
      #  "Integration with other packages" => "integration.md",
      #  "Internals" => "internals.md",
      #  "Api Reference" => "api.md",
    ],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    doctest = false
)
