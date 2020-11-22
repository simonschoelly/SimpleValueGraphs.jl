using SimpleValueGraphs: hasedgekey_or_throw, AbstractValGraph
@testset "abstractvaluegraph" begin

struct DummyValGraph{V, V_VALS, E_VALS, G <: AbstractValGraph{V, V_VALS, E_VALS}} <: AbstractValGraph{V, V_VALS, E_VALS}

    wrapped::G
end

SimpleValueGraphs.nv(g::DummyValGraph) = nv(g.wrapped)
SimpleValueGraphs.is_directed(::Type{<:DummyValGraph{V, V_VALS, E_VALS, G}}) where {V, V_VALS, E_VALS, G} = is_directed(G)
SimpleValueGraphs.has_edge(g::DummyValGraph, s, d) = has_edge(g.wrapped, s, d)
SimpleValueGraphs.get_edgeval(g::DummyValGraph, s, d, key::Integer) =
    get_edgeval(g.wrapped, s, d, key)
SimpleValueGraphs.get_vertexval(g::DummyValGraph, v, key::Integer) =
    get_vertexval(g.wrapped, v, key)

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
        vertexval_initializer=undef
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

    g1 = DummyValGraph(ValGraph(0; vertexval_types=(xy=Bool, ), vertexval_initializer=undef))
    g2 = DummyValGraph(ValDiGraph(0; vertexval_types=(Int, Int), vertexval_initializer=undef))

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


end # testset
