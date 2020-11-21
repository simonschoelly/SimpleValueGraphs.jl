using LightGraphs
using SimpleValueGraphs
using Test

using Base.Iterators: product

include("testutils.jl")

tests = Dict{String, String}()

function register_test(path::String)

    tests[path] = path
end

register_test("AbstractTuples.jl")
# register_test("abstractvaluegraph.jl")
register_test("integrations/SimpleGraphs.jl")
# register_test("interface/constructors.jl")
register_test("interface/edges.jl")
register_test("interface/edgeval_accessors.jl")
register_test("interface/iterators.jl")
register_test("interface/modifiers.jl")
# register_test("interface/valuegraph.jl")
register_test("matrices.jl")


@testset "ValueGraphs" begin

    regex = r""
    if !isempty(ARGS)
        length(ARGS) > 1 && error("At most one regex can be specified for test_args")
        regex = Regex(ARGS[1])
    end

    filtered_test_names = filter(test_name -> occursin(regex, test_name), keys(tests)) |> collect |> sort

    for (i, test_name) in enumerate(filtered_test_names)
        println("$i / $(length(filtered_test_names)) $test_name")
        @time include(tests[test_name])
    end
end # testset
