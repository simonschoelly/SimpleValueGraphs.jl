
mutable struct TestMutStruct{T}
    x::T
end

const TEST_VERTEX_TYPES_SMALL = [Int8, Int32, Int64, UInt64]
const TEST_VERTEX_TYPES_BIG =
    [ UInt8,
      Int8,
      Int16,
      UInt16, 
      Int32,
      UInt32,
      Int64,
      UInt64,
      Int128,
      UInt128,
      BigInt
    ]

const TEST_EDGEVAL_TYPES_SMALL =
    [ Tuple{},
      Tuple{Float32},
      NamedTuple{(:a,), Tuple{Char}},
      NamedTuple{(:fst, :snd), Tuple{Int8, TestMutStruct{Bool}}}
    ]

const TEST_EDGEVAL_TYPES_SINGE_VALUE_SMALL =
    [ Tuple{TestMutStruct{Char}},
      NamedTuple{(:xyz,), Tuple{Tuple{Int8, UInt8}}},
      Tuple{Union{Int8, Float32}}
    ]

const TEST_EDGEVAL_TYPES_NON_SINGE_VALUE_SMALL =
    [ Tuple{},
      NamedTuple{(), Tuple{}},
      NamedTuple{(:one, :two), Tuple{Int, Int}},
      Tuple{Bool, Int16, UInt16}
    ]

#
# TODO needs more different types, also tuples and named tuples, unitful units, Union types, Nothing

const test_zero_edgval_types = [()]

const test_single_edgeval_types =
    [ (Int,),
      (a=Float16, ),
      (Union{Nothing, Char}, ),
      (a=Tuple{Int, Float32}, ),
      (Vector{Int32}, ),
      (a=Vector, ),
      (NamedTuple{(:a, :b), Tuple{Char, UInt16}}, ),
    ]

const test_multi_edgeval_types =
    [ (Int, Float32),
      (a=Float64, b=Float64),
      (Int8, Int16, Int8),
      (a=Vector{Int64}, b=Tuple{Int, Int}, c=Union{Nothing, Int}),
    ] 

const test_edgeval_types = union(
        test_zero_edgval_types,
        test_single_edgeval_types,
        test_multi_edgeval_types
    )

function make_testgraphs(G::Type{<:AbstractGraph}; kwargs...)
    return Channel(c -> _make_testgraphs(c, G, kwargs...))
end

# Similar to `rand` but for more types.
# We do not want type piracy, so we need this.
function rand_sample(::Type{<:Rational{T}}) where {T}
    # TODO do we want to avoid division by zero?
    return rand(T) // rand(T)
end

rand_sample(T::Type) = rand(T)

rand_sample(::Type{Nothing}) = nothing
rand_sample(::Type{Missing}) = missing

rand_sample(::Type{TestMutStruct{T}}) where {T} = TestMutStruct(rand_sample(T))

function rand_sample(U::Union)
    i = rand(1:length(propertynames(U)))
    return rand_sample(getproperty(U, propertynames(U)[i]))
end

function rand_sample(T::Type, dims...)
    result = Array{T}(undef, dims)
    for i in eachindex(result)
        result[i] = rand_sample(T)
    end
    return result
end

function rand_sample(T::Type{<:Union{Tuple, NamedTuple}})
    return T(rand_sample(TT) for TT in T.types)
end


