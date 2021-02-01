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

SimpleValueGraphs.set_vertexval!(g::DummyValGraph, v, key::Integer, value) =
    set_vertexval!(g.wrapped, v, key, value)

SimpleValueGraphs.get_edgeval(g::DummyValGraph, s, d, key::Integer) =
    get_edgeval(g.wrapped, s, d, key)

SimpleValueGraphs.set_edgeval!(g::DummyValGraph, s, d, key::Integer, value) =
    set_edgeval!(g.wrapped, s, d, key, value)

SimpleValueGraphs.get_graphval(g::DummyValGraph, key::Integer) =
    get_graphval(g.wrapped, key)

SimpleValueGraphs.set_graphval!(g::DummyValGraph, key::Integer, value) =
    set_graphval!(g.wrapped, key, value)

SimpleValueGraphs.add_vertex!(g::DummyValGraph, values) = add_vertex!(g.wrapped, values)

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

@testset "hasedgekey_or_throw" begin

    g0 = DummyValGraph(ValOutDiGraph(Int8(0)))
    g1 = DummyValGraph(ValGraph(1; edgeval_types=(a=Int, b=String)))
    g2 = DummyValGraph(ValDiGraph(2; edgeval_types=(Int, )))

    G0 = typeof(g0)
    G1 = typeof(g1)
    G2 = typeof(g2)

    @test_throws Exception hasedgekey_or_throw(g0, 1)
    @test_throws Exception hasedgekey_or_throw(G0, 1)
    @test_throws Exception hasedgekey_or_throw(g0, 0)
    @test_throws Exception hasedgekey_or_throw(G0, 0)
    @test_throws Exception hasedgekey_or_throw(g0, :a)
    @test_throws Exception hasedgekey_or_throw(G0, :a)

    @test hasedgekey_or_throw(g1, :a) == nothing
    @test hasedgekey_or_throw(G1, :a) == nothing
    @test hasedgekey_or_throw(g1, :b) == nothing
    @test hasedgekey_or_throw(G1, :b) == nothing
    @test_throws Exception hasedgekey_or_throw(g1, :c)
    @test_throws Exception hasedgekey_or_throw(G1, :c)
    @test hasedgekey_or_throw(g1, 1) == nothing
    @test hasedgekey_or_throw(G1, 1) == nothing
    @test hasedgekey_or_throw(g1, 2) == nothing
    @test hasedgekey_or_throw(G1, 2) == nothing
    @test_throws Exception hasedgekey_or_throw(g1, 3)
    @test_throws Exception hasedgekey_or_throw(G1, 3)

    @test hasedgekey_or_throw(g2, 1) == nothing
    @test hasedgekey_or_throw(G2, 1) == nothing
    @test_throws Exception hasedgekey_or_throw(g2, 0)
    @test_throws Exception hasedgekey_or_throw(G2, 2)
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

