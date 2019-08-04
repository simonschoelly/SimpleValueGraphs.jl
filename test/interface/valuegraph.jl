


@testset "edgevals_type($G{$V, $E_VALS})" for
    G in (ValueGraph, ValueOutDiGraph, ValueDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL

    g = G{V, E_VALS}(0)
    @assert g isa G{V, E_VALS}

    @test edgevals_type(g) == E_VALS
    @test edgevals_type(typeof(g)) == E_VALS
    @test edgevals_type(G{V, E_VALS}) == E_VALS

end

@testset "edgetype($G{$G, $E_VALS})" for
    G in (ValueGraph, ValueOutDiGraph, ValueDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL

    g = G{V, E_VALS}(0)
    @assert g isa G{V, E_VALS}

    ET_should_be = (is_directed(g) ? ValueDiEdge : ValueEdge){V, E_VALS}

    @test edgetype(g) == ET_should_be
    @test edgetype(typeof(g)) == ET_should_be
    @test edgetype(G{V, E_VALS}) == ET_should_be

end

