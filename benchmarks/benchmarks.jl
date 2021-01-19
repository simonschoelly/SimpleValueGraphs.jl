using BenchmarkTools
using SimpleValueGraphs, LightGraphs
using SimpleWeightedGraphs, MetaGraphs
using SNAPDatasets: loadsnap, snap_graphs
using SparseArrays
using Random: MersenneTwister


function load_graph_with_rand_weights(name::Symbol)

    if name ∈ keys(snap_graphs)
        g = squash(loadsnap(name))

        rng = MersenneTwister(0)
        G = is_directed(g) ? ValDiGraph : ValGraph
        return G(g; edgeval_types=(weight=Float64, ),
                 edgeval_init=(s, d) -> (weight=rand(rng, 1:255),))
    end

    error("no graph called :$name found.")
end

function graph_with_weights(::Type{SimpleGraph{T}}, ::Type{Matrix}, name) where {T}

    gv = load_graph_with_rand_weights(name)

    g = SimpleGraph{T}(adjacency_matrix(gv))
    matrix = Matrix(weights(gv))

    return (graph=g, weights=matrix)
end

function graph_with_weights(::Type{SimpleGraph{T}}, ::Type{SparseMatrixCSC}, name) where {T}

    gv = load_graph_with_rand_weights(name)

    g = SimpleGraph{T}(adjacency_matrix(gv))
    matrix = SparseMatrixCSC(weights(gv))

    return (graph=g, weights=matrix)
end

function graph_with_weights(::Type{SimpleWeightedGraph{T}}, name) where {T}

    gv = load_graph_with_rand_weights(name)

    return SimpleWeightedGraph{T}(weights(gv))
end

function graph_with_weights(::Type{MetaGraph{T}}, name) where {T}

    T == Int || error("Currently only MetaGraph{Int} is supported")

    g, w = graph_with_weights(SimpleGraph{T}, SparseMatrixCSC, name)
    gm = MetaGraph(g)
    for e in edges(gm)
        set_prop!(gm, e, :weight, w[src(e), dst(e)])
    end

    return gm
end

function graph_with_weights(::Type{ValGraph{T}}, name) where {T}

    g, w = graph_with_weights(SimpleGraph{T}, SparseMatrixCSC, name)
    return ValGraph(g, edgeval_types=(Float64,), edgeval_init=(s, d) -> (w[s,d],))
end


suite = BenchmarkGroup()

suite["prim_mst"] = BenchmarkGroup()
suite["prim_mst"]["facebook"] = BenchmarkGroup()

suite["prim_mst"]["facebook"]["SimpleGraph{Int} + Matrix"] =
    @benchmarkable prim_mst(g, m) setup=((g, m) = graph_with_weights(SimpleGraph{Int}, Matrix, :facebook_combined))
suite["prim_mst"]["facebook"]["SimpleGraph{Int} + SparseMatrixCSC"] =
    @benchmarkable prim_mst(g, m) setup=((g, m) = graph_with_weights(SimpleGraph{Int}, SparseMatrixCSC, :facebook_combined))
suite["prim_mst"]["facebook"]["SimpleWeightedGraph{Int}"] =
    @benchmarkable prim_mst(g) setup=(g = graph_with_weights(SimpleWeightedGraph{Int}, :facebook_combined))
suite["prim_mst"]["facebook"]["MetaGraph{Int}"] =
    @benchmarkable prim_mst(g) setup=(g = graph_with_weights(MetaGraph{Int}, :facebook_combined))
suite["prim_mst"]["facebook"]["ValGraph{Int}"] =
    @benchmarkable prim_mst(g) setup=(g = graph_with_weights(ValGraph{Int}, :facebook_combined))


suite["boruvka_mst"] = BenchmarkGroup()
suite["boruvka_mst"]["facebook"] = BenchmarkGroup()

suite["boruvka_mst"]["facebook"]["SimpleGraph{Int} + Matrix"] =
    @benchmarkable boruvka_mst(g, m) setup=((g, m) = graph_with_weights(SimpleGraph{Int}, Matrix, :facebook_combined))
suite["boruvka_mst"]["facebook"]["SimpleGraph{Int} + SparseMatrixCSC"] =
    @benchmarkable boruvka_mst(g, m) setup=((g, m) = graph_with_weights(SimpleGraph{Int}, SparseMatrixCSC, :facebook_combined))