@testset "outedgevals" begin

    g4 = ValOutDiGraph{Int16}(4, edgeval_types=(a=String,))
    add_edge!(g4, 1, 2, (a="12",))
    add_edge!(g4, 2, 2, (a="22",))
    add_edge!(g4, 1, 4, (a="14",))
    add_edge!(g4, 4, 1, (a="41",))
    g4 = DummyValGraph(g4)

    @test outedgevals(g4, 1) == ["12", "14"]
    @test outedgevals(g4, 2) == ["22"]
    @test outedgevals(g4, 3) == []
    @test outedgevals(g4, 4) == ["41"]

    @test outedgevals(g4, 1, 1) == ["12", "14"]
    @test outedgevals(g4, 2, 1) == ["22"]
    @test outedgevals(g4, 3, 1) == []
    @test outedgevals(g4, 4, 1) == ["41"]

    @test outedgevals(g4, 1, :a) == ["12", "14"]
    @test outedgevals(g4, 2, :a) == ["22"]
    @test outedgevals(g4, 3, :a) == []
    @test outedgevals(g4, 4, :a) == ["41"]

    @test outedgevals(g4, 1, :) == [(a="12",), (a="14",)]
    @test outedgevals(g4, 2, :) == [(a="22",)]
    @test outedgevals(g4, 3, :) == []
    @test outedgevals(g4, 4, :) == [(a="41",)]


    g3 = ValGraph{UInt64}(3, edgeval_types=(x=String, y=Tuple{Int, Int}))
    add_edge!(g3, 1, 2, (x="12", y=(1,2)))
    add_edge!(g3, 2, 3, (x="23", y=(2,3)))
    add_edge!(g3, 3, 3, (x="33", y=(3,3)))
    g3 = DummyValGraph(g3)

    @test outedgevals(g3, 1, 1) == ["12"]
    @test outedgevals(g3, 2, 1) == ["12", "23"]
    @test outedgevals(g3, 3, 1) == ["23", "33"]
    @test outedgevals(g3, 1, 2) == [(1,2)]
    @test outedgevals(g3, 2, 2) == [(1,2), (2,3)]
    @test outedgevals(g3, 3, 2) == [(2,3), (3,3)]

    @test outedgevals(g3, 1, :x) == ["12"]
    @test outedgevals(g3, 2, :x) == ["12", "23"]
    @test outedgevals(g3, 3, :x) == ["23", "33"]
    @test outedgevals(g3, 1, :y) == [(1,2)]
    @test outedgevals(g3, 2, :y) == [(1,2), (2,3)]
    @test outedgevals(g3, 3, :y) == [(2,3), (3,3)]

    @test outedgevals(g3, 1, :) == [(x="12", y=(1,2))]
    @test outedgevals(g3, 2, :) == [(x="12", y=(1,2)), (x="23", y=(2,3))]
    @test outedgevals(g3, 3, :) == [(x="23", y=(2,3)), (x="33", y=(3,3))]
end

@testset "inedgevals" begin

    g4 = ValDiGraph(4, edgeval_types=(a=String,))
    add_edge!(g4, 1, 2, (a="12",))
    add_edge!(g4, 2, 2, (a="22",))
    add_edge!(g4, 1, 4, (a="14",))
    add_edge!(g4, 4, 1, (a="41",))
    g4 = DummyValGraph(g4)

    @test inedgevals(g4, 1) == ["41"]
    @test inedgevals(g4, 2) == ["12", "22"]
    @test inedgevals(g4, 3) == []
    @test inedgevals(g4, 4) == ["14"]

    @test inedgevals(g4, 1, 1) == ["41"]
    @test inedgevals(g4, 2, 1) == ["12", "22"]
    @test inedgevals(g4, 3, 1) == []
    @test inedgevals(g4, 4, 1) == ["14"]

    @test inedgevals(g4, 1, :a) == ["41"]
    @test inedgevals(g4, 2, :a) == ["12", "22"]
    @test inedgevals(g4, 3, :a) == []
    @test inedgevals(g4, 4, :a) == ["14"]

    @test inedgevals(g4, 1, :) == [(a="41",)]
    @test inedgevals(g4, 2, :) == [(a="12",), (a="22",)]
    @test inedgevals(g4, 3, :) == []
    @test inedgevals(g4, 4, :) == [(a="14",)]


    g3 = ValDiGraph{UInt8}(3, edgeval_types=(x=String, y=Tuple{Int, Int}))
    add_edge!(g3, 1, 2, (x="12", y=(1,2)))
    add_edge!(g3, 2, 3, (x="23", y=(2,3)))
    add_edge!(g3, 3, 2, (x="32", y=(3,2)))
    add_edge!(g3, 3, 3, (x="33", y=(3,3)))
    g3 = DummyValGraph(g3)

    @test inedgevals(g3, 1, 1) == []
    @test inedgevals(g3, 2, 1) == ["12", "32"]
    @test inedgevals(g3, 3, 1) == ["23", "33"]
    @test inedgevals(g3, 1, 2) == []
    @test inedgevals(g3, 2, 2) == [(1,2), (3,2)]
    @test inedgevals(g3, 3, 2) == [(2,3), (3,3)]

    @test inedgevals(g3, 1, :x) == []
    @test inedgevals(g3, 2, :x) == ["12", "32"]
    @test inedgevals(g3, 3, :x) == ["23", "33"]
    @test inedgevals(g3, 1, :y) == []
    @test inedgevals(g3, 2, :y) == [(1,2), (3,2)]
    @test inedgevals(g3, 3, :y) == [(2,3), (3,3)]

    @test inedgevals(g3, 1, :) == []
    @test inedgevals(g3, 2, :) == [(x="12", y=(1,2)), (x="32", y=(3,2))]
    @test inedgevals(g3, 3, :) == [(x="23", y=(2,3)), (x="33", y=(3,3))]
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

