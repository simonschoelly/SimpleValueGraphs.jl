import SimpleValueGraphs: tuple_of_types, OneEdgeValGraph

@testset "edge iterator $G" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G((s,d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS)) 

        iter = edges(g)

        E_should_be = (is_directed(g) ? ValDiEdge : ValEdge){V, E_VALS}

        
        @testset "eltype" begin
            @test eltype(iter) <: E_should_be
        end

        @testset "length" begin
            @test length(iter) == ne(g)
        end

        @testset "correct edges" begin
            @test all(iter) do e
                s, d, vs = src(e), dst(e), get_val(e, :)
                e isa E_should_be &&
                has_edge(g, s, d) &&
                get_val(g, s, d, :) == vs
            end
        end

        @testset "lexically strictly increasing" begin
            s_prev, d_prev = 0, 0
            @test all(iter) do (e)
                s, d = src(e), dst(e)
                if (s < s_prev ||  (s == s_prev && d <= d_prev))
                    return false
                end
                s_prev, d_prev = s, d
                return true
            end
        end

    end
end

@testset "inneighbors $G" for
    G in (EdgeValGraph, EdgeValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G((s,d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS)) 

        @testset "inneighbors are unique" begin
            @test all(vertices(g)) do u
                allunique(inneighbors(g, u))
            end
        end

        @testset "inneighbors same as simple graph" begin
            @test all(vertices(g)) do u
                issetequal(inneighbors(g, u), inneighbors(gs, u))
            end
        end

    end
end

@testset "outneighbors $G" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G((s,d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS)) 

        @testset "outneighbors are unique" begin
            @test all(vertices(g)) do u
                allunique(outneighbors(g, u))
            end
        end

        @testset "outneighbors same as simple graph" begin
            @test all(vertices(g)) do u
                issetequal(outneighbors(g, u), outneighbors(gs, u))
            end
        end

    end
end

@testset "outedgevals $G" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G((s,d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))

        @testset "outedgevals are correct for key $key" for key in allkeys_for_E_VALS(E_VALS)

            @test all(vertices(g)) do u
                outedgevals(g, u, key) == [get_val(g, u, v, key) for v in outneighbors(g, u)]
            end
        end
    end
end

@testset "inedgevals $G" for
    G in (EdgeValGraph, EdgeValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G((s,d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))

        @testset "inedgevals are correct for key $key" for key in allkeys_for_E_VALS(E_VALS)

            @test all(vertices(g)) do u
                inedgevals(g, u, key) == [get_val(g, v, u, key) for v in inneighbors(g, u)]
            end
        end
    end
end
