

@testset "edgevals_type($G{$V, $E_VALS})" for
    G in (ValGraph, ValOutDiGraph, ValDiGraph),
    V in TEST_VERTEX_TYPES_SMALL,
    E_VALS in TEST_EDGEVAL_TYPES_SMALL

    g = G{V, E_VALS}(0)
    @assert g isa G{V, E_VALS}

    @test edgevals_type(g) == E_VALS
    @test edgevals_type(typeof(g)) == E_VALS
    @test edgevals_type(G{V, E_VALS}) == E_VALS

end

@testset "edgetype($G{$G, $E_VALS})" for
    G in (ValGraph, ValOutDiGraph, ValDiGraph),
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
        G in (ValGraph, ValOutDiGraph, ValDiGraph),
        V in TEST_VERTEX_TYPES_SMALL,
        E_VALS in TEST_EDGEVAL_TYPES_SMALL,
        n in [0, 1, 2, 3, 10, 11]

        g = G{V, E_VALS}(n)
        @assert g isa G{V, E_VALS}

        @test vertices(g) == Base.OneTo(n)
        @test eltype(vertices(g)) == V
    end

    @testset "has_vertex($G{$G, $E_VALS}($n), $u))" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph),
        V in TEST_VERTEX_TYPES_SMALL,
        E_VALS in TEST_EDGEVAL_TYPES_SMALL,
        n in [0, 1, 2, 3, 10, 11],
        u in [-1, 0, 1, 2, 4, 12, 127]

        g = G{V, E_VALS}(n)
        @assert g isa G{V, E_VALS}

        @test has_vertex(g, u) == ((u >= 1) && (u <= n))
    end
end

function xshow(io::IO, g::AbstractValGraph{V, E_VALS}) where {V, E_VALS}
    nvg = Int(nv(g))
    neg = Int(nv(g))
    dir = is_directed(g) ? "directed" : "undirected"
    name = string(nameof(typeof(g)))

    types = tuple_of_types(E_VALS)

    edgevalues_string = if g isa ZeroValGraph
        "with no edge values"
    elseif g isa OneValGraph
        if has_named_edgevals(g)
            "with named edge values of type $types"
        else
            "with edge values of type $types"
        end
    else
        if has_named_edgevals(g)
            "with multiple named edge values of types $types"
        else
            "with multiple edge values of types $types"
        end

    end

    println(io, "{$nvg, $neg} $dir $name{$V} graph $edgevalues_string.")
end

function test_show(x, expected::String)
    io = IOBuffer()
    show(io, x)
    @test String(take!(io)) == expected
end

# TODO use testset with different parameters
@testset "show" begin

    test_show(ValGraph{Int8}(10; edgeval_types=()), "{10, 0} undirected ValGraph{Int8} graph with no edge values.\n")
    test_show(ValDiGraph{Int64}(0; edgeval_types=NamedTuple()), "{0, 0} directed ValDiGraph{Int64} graph with no edge values.\n")
    test_show(ValOutDiGraph{UInt32}(0; edgeval_types=NamedTuple()), "{0, 0} directed ValOutDiGraph{UInt32} graph with no edge values.\n")

    test_show(ValGraph(undef, cycle_graph(Int16(3)), edgeval_types=(Float32,)),
              "{3, 3} undirected ValGraph{Int16} graph with edge values of type (Float32,).\n")

    test_show(ValOutDiGraph(undef, path_digraph(Int32(5)), edgeval_types=(label = String,)),
              "{5, 4} directed ValOutDiGraph{Int32} graph with named edge values of type (label = String,).\n")

    test_show(ValGraph(undef, complete_graph(UInt64(6)), edgeval_types=(String, Char)),
              "{6, 15} undirected ValGraph{UInt64} graph with multiple edge values of types (String, Char).\n")

    test_show(ValDiGraph(undef, complete_digraph(UInt64(6)), edgeval_types=(a=Bool, b=Tuple{Bool, Bool}, c=Char)),
              "{6, 30} directed ValDiGraph{UInt64} graph with multiple named edge values of types (a = Bool, b = $(Tuple{Bool,Bool}), c = Char).\n")

end