function _make_testgraphs(c::Channel, ::Type{SimpleGraph{V}}; kwargs...) where {V}
        g = SimpleGraph{V}(0)
        info = "$(typeof(g)) 0-graph"
        put!(c, (graph=g, info=info))

        g = SimpleGraph{V}(1)
        info = "$(typeof(g)) 1 vert, 0 edges"
        put!(c, (graph=g, info=info))

        g = SimpleGraph{V}(1)
        add_edge!(g, 1, 1)
        info = "$(typeof(g)) 1 vert, 1 loop"
        put!(c, (graph=g, info=info))

        g = SimpleGraph{V}(2)
        info = "$(typeof(g)) 2 verts, 0 edges"
        put!(c, (graph=g, info=info))

        g = SimpleGraph{V}(2)
        add_edge!(g, 1, 2)
        info = "$(typeof(g)) 2 vers, 1 edge"
        put!(c, (graph=g, info=info))

        g = SimpleGraph{V}(2)
        add_edge!(g, 2, 2)
        info = "$(typeof(g)) 2 verts, 1 edge, 1 loop"
        put!(c, (graph=g, info=info))

        g = SimpleGraph{V}(2)
        add_edge!(g, 2, 2)
        info = "$(typeof(g)) 2 verts, 1 edge, 1 loop"
        put!(c, (graph=g, info=info))

        g = SimpleGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 1, 1)
        info = "$(typeof(g)) 2 verts, 1 edge, 1 loop"
        put!(c, (graph=g, info=info))

        g = SimpleGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 1, 1)
        add_edge!(g, 2, 2)
        info = "$(typeof(g)) 2 verts, 1 edge, 1 loop"
        put!(c, (graph=g, info=info))

        g = CompleteGraph(V(5))
        info = "$(typeof(g)) CompleteGraph(5)"
        put!(c, (graph=g, info=info))
end

function _make_testgraphs(c::Channel, ::Type{SimpleDiGraph{V}}; kwargs...) where{V}
        g = SimpleDiGraph{V}(0)
        info = "$(typeof(g)) 0-graph"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(1)
        info = "$(typeof(g)) 1 vert"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(1)
        add_edge!(g, 1, 1)
        info = "$(typeof(g)) 1 vert, 1 loop"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        info = "$(typeof(g)) 2 verts, 0 edge"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        info = "$(typeof(g)) 2 verts, 1 edge"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        add_edge!(g, 2, 2)
        info = "$(typeof(g)) 2 verts, 2 edges, 1 loop"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 1)
        add_edge!(g, 1, 2)
        info = "$(typeof(g)) 2 verts, 1 edge, 1 loop"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 1)
        add_edge!(g, 2, 2)
        info = "$(typeof(g)) 2 verts, 2 edges, 2 loop"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        info = "$(typeof(g)) 2 verts, 2 edges"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        add_edge!(g, 2, 2)
        info = "$(typeof(g)) 2 verts, 3 edges, 1 loops"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 1, 1)
        add_edge!(g, 2, 2)
        info = "$(typeof(g)) 2 verts, 3 edges, 2 loops"
        put!(c, (graph=g, info=info))

        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        add_edge!(g, 1, 1)
        add_edge!(g, 2, 2)
        info = "$(typeof(g)) 2 verts 4 edges, 1 loop"
        put!(c, (graph=g, info=info))
end


function testgraphA()
    g = ValueGraph(CompleteBipartiteGraph(3, 4))
    add_edge!(g, 1, 4, 10.0)
    return g
end

# TODO only works for undirected graphs
# TODO allow for only non-negative or positive weights
function graph_with_randvals(g::AbstractGraph{T}) where {T}
    U = Float64
    resultg = ValueGraph{T, U}(nv(g))
    for e in edges(g)
        s, d = src(e), dst(e)
        add_edge!(resultg, s, d, convert(U, randn()))
    end
    return resultg
end

function is_strictly_increasing(list)
    return all(2:length(list)) do i
        @inbounds list[i - 1] < list[i]
    end
end



# TODO these functions are not finished yet
function testset_isvalidgraph(g::ValueGraph; undef_edgevalues::Bool=false)
    @testset "Is valid graph" begin
        @testset "g.ne has correct value" begin
            # Each edge, apart from self-loops occurs twice
            should_be_twice = 0
            for (u, list) in enumerate(g.fadjlist)
                for v in list
                    should_be_twice += ifelse(u == v, 2, 1)
                end
            end
            @test 2 * g.ne == should_be_twice
        end

        @testset "Lists have same sizes" begin
            lengths_should_be = length.(g.fadjlist)
            @test all(g.edgevals) do adjlist
                    length.(adjlist) == lengths_should_be
            end
        end
        
        @testset "Adjacency list are strictly increasing" begin
            @test all(is_strictly_increasing, g.fadjlist)
        end

        @testset "Symmetric Adjanceny list" begin
            issym = true
            for (u, list_u) in enumerate(g.fadjlist)
                for v in list_u
                    @inbounds list_v = g.fadjlist[v]
                    index = searchsortedfirst(list_v, u)
                    issym &= (index <= length(list_v) && list_v[index] == u)
                end
            end
            @test issym
        end

        if !undef_edgevalues && !isempty(g.edgevals)
            @testset "Symmetric values for key $key" for key in keys(g.edgevals)
                value_adjlist = g.edgevals[key]
                issym = true
                for (u, list_u) in enumerate(g.fadjlist)
                    for (index_u, v) in enumerate(list_u)
                        @inbounds list_v = g.fadjlist[v]
                        index_v = searchsortedfirst(list_v, u)
                        @inbounds issym &= value_adjlist[u][index_u] == value_adjlist[v][index_v]
                    end
                end
                @test issym
            end
        end

    end
