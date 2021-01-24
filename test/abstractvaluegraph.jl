using SimpleValueGraphs: hasedgekey_or_throw, AbstractValGraph, ValEdgeIter

@testset "abstractvaluegraph" begin

struct DummyValGraph{V, V_VALS, E_VALS, G_VALS, G <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}} <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}

    wrapped::G
end

SimpleValueGraphs.nv(g::DummyValGraph) = nv(g.wrapped)

SimpleValueGraphs.is_directed(::Type{<:DummyValGraph{V, V_VALS, E_VALS, G_VALS, G}}) where {V, V_VALS, E_VALS, G_VALS, G} = is_directed(G)

SimpleValueGraphs.has_edge(g::DummyValGraph, s, d) = has_edge(g.wrapped, s, d)

SimpleValueGraphs.get_edgeval(g::DummyValGraph, s, d, key::Integer) =
    get_edgeval(g.wrapped, s, d, key)

SimpleValueGraphs.get_vertexval(g::DummyValGraph, v, key::Integer) =
    get_vertexval(g.wrapped, v, key)

SimpleValueGraphs.get_vertexval(g::DummyValGraph, v, key::Integer) =
    get_vertexval(g.wrapped, v, key)

SimpleValueGraphs.get_edgeval(g::DummyValGraph, s, d, key::Integer) =
    get_edgeval(g.wrapped, s, d, key)

@testset "eltype" begin

    @test eltype(DummyValGraph{Int8}) == Int8
    @test eltype(DummyValGraph(ValGraph{UInt16}(3))) == UInt16
end

@testset "vertexvals_type" begin

    @test vertexvals_type(DummyValGraph{Int64, Tuple{Integer, Union{Nothing, String}}}) ==
                Tuple{Integer, Union{Nothing, String}}

    g = DummyValGraph(ValDiGraph(
        0;
        vertexval_types=(a=Char, b=Vector{Bool}),
        vertexval_init=undef
    ))

    expected_type = NamedTuple{(:a, :b), Tuple{Char, Vector{Bool}}}
    @assert g isa AbstractValGraph{V, expected_type, E_VALS} where {V, E_VALS}
    @test vertexvals_type(g) == expected_type
end

@testset "vertexvals_type" begin

    @test edgevals_type(DummyValGraph{Int, Tuple{}, Tuple{Integer, Union{Nothing, String}}}) ==
                Tuple{Integer, Union{Nothing, String}}

    g = DummyValGraph(ValOutDiGraph(
        0;
        edgeval_types=(String,)
    ))
    expected_type = Tuple{String}
    @assert g isa AbstractValGraph{V, V_VALS, expected_type} where {V, V_VALS}
    @test edgevals_type(g) == expected_type
end

@testset "hasedgekey" begin

    g1 = DummyValGraph(ValGraph(0; edgeval_types=(a=Int, b=String)))
    g2 = DummyValGraph(ValDiGraph(0; edgeval_types=(Int, )))

    @test hasedgekey(g1, :a)
    @test hasedgekey(typeof(g1), :a)
    @test hasedgekey(g1, :b)
    @test hasedgekey(typeof(g1), :b)
    @test !hasedgekey(g1, :c)
    @test !hasedgekey(typeof(g1), :c)
    @test hasedgekey(g1, 1)
    @test hasedgekey(typeof(g1), 1)
    @test hasedgekey(g1, 2)
    @test hasedgekey(typeof(g1), 2)
    @test !hasedgekey(g1, 0)
    @test !hasedgekey(typeof(g1), 0)
    @test !hasedgekey(g1, 3)
    @test !hasedgekey(typeof(g1), 3)

    @test hasedgekey(g2, 1)
    @test hasedgekey(typeof(g2), 1)
    @test !hasedgekey(g2, 0)
    @test !hasedgekey(typeof(g2), 2)
end

@testset "hasvertexkey" begin

    g1 = DummyValGraph(ValGraph(0; vertexval_types=(xy=Bool, ), vertexval_init=undef))
    g2 = DummyValGraph(ValDiGraph(0; vertexval_types=(Int, Int), vertexval_init=undef))

    @test hasvertexkey(g1, :xy)
    @test hasvertexkey(typeof(g1), :xy)
    @test !hasvertexkey(g1, :uv)
    @test !hasvertexkey(typeof(g1), :uv)
    @test hasvertexkey(g1, 1)
    @test hasvertexkey(typeof(g1), 1)
    @test !hasvertexkey(g1, 0)
    @test !hasvertexkey(typeof(g1), 0)
    @test !hasvertexkey(g1, 2)
    @test !hasvertexkey(typeof(g1), 2)


    @test hasvertexkey(g2, Int8(1))
    @test hasvertexkey(typeof(g2), Int8(1))
    @test hasvertexkey(g2, UInt8(2))
    @test hasvertexkey(typeof(g2), UInt8(2))
    @test !hasvertexkey(g2, 0)
    @test !hasvertexkey(typeof(g2), UInt8(0))
    @test !hasvertexkey(g2, 3)
    @test !hasvertexkey(typeof(g2), 3)