@testset "set_vertexval!" begin

    g0 = DummyValGraph(ValDiGraph(2));

    g1 = DummyValGraph(ValGraph(Int8(2);
        vertexval_types=(Int64, ),
        vertexval_init=v -> (v, )
    ))

    g2 = DummyValGraph(ValOutDiGraph(UInt16(2);
        vertexval_types=(a=Int64, b=String),
        vertexval_init=v -> (a=v, b="$v")
    ))

    @test set_vertexval!(g0, 2, :, ()) == true
    @test set_vertexval!(g0, 0, :, ()) == false

    @test set_vertexval!(g1, 1, 11) == true
    @test get_vertexval(g1, 1) == 11
    @test get_vertexval(g1, 2) == 2
    @test set_vertexval!(g1, 2, 22) == true
    @test get_vertexval(g1, 1) == 11
    @test get_vertexval(g1, 2) == 22
    @test set_vertexval!(g1, 3, 33) == false
    @test get_vertexval(g1, 1) == 11
    @test get_vertexval(g1, 2) == 22

    @test set_vertexval!(g1, 1, :, (111,)) == true
    @test get_vertexval(g1, 1) == 111
    @test get_vertexval(g1, 2) == 22
    @test set_vertexval!(g1, 0, :, (44,)) == false
    @test get_vertexval(g1, 1) == 111
    @test get_vertexval(g1, 2) == 22

    @test set_vertexval!(g2, 1, :a, 11) == true
    @test get_vertexval(g2, 1, :) == (a=11, b="1")
    @test get_vertexval(g2, 2, :) == (a=2, b="2")
    @test set_vertexval!(g2, 2, :b, "22") == true
    @test get_vertexval(g2, 1, :) == (a=11, b="1")
    @test get_vertexval(g2, 2, :) == (a=2, b="22")
    @test set_vertexval!(g2, 3, :b, "33") == false
    @test get_vertexval(g2, 1, :) == (a=11, b="1")
    @test get_vertexval(g2, 2, :) == (a=2, b="22")
    @test set_vertexval!(g2, 1, :, (a=111, b="111")) == true
    @test get_vertexval(g2, 1, :) == (a=111, b="111")
    @test get_vertexval(g2, 2, :) == (a=2, b="22")
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

