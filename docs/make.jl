using Documenter, SimpleValueGraphs

DocMeta.setdocmeta!(SimpleValueGraphs, :DocTestSetup, :(using SimpleValueGraphs, LightGraphs, Random); recursive=true)
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
            "Comparison of graph types" => "comparison.md",
        ],
        "Custom Value Graph types" => "custom-valuegraph-types.md"
      #  "AbstractValGraph interface" => "abstractgraph.md",
      #  "Integration with other packages" => "integration.md",
      #  "Internals" => "internals.md",
      #  "Api Reference" => "api.md",
    ],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    doctest = false
    # doctest = true
)

deploydocs(;
    repo="github.com/simonschoelly/SimpleValueGraphs.jl",
)