suite["boruvka_mst"]["facebook"]["SimpleWeightedGraph{Int}"] =
    @benchmarkable boruvka_mst(g) setup=(g = graph_with_weights(SimpleWeightedGraph{Int}, :facebook_combined))
suite["boruvka_mst"]["facebook"]["MetaGraph{Int}"] =
    @benchmarkable boruvka_mst(g) setup=(g = graph_with_weights(MetaGraph{Int}, :facebook_combined))
suite["boruvka_mst"]["facebook"]["ValGraph{Int}"] =
    @benchmarkable boruvka_mst(g) setup=(g = graph_with_weights(ValGraph{Int}, :facebook_combined))


suite["dijkstra_shortest_paths"] = BenchmarkGroup()
suite["dijkstra_shortest_paths"]["facebook"] = BenchmarkGroup()

suite["dijkstra_shortest_paths"]["facebook"]["SimpleGraph{Int} + Matrix"] =
    @benchmarkable dijkstra_shortest_paths(g, 1, m) setup=((g, m) = graph_with_weights(SimpleGraph{Int}, Matrix, :facebook_combined))
suite["dijkstra_shortest_paths"]["facebook"]["SimpleGraph{Int} + SparseMatrixCSC"] =
    @benchmarkable dijkstra_shortest_paths(g, 1, m) setup=((g, m) = graph_with_weights(SimpleGraph{Int}, SparseMatrixCSC, :facebook_combined))
suite["dijkstra_shortest_paths"]["facebook"]["SimpleWeightedGraph{Int}"] =
    @benchmarkable dijkstra_shortest_paths(g, 1) setup=(g = graph_with_weights(SimpleWeightedGraph{Int}, :facebook_combined))
suite["dijkstra_shortest_paths"]["facebook"]["MetaGraph{Int}"] =
    @benchmarkable dijkstra_shortest_paths(g, 1) setup=(g = graph_with_weights(MetaGraph{Int}, :facebook_combined))
suite["dijkstra_shortest_paths"]["facebook"]["ValGraph{Int}"] =
    @benchmarkable dijkstra_shortest_paths(g, 1) setup=(g = graph_with_weights(ValGraph{Int}, :facebook_combined))


suite["Experimental.dijkstra_shortest_paths"] = BenchmarkGroup()
suite["Experimental.dijkstra_shortest_paths"]["facebook"] = BenchmarkGroup()

suite["Experimental.dijkstra_shortest_paths"]["facebook"]["SimpleGraph{Int} + Matrix"] =
    @benchmarkable SimpleValueGraphs.Experimental.dijkstra_shortest_paths(g, 1, m) setup=((g, m) = graph_with_weights(SimpleGraph{Int}, Matrix, :facebook_combined))
suite["Experimental.dijkstra_shortest_paths"]["facebook"]["SimpleGraph{Int} + SparseMatrixCSC"] =
    @benchmarkable SimpleValueGraphs.Experimental.dijkstra_shortest_paths(g, 1, m) setup=((g, m) = graph_with_weights(SimpleGraph{Int}, SparseMatrixCSC, :facebook_combined))
suite["Experimental.dijkstra_shortest_paths"]["facebook"]["SimpleWeightedGraph{Int}"] =
    @benchmarkable SimpleValueGraphs.Experimental.dijkstra_shortest_paths(g, 1) setup=(g = graph_with_weights(SimpleWeightedGraph{Int}, :facebook_combined))
suite["Experimental.dijkstra_shortest_paths"]["facebook"]["MetaGraph{Int}"] =
    @benchmarkable SimpleValueGraphs.Experimental.dijkstra_shortest_paths(g, 1) setup=(g = graph_with_weights(MetaGraph{Int}, :facebook_combined))
suite["Experimental.dijkstra_shortest_paths"]["facebook"]["ValGraph{Int}"] =
    @benchmarkable SimpleValueGraphs.Experimental.dijkstra_shortest_paths(g, 1) setup=(g = graph_with_weights(ValGraph{Int}, :facebook_combined))


if !isinteractive()
    tune!(suite, verbose = true)
    results = run(suite, verbose = true)
    println(results)
end



