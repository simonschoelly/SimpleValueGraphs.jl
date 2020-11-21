import SimpleValueGraphs: tuple_of_types, OneEdgeValGraph

@testset "edge iterator $G" for
    G in (ValGraph, ValOutDiGraph, ValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G(gs;
              edgeval_types=tuple_of_types(E_VALS),
              edgeval_initializer=(s,d) -> rand_sample(E_VALS)
        )

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
                s, d, vs = src(e), dst(e), get_edgeval(e, :)
                e isa E_should_be &&
                has_edge(g, s, d) &&
                get_edgeval(g, s, d, :) == vs
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
    G in (ValGraph, ValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G(gs;
            edgeval_types=tuple_of_types(E_VALS),
            edgeval_initializer=(s,d) -> rand_sample(E_VALS)
        )

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
    G in (ValGraph, ValOutDiGraph, ValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G(gs;
            edgeval_types=tuple_of_types(E_VALS),
            edgeval_initializer=(s,d) -> rand_sample(E_VALS)
        )

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
    G in (ValGraph, ValOutDiGraph, ValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G(gs;
            edgeval_types=tuple_of_types(E_VALS),
            edgeval_initializer=(s,d) -> rand_sample(E_VALS)
        )

        @testset "outedgevals are correct for key $key" for key in allkeys_for_E_VALS(E_VALS)

            @test all(vertices(g)) do u
                outedgevals(g, u, key) == [get_edgeval(g, u, v, key) for v in outneighbors(g, u)]
            end
        end

        if g isa OneEdgeValGraph
            @testset "outedgevals for graphs with single key" begin
                @test all(vertices(g)) do u
                    outedgevals(g, u) == outedgevals(g, u, 1)
                end
            end
        end
    end
end

@testset "inedgevals $G" for
    G in (ValGraph, ValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G(gs;
            edgeval_types=tuple_of_types(E_VALS),
            edgeval_initializer=(s,d) -> rand_sample(E_VALS)
        )

        @testset "inedgevals are correct for key $key" for key in allkeys_for_E_VALS(E_VALS)

            @test all(vertices(g)) do u
                inedgevals(g, u, key) == [get_edgeval(g, v, u, key) for v in inneighbors(g, u)]
            end
        end

        if g isa OneEdgeValGraph
            @testset "inedgevals for graphs with single key" begin
                @test all(vertices(g)) do u
                    inedgevals(g, u) == inedgevals(g, u, 1)
                end
            end
        end
    end
end

@testset "edges $G" for
    G in (ValGraph, ValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL,
    (gs, info) in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

    @testset "Params: $G{$V, $E_VALS}, gs = $info" begin

        g = G(gs;
            edgeval_types=tuple_of_types(E_VALS),
            edgeval_initializer=(s,d) -> rand_sample(E_VALS)
        )

        @testset "edges are lexicographical sorted, unique" begin
            lexicographical_sorted = true
            s = 0
            d = 0
            for e in edges(g)
                s_new = src(e)
                d_new = dst(e)

                if s_new < s || (s_new == s && d_new <= d)
                    lexicographical_sorted = false
                    break
                end
            end
            @test lexicographical_sorted
        end

        @testset "correct src, dst" begin
            @test all(edges(g)) do e
                has_edge(g, src(e), dst(e))
            end
        end

        @testset "correct values" begin
            @test all(edges(g)) do e
                get_edgeval(e, :) == get_edgeval(g, src(e), dst(e), :)
            end
        end

        @testset "correct length" begin
            @test length(edges(g)) == ne(g)
        end
    end
end

