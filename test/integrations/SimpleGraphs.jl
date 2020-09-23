
import SimpleValueGraphs: tuple_of_types, default_edgeval_types

@testset "SimpleGraphs.jl" begin

# EdgeValGraph(undef, gs, (Float64,))
@testset "Constructor $G(undef, \$gs, \$edgeval_types)" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

    GS = is_directed(G) ? SimpleDiGraph : SimpleGraph

    @testset "Params: edgeval_types = $edgeval_types, gs = $info" for
                V in TEST_VERTEX_TYPES_SMALL,
    edgeval_types in tuple_of_types.(TEST_EDGEVAL_TYPES_SMALL),
       (gs, info) in make_testgraphs(GS{V})
  

        g = G(undef, gs; edgeval_types=edgeval_types)

        @testset "correct type" begin
            E_VALS_should_be = (edgeval_types isa Tuple) ?
                Tuple{edgeval_types...} :
                NamedTuple{keys(edgeval_types),
                           Tuple{edgeval_types...}}

            @test g isa G{V, E_VALS_should_be}
        end
        testset_topological_equivalent(gs, g)
        testset_isvalidgraph(g, undef_edgevalues=true)
    end
end

# EdgeValGraph(undef, gs)
@testset "Constructor $G(undef, \$gs)" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

    GS = is_directed(G) ? SimpleDiGraph : SimpleGraph

    @testset "Params: gs = $info" for
                V in TEST_VERTEX_TYPES_SMALL,
       (gs, info) in make_testgraphs(GS{V})
  

        g = G(undef, gs)

        @testset "correct type" begin
            E_VALS_should_be = (default_edgeval_types isa Tuple) ?
                Tuple{default_edgeval_types...} :
                NamedTuple{keys(default_edgeval_types),
                           Tuple{default_edgeval_types...}}

            @test g isa G{V, E_VALS_should_be}
        end
        testset_topological_equivalent(gs, g)
        testset_isvalidgraph(g, undef_edgevalues=true)
    end
end



# EdgeValGraph((s, d) -> (f(s, d),), gs, (Float64,))
@testset "Constructor $G(f, \$gs, \$edgeval_types)" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

    GS = is_directed(G) ? SimpleDiGraph : SimpleGraph


    @testset "Params: edgeval_types = $(tuple_of_types(E_VALS)), gs = $info" for
                V in TEST_VERTEX_TYPES_SMALL,
           E_VALS in TEST_EDGEVAL_TYPES_SMALL,
       (gs, info) in make_testgraphs(GS{V})
  

        n = nv(gs)
        A = rand_sample(E_VALS, n, n)
        edgeval_types = tuple_of_types(E_VALS)

        g = G((s, d) -> A[s,d], gs; edgeval_types=edgeval_types)

        @testset "correct type" begin
            E_VALS_should_be = (edgeval_types isa Tuple) ?
                Tuple{edgeval_types...} :
                NamedTuple{keys(edgeval_types),
                           Tuple{edgeval_types...}}

            @test g isa G{V, E_VALS_should_be}
        end

        @testset "correct values" begin
            @test all(edges(gs)) do e
                s, d = src(e), dst(e)
                A[s, d] == get_val(g, s, d, :)
            end
        end

        testset_topological_equivalent(gs, g)
        testset_isvalidgraph(g)
    end
end

end # testset