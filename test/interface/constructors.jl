using SimpleValueGraphs.AbstractTuples

import SimpleValueGraphs: tuple_of_types, default_edgeval_types, default_eltype


function testset_toplogical_equivalent(g::SimpleGraph, gv::EdgeValGraph)
    @testset "Topological equivalent" begin
        @test all(lr -> lr[1] == lr[2], zip(g.fadjlist, gv.fadjlist))
    end
end

function testset_toplogical_equivalent(g::SimpleDiGraph, gv::EdgeValOutDiGraph)
    @testset "Topological equivalent" begin
        @test all(lr -> lr[1] == lr[2], zip(g.fadjlist, gv.fadjlist))
    end
end

function testset_toplogical_equivalent(g::SimpleDiGraph, gv::EdgeValDiGraph)
    @testset "Topological equivalent" begin
        @test all(lr -> lr[1] == lr[2], zip(g.fadjlist, gv.fadjlist))
        @test all(lr -> lr[1] == lr[2], zip(g.badjlist, gv.badjlist))
    end
end


# EdgeValGraph{Int, Tuple{Float64}}(10)
@testset "Constructor $G{\$V, \$E_VALS}(\$n)" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

    @testset "Params: V = $V, E_VALS = $E_VALS" for
         V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
         n in (V in (UInt8, Int8) ? V[0, 5, typemax(V)] : V[0, 5])

        g = G{V, E_VALS}(n)

        @test g isa G{V, E_VALS}
        @test ne(g) == 0
        @test nv(g) == n
        gs = is_directed(G) ? SimpleDiGraph(n) : SimpleGraph(n)
        testset_topological_equivalent(gs, g)
        testset_isvalidgraph(g)

    end
end


# EdgeValGraph(10, (Float64, ))
@testset "Constructor $G(\$n::\$V, \$edgeval_types)" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

    @testset "Params n = $n, V = $V; edgeval_types = $edgeval_types" for
                V in TEST_VERTEX_TYPES_SMALL,
    edgeval_types in tuple_of_types.(TEST_EDGEVAL_TYPES_SMALL),
                n in (V in (UInt8, Int8) ? V[0, 5, typemax(V)] : V[0, 5])
                    
        g = G(n; edgeval_types=edgeval_types)

        E_VALS_should_be = (edgeval_types isa Tuple) ?
            Tuple{edgeval_types...} :
            NamedTuple{keys(edgeval_types), Tuple{edgeval_types...}}

        @test g isa G{default_eltype, E_VALS_should_be}
        @test ne(g) == 0
        @test nv(g) == n
        gs = is_directed(G) ? SimpleDiGraph(n) : SimpleGraph(n)
        testset_topological_equivalent(gs, g)
        testset_isvalidgraph(g)
    end

end



# EdgeValGraph(10)
@testset "Constructor $G(\$n::\$V)" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

    @testset "Params n = $n, V = $V" for
        V in TEST_VERTEX_TYPES_SMALL,
        n in (V in (UInt8, Int8) ? V[0, 5, typemax(V)] : V[0, 5])

        g = G(n)

        @testset "correct type" begin
            E_VALS_should_be = (default_edgeval_types isa Tuple) ?
                Tuple{default_edgeval_types...} :
                NamedTuple{keys(default_edgeval_types),
                           Tuple{default_edgeval_types...}}

            @test g isa G{default_eltype, E_VALS_should_be}
        end

        @testset "0 edges" begin @test ne(g) == 0 end
        @testset "$n vertices" begin @test ne(g) == 0 end
        gs = is_directed(G) ? SimpleDiGraph(n) : SimpleGraph(n)
        testset_topological_equivalent(gs, g)
        testset_isvalidgraph(g)
    end
end

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




