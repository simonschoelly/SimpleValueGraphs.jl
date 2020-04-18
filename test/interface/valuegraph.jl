


@testset "edgevals_type($G{$V, $E_VALS})" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL

    g = G{V, E_VALS}(0)
    @assert g isa G{V, E_VALS}

    @test edgevals_type(g) == E_VALS
    @test edgevals_type(typeof(g)) == E_VALS
    @test edgevals_type(G{V, E_VALS}) == E_VALS

end

@testset "edgetype($G{$G, $E_VALS})" for
    G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL

    g = G{V, E_VALS}(0)
    @assert g isa G{V, E_VALS}

    ET_should_be = (is_directed(g) ? ValDiEdge : ValEdge){V, E_VALS}

    @test edgetype(g) == ET_should_be
    @test edgetype(typeof(g)) == ET_should_be
    @test edgetype(G{V, E_VALS}) == ET_should_be

end

@testset "vertices" begin
    @testset "vertices($G{$G, $E_VALS}($n))" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph),
        V in TEST_VERTEX_TYPES_SMALL,
        E_VALS in TEST_EDGEVAL_TYPES_SMALL,
        n in [0, 1, 2, 3, 10, 11]

        g = G{V, E_VALS}(n)
        @assert g isa G{V, E_VALS}

        @test vertices(g) == Base.OneTo(n)
        @test eltype(vertices(g)) == V
    end

    @testset "has_vertex($G{$G, $E_VALS}($n), $u))" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph),
        V in TEST_VERTEX_TYPES_SMALL,
        E_VALS in TEST_EDGEVAL_TYPES_SMALL,
        n in [0, 1, 2, 3, 10, 11],
        u in [-1, 0, 1, 2, 4, 12, 127]

        g = G{V, E_VALS}(n)
        @assert g isa G{V, E_VALS}

        @test has_vertex(g, u) == ((u >= 1) && (u <= n))
    end
end

# TODO might move tests for abstract type to separate class
@testset "show" begin

end