@testset "set_edgeval!" begin

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

    @test set_edgeval!(g0, 1, 1, :, ()) == true
    @test set_edgeval!(g0, 2, 3, :, ()) == true
    @test set_edgeval!(g0, 3, 2, :, ()) == true
    @test set_edgeval!(g0, 1, 3, :, ()) == false
    @test set_edgeval!(g0, 3, 3, :, ()) == false

    @test set_edgeval!(g1, 1, 1, :a, 11) == true
    @test outedgevals(g1, 1, :) == [(a=11, b="1")]
    @test outedgevals(g1, 2, :) == [(a=2, b="3")]
    @test outedgevals(g1, 3, :) == [(a=2, b="3")]
    @test set_edgeval!(g1, 2, 3, :b, "33") == true
    @test outedgevals(g1, 1, :) == [(a=11, b="1")]
    @test outedgevals(g1, 2, :) == [(a=2, b="33")]
    @test outedgevals(g1, 3, :) == [(a=2, b="33")]
    @test set_edgeval!(g1, 1, 2, :b, "22") == false
    @test outedgevals(g1, 1, :) == [(a=11, b="1")]
    @test outedgevals(g1, 2, :) == [(a=2, b="33")]
    @test outedgevals(g1, 3, :) == [(a=2, b="33")]
    @test set_edgeval!(g1, 3, 2, :, (a=222, b="333")) == true
    @test outedgevals(g1, 1, :) == [(a=11, b="1")]
    @test outedgevals(g1, 2, :) == [(a=222, b="333")]
    @test outedgevals(g1, 3, :) == [(a=222, b="333")]

    @test set_edgeval!(g2, 3, 4, 33) == true
    @test outedgevals(g2, 1) == [1, 1]
    @test outedgevals(g2, 2) == []
    @test outedgevals(g2, 3) == [33]
    @test outedgevals(g2, 4) == [4]
    @test set_edgeval!(g2, 1, 3, 11) == false
    @test outedgevals(g2, 1) == [1, 1]
    @test outedgevals(g2, 2) == []
    @test outedgevals(g2, 3) == [33]
    @test outedgevals(g2, 4) == [4]

end

@testset "get_graphval" begin

    g1 = DummyValGraph(ValGraph(1, graphvals=(1, "2")))
    g2 = DummyValGraph(ValDiGraph(2, graphvals=(x=1, y="2")))
    g3 = DummyValGraph(ValOutDiGraph(3, graphvals=(a="1", )))
    g4 = DummyValGraph(ValOutDiGraph(Int(4)))

    @test get_graphval(g1, :) == (1, "2")

    @test get_graphval(g2, :x) == 1
    @test get_graphval(g2, :y) == "2"
    @test get_graphval(g2, :) == (x=1, y="2")

    @test get_graphval(g3) == "1"
    @test get_graphval(g3, :a) == "1"
    @test get_graphval(g3, :) == (a="1",)

    @test get_graphval(g4, :) == ()
end

@testset "set_graphval!" begin

    g1 = DummyValGraph(ValGraph(1, graphvals=(1, "2")))
    g2 = DummyValGraph(ValDiGraph(2, graphvals=(x=1, y="2")))
    g3 = DummyValGraph(ValOutDiGraph(3, graphvals=(a="1", )))
    g4 = DummyValGraph(ValOutDiGraph(Int(4)))

    set_graphval!(g1, :, (10, "20"))
    @test get_graphval(g1, :) == (10, "20")

    set_graphval!(g2, :x , 10)
    @test get_graphval(g2, :) == (x=10, y="2")
    set_graphval!(g2, :y, "20")
    @test get_graphval(g2, :) == (x=10, y="20")
    set_graphval!(g2, :, (x=100, y="200"))
    @test get_graphval(g2, :) == (x=100, y="200")

    set_graphval!(g3, "10")
    @test get_graphval(g3) == "10"
    set_graphval!(g3, :, (a="100",))
    @test get_graphval(g3) == "100"
    set_graphval!(g3, :a, "1000")
    @test get_graphval(g3) == "1000"

    set_graphval!(g4, :, ())
    @test get_graphval(g4, :) == ()
end

@testset "add_vertex!" begin

    ga = DummyValGraph(ValGraph{UInt64}(0, edgeval_types=(a=Int64, b=Char)))
    gb = DummyValGraph(ValDiGraph{Int8}(0))

    add_vertex!(ga)
    @test nv(ga) == 1
    add_vertex!(ga)
    @test nv(ga) == 2

    add_vertex!(gb)
    @test nv(gb) == 1
    add_vertex!(gb)
    @test nv(gb) == 2
end

end # testset

