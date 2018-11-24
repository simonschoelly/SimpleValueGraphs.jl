using LightGraphs
using SimpleValueGraphs
using ProgressMeter
using TerminalMenus
using Test

include("testutils.jl")

tests = Dict("LightGraphs compability"    => () -> include("lightgraphs_compatibility.jl"),
             "SimpleValueGraph interface" => () -> include("interface.jl"),
            )

@testset "SimpleValueGraphs" begin

    if isinteractive()
        testnames = collect(keys(tests))
        menu = MultiSelectMenu(testnames)
        menu.selected = Set(Base.OneTo(length(testnames))) # select all options by default
        selected_tests = request("Select which tests to run:", menu) 
        for test_num in selected_tests
                tests[testnames[test_num]]()
        end
    else
        foreach(test -> test(), values(tests))
    end

end # testset