end

function testset_isvalidgraph(g::ValueOutDiGraph; undef_edgevalues::Bool=false)
    @testset "Is valid graph" begin
        @testset "g.ne has correct value" begin
            should_be = mapreduce(length, +, g.fadjlist, init=0)
            @test g.ne == should_be
        end

        @testset "Lists have same sizes" begin
            lengths_should_be = length.(g.fadjlist)
            @test all(g.edgevals) do adjlist
                    length.(adjlist) == lengths_should_be
            end
        end

        @testset "Adjacency list are strictly increasing" begin
            @test all(is_strictly_increasing, g.fadjlist)
        end
    end
end

function testset_isvalidgraph(g::ValueDiGraph; undef_edgevalues::Bool=false)
    @testset "Is valid graph" begin
        @testset "g.ne has correct value" begin
            should_be_forwards = mapreduce(length, +, g.fadjlist, init=0)
            should_be_backwards = mapreduce(length, +, g.badjlist, init=0)
            @test g.ne == should_be_forwards == should_be_backwards
        end

        @testset "Lists have same sizes" begin
            lengths_should_be = length.(g.fadjlist)
            @test all(g.edgevals) do adjlist
                    length.(adjlist) == lengths_should_be
            end
            lengths_should_be = length.(g.badjlist)
            @test all(g.redgevals) do adjlist
                    length.(adjlist) == lengths_should_be
            end
        end

        @testset "Adjacency list are strictly increasing" begin
            @test all(is_strictly_increasing, g.fadjlist)
            @test all(is_strictly_increasing, g.badjlist)
        end

        @testset "Symmetric Adjanceny list" begin
            issym = true
            for (u, list_u) in enumerate(g.fadjlist)
                for v in list_u
                    @inbounds list_v = g.badjlist[v]
                    index = searchsortedfirst(list_v, u)
                    issym &= (index <= length(list_v) && list_v[index] == u)
                end
            end
            @test issym
        end

        if !undef_edgevalues && !isempty(g.edgevals)
            @testset "Symmetric values for key $key" for key in keys(g.edgevals)
                value_adjlist = g.edgevals[key]
                value_badjlist = g.redgevals[key]
                issym = true
                for (u, list_u) in enumerate(g.fadjlist)
                    for (index_u, v) in enumerate(list_u)
                        @inbounds list_v = g.badjlist[v]
                        index_v = searchsortedfirst(list_v, u)
                        @inbounds issym &= value_adjlist[u][index_u] == value_badjlist[v][index_v]
                    end
                end
                @test issym
            end
        end
    end
end

function testset_topological_equivalent(g::SimpleGraph, gv::ValueGraph)
    @testset "Topological equivalent" begin
        @test g.fadjlist == gv.fadjlist
    end
end

function testset_topological_equivalent(g::SimpleDiGraph, gv::ValueOutDiGraph)
    @testset "Topological equivalent" begin
        @test g.fadjlist == gv.fadjlist
    end
end

function testset_topological_equivalent(g::SimpleDiGraph, gv::ValueDiGraph)
    @testset "Topological equivalent" begin
        @test g.fadjlist == gv.fadjlist
        @test g.badjlist == gv.badjlist
    end
end


allkeys_for_E_VALS(E_VALS::Type{<:Tuple}) = 1:length(E_VALS.types)
allkeys_for_E_VALS(E_VALS::Type{<:NamedTuple}) = E_VALS.names ∪
                                                 (1:length(E_VALS.names))
