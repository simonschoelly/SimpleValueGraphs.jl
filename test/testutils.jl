# TODO this should contain helper functions for testing
using InteractiveUtils: subtypes

const test_vertex_types = subtypes(Signed) ∪ subtypes(Unsigned)
#
# TODO needs more different types, also tuples and named tuples, unitful units, Union types, Nothing
const test_edgeval_types = [Rational{Int}, Float16, Float64, BigFloat, Int, UInt8, Tuple{Int, Int}, NamedTuple{(:a, :b), Tuple{Int, Int}}]

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

function rand_sample(U::Union)
    i = rand(1:length(propertynames(U)))
    return rand_sample(getproperty(U, propertynames(U)[i]))
end

function rand_sample(T::Type, dims...)
    result = Array{T}(dims)
    for i in eachindex(result)
        result[i] = rand_sample(T)
    end
    return result
end

function rand_sample(T::Type{<:Union{Tuple, NamedTuple}})
    return T(rand_sample(TT) for TT in T.types)
end


function _make_testgraphs(c::Channel, ::Type{SimpleGraph}; kwargs...)
    for V in test_vertex_types
        g = SimpleGraph{V}(0)
        info = """type: $(typeof(g))
                  0-graph"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleGraph{V}(1)
        info = """type: $(typeof(g))
                  1-graph"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleGraph{V}(1)
        add_edge!(g, 1, 1)
        info = """type: $(typeof(g))
                  1-graph with self-loop"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleGraph{V}(2)
        info = """type: $(typeof(g))
                  2-vertex-graph, no edges"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleGraph{V}(2)
        add_edge!(g, 1, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleGraph{V}(2)
        add_edge!(g, 2, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, no edge, 1 self-loop"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleGraph{V}(2)
        add_edge!(g, 2, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, no edge, 2 self-loops"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 1, 1)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge, 1 self-loop"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 1, 1)
        add_edge!(g, 2, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge, 2 self-loops"""
        put!(c, (graph=g, info=info))
    end
end

function _make_testgraphs(c::Channel, ::Type{SimpleDiGraph}; kwargs...)
    for V in test_vertex_types
        g = SimpleDiGraph{V}(0)
        info = """type: $(typeof(g))
                  0-graph"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(1)
        info = """type: $(typeof(g))
                  1-graph"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(1)
        add_edge!(g, 1, 1)
        info = """type: $(typeof(g))
                  1-graph with self-loop"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        info = """type: $(typeof(g))
                  2-vertex-graph, no edges"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        add_edge!(g, 2, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 self loop"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 1)
        add_edge!(g, 1, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge, 1 self loop"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 1)
        add_edge!(g, 2, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 2 self loops"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge, 1 reverse edge"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        add_edge!(g, 2, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge, 1 reverse edge, 1 self loop"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 1, 1)
        add_edge!(g, 2, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge, 2 self loops"""
        put!(c, (graph=g, info=info))
    end
    for V in test_vertex_types
        g = SimpleDiGraph{V}(2)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        add_edge!(g, 1, 1)
        add_edge!(g, 2, 2)
        info = """type: $(typeof(g))
                  2-vertex-graph, 1 edge, 1 reverse edge, 2 self loops"""
        put!(c, (graph=g, info=info))
    end
end


function testgraphA()
    g = SimpleValueGraph(CompleteBipartiteGraph(3, 4))
    add_edge!(g, 1, 4, 10.0)
    return g
end

# TODO only works for undirected graphs
# TODO allow for only non-negative or positive weights
function graph_with_randvals(g::AbstractGraph{T}) where {T}
    U = Float64
    resultg = SimpleValueGraph{T, U}(nv(g))
    for e in edges(g)
        s, d = src(e), dst(e)
        add_edge!(resultg, s, d, convert(U, randn()))
    end
    return resultg
end