end

# TODO should we also test the non-exported hasvertexkey_or_throw, hasedgekey_or_throw?

# TODO test show

@testset "vertices" begin

    g1 = DummyValGraph(ValGraph{UInt8}(2))
    g2 = DummyValGraph(ValOutDiGraph{Int16}(3))

    @test allunique(vertices(g1))
    @test issetequal(vertices(g1), 1:2)
    @test allunique(vertices(g2))
    @test issetequal(vertices(g2), 1:3)
end

@testset "has_vertex" begin

    g = DummyValGraph(ValGraph{UInt8}(2))

    @test has_vertex(g, UInt8(1))
    @test has_vertex(g, 2)
    @test !has_vertex(g, 0)
    @test !has_vertex(g, 3)
    @test !has_vertex(g, -1)
end

@testset "edges" begin

    g_simple = SimpleGraph(Edge.([(1, 1), (1, 2), (4, 5)]))
    g_simple_di = SimpleDiGraph(Edge.([(1, 1), (1, 2), (4, 5), (5, 4)]))

    g1 = DummyValGraph(ValGraph{UInt16}(g_simple;
        edgeval_types=(a=Int64, b=Float64),
        edgeval_init=(s, d) -> (a=s, b=d)
    ))
    g2 = DummyValGraph(ValDiGraph{Int16}(g_simple_di;
        edgeval_types=(Int64, Float64),
        edgeval_init=(s, d) -> (s, d)
    ))

    @test edges(g1, :) isa ValEdgeIter{typeof(g1)}
    @test edges(g2, :) isa ValEdgeIter{typeof(g2)}

    @test eltype(edges(g1, :)) == ValEdge{UInt16, NamedTuple{(:a, :b), Tuple{Int64, Float64}}}
    @test eltype(edges(g2, :)) == ValDiEdge{Int16, Tuple{Int64, Float64}}

    @test collect(edges(g1, :)) == [
        ValEdge{UInt16, NamedTuple{(:a, :b), Tuple{Int64, Float64}}}(1, 1, (a=1, b=1.0)),
        ValEdge{UInt16, NamedTuple{(:a, :b), Tuple{Int64, Float64}}}(1, 2, (a=1, b=2.0)),
        ValEdge{UInt16, NamedTuple{(:a, :b), Tuple{Int64, Float64}}}(4, 5, (a=4, b=5.0))
    ]
    @test collect(edges(g2, :)) == [
        ValDiEdge{Int16, Tuple{Int64, Float64}}(1, 1, (1, 1.0)),
        ValDiEdge{Int16, Tuple{Int64, Float64}}(1, 2, (1, 2.0)),
        ValDiEdge{Int16, Tuple{Int64, Float64}}(4, 5, (4, 5.0)),
        ValDiEdge{Int16, Tuple{Int64, Float64}}(5, 4, (5, 4.0)),
    ]
end

@testset "edgetype" begin

    g1 = DummyValGraph(ValGraph{Int8}(0; edgeval_types=(Int16, Int32)))
    g2 = DummyValGraph(ValDiGraph{UInt8}(0; edgeval_types=(a=UInt16, b=UInt32)))

    @test edgetype(g1) == ValEdge{Int8, Tuple{}}
    @test edgetype(g2) == ValDiEdge{UInt8, Tuple{}}
end

@testset "ne" begin

    g_simple = SimpleGraph(Edge.([(1, 1), (1, 2), (4, 5)]))
    g_simple_di = SimpleDiGraph(Edge.([(1, 1), (1, 2), (4, 5), (5, 4)]))

    g1 = DummyValGraph(ValGraph(g_simple))
    g2 = DummyValGraph(ValDiGraph(g_simple_di))

    @test ne(g1) == 3
    @test ne(g2) == 4
end

@testset "outneightbors" begin

    g_simple = SimpleGraph(Edge.([(1, 1), (1, 2), (4, 5)]))
    g_simple_di = SimpleDiGraph(Edge.([(1, 1), (1, 2), (4, 5), (5, 4)]))

    g1 = DummyValGraph(ValGraph(g_simple))
    g2 = DummyValGraph(ValDiGraph(g_simple_di))

    @test outneighbors(g1, 1) == [1, 2]
    @test outneighbors(g1, 2) == [1]
    @test outneighbors(g1, 3) == []
    @test outneighbors(g1, 4) == [5]
    @test outneighbors(g1, 5) == [4]

    @test outneighbors(g2, 1) == [1, 2]
    @test outneighbors(g2, 2) == []
    @test outneighbors(g2, 3) == []
    @test outneighbors(g2, 4) == [5]
    @test outneighbors(g2, 5) == [4]
end

