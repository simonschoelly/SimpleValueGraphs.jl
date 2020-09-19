using LightGraphs
using SimpleValueGraphs
using Test

using Base.Iterators: product
using SimpleValueGraphs.AbstractTuples: tuple_of_types

include("testutils.jl")

tests = [
    "AbstractTuples.jl",
    "abstractvaluegraph.jl",
    "interface/constructors.jl",
    "interface/edges.jl",
    "interface/edgeval_accessors.jl",
    "interface/iterators.jl",
    "interface/modifiers.jl",
    "interface/valuegraph.jl",
    "matrices.jl",
]

@testset "ValueGraphs" begin
    for (i, test) in enumerate(tests)
        println("$i / $(length(tests)) $test")
        @time include(test)
    end
end # testset