@testset "inneightbors" begin

    g_simple = SimpleGraph(Edge.([(1, 1), (1, 2), (4, 5)]))
    g_simple_di = SimpleDiGraph(Edge.([(1, 1), (1, 2), (4, 5), (5, 4)]))

    g1 = DummyValGraph(ValGraph(g_simple))
    g2 = DummyValGraph(ValDiGraph(g_simple_di))

    @test inneighbors(g1, 1) == [1, 2]
    @test inneighbors(g1, 2) == [1]
    @test inneighbors(g1, 3) == []
    @test inneighbors(g1, 4) == [5]
    @test inneighbors(g1, 5) == [4]

    @test inneighbors(g2, 1) == [1]
    @test inneighbors(g2, 2) == [1]
    @test inneighbors(g2, 3) == []
    @test inneighbors(g2, 4) == [5]
    @test inneighbors(g2, 5) == [4]
end

@testset "get_vertexval" begin

    g0 = DummyValGraph(ValDiGraph(2));

    g1 = DummyValGraph(ValGraph(2;
        vertexval_types=(Int64, ),
        vertexval_init=v -> (v, )
    ))

    g2 = DummyValGraph(ValOutDiGraph(2;
        vertexval_types=(a=Int64, b=String),
        vertexval_init=v -> (a=v, b="$v")
    ))

    @test get_vertexval(g0, 1, :) == ()
    @test get_vertexval(g0, 2, :) == ()
    @test get_vertexval(g1, 1, :) == (1,)
    @test get_vertexval(g1, 2, :) == (2,)
    @test get_vertexval(g2, 1, :) == (a=1, b="1")
    @test get_vertexval(g2, 2, :) == (a=2, b="2")

    @test get_vertexval(g1, 1, 1) == 1
    @test get_vertexval(g1, 2, 1) == 2
    @test get_vertexval(g2, 1, 1) == 1
    @test get_vertexval(g2, 2, 1) == 2
    @test get_vertexval(g2, 1, 2) == "1"
    @test get_vertexval(g2, 2, 2) == "2"

    @test get_vertexval(g2, 1, :a) == 1
    @test get_vertexval(g2, 2, :a) == 2
    @test get_vertexval(g2, 1, :b) == "1"
    @test get_vertexval(g2, 2, :b) == "2"

    @test get_vertexval(g1, 1) == 1
    @test get_vertexval(g1, 2) == 2
end

@testset "get_edgeval" begin

    g_simple = SimpleGraph(Edge.([(1, 1), (2, 3)]))
    g_simple_di = SimpleDiGraph(Edge.([(1, 1), (1, 2), (3, 4), (4, 3)]))

    g0 = DummyValGraph(ValGraph(g_simple))
    g1 = DummyValGraph(
        ValGraph(g_simple;
                 edgeval_types=(a=Int64, b=String),
                 edgeval_init=(s, d) ->(a=s, b="$d")
    ))
    g2 = DummyValGraph(
        ValDiGraph(g_simple_di;
                 edgeval_types=(Int64,),
                 edgeval_init=(s, d) ->(s,)
    ))

    @test get_edgeval(g0, 1, 1, :) == ()
    @test get_edgeval(g0, 2, 3, :) == ()
    @test get_edgeval(g0, 3, 2, :) == ()
    @test get_edgeval(g1, 1, 1, :) == (a=1, b="1")
    @test get_edgeval(g1, 2, 3, :) == (a=2, b="3")
    @test get_edgeval(g1, 3, 2, :) == (a=2, b="3")
    @test get_edgeval(g2, 1, 1, :) == (1,)
    @test get_edgeval(g2, 1, 2, :) == (1,)
    @test get_edgeval(g2, 3, 4, :) == (3,)
    @test get_edgeval(g2, 4, 3, :) == (4,)

    @test get_edgeval(g1, 1, 1, 1) == 1
    @test get_edgeval(g1, 2, 3, 1) == 2
    @test get_edgeval(g1, 3, 2, 1) == 2
    @test get_edgeval(g1, 1, 1, 2) == "1"
    @test get_edgeval(g1, 2, 3, 2) == "3"
    @test get_edgeval(g1, 3, 2, 2) == "3"
    @test get_edgeval(g2, 1, 1, 1) == 1
    @test get_edgeval(g2, 1, 2, 1) == 1
    @test get_edgeval(g2, 3, 4, 1) == 3
    @test get_edgeval(g2, 4, 3, 1) == 4

    @test get_edgeval(g1, 1, 1, :a) == 1
    @test get_edgeval(g1, 2, 3, :a) == 2
    @test get_edgeval(g1, 3, 2, :a) == 2
    @test get_edgeval(g1, 1, 1, :b) == "1"
    @test get_edgeval(g1, 2, 3, :b) == "3"
    @test get_edgeval(g1, 3, 2, :b) == "3"

    @test get_edgeval(g2, 1, 1) == 1
    @test get_edgeval(g2, 1, 2) == 1
    @test get_edgeval(g2, 3, 4) == 3
    @test get_edgeval(g2, 4, 3) == 4
end


end # testset
