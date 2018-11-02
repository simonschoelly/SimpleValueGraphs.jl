using LightGraphs
using SimpleValueGraphs
using SimpleWeightedGraphs
using MetaGraphs
using LightGraphsFlows
#using PkgBenchmark
using BenchmarkTools
using SparseArrays

function add_edges(g::AbstractGraph,
                          srcs, dsts, weights=nothing)
    m = length(srcs)
    @assert length(dsts) == m
    @assert weights == nothing || length(weights) == m 
    @inbounds for i in 1:m
        if weights != nothing
            add_edge!(g, srcs[i], dsts[i], weights[i])
        else
            add_edge!(g, srcs[i], dsts[i])
        end
    end
    return g
end

function add_edges(g::MetaGraph,
                          srcs, dsts, weights=nothing)
    m = length(srcs)
    @assert length(dsts) == m
    @assert weights == nothing || length(weights) == m 
    @inbounds for i in 1:m
        if weights != nothing
            add_edge!(g, srcs[i], dsts[i], weightfield(g), weights[i])
        else
            add_edge!(g, srcs[i], dsts[i])
        end
    end
    return g
end



SUITE = BenchmarkGroup()
SUITE["adding edges"] = BenchmarkGroup()

let
    bg = BenchmarkGroup()
    SUITE["adding edges"]["complete graph"] = bg

    n = 100
    m = n * (n - 1) ÷ 2
    srcs = Vector{Int}(undef, m)
    dsts = Vector{Int}(undef, m)
    k = 1
    for i = 1:n, j = (i+1):n
        srcs[k] = i
        dsts[k] = j
    end
    weightsFloat64 = rand(Float64, m)

    bg["SimpleGraph"] =
        @benchmarkable add_edges(SimpleGraph{Int64}($n), $srcs, $dsts)
        
    bg["SimpleValueGraph default weights Float64"] = 
        @benchmarkable add_edges(SimpleValueGraph{Int64, Float64}($n), $srcs, $dsts)
        
    bg["SimpleValueGraph with weights Float64"] = 
        @benchmarkable add_edges(SimpleValueGraph{Int64, Float64}($n), 
                                        $srcs, $dsts, $weightsFloat64)
    
    bg["SimpleValueGraph with weights Nothing"] = 
        @benchmarkable add_edges(SimpleValueGraph{Int64, Nothing}($n), 
                                        $srcs, $dsts) 

    bg["SimpleWeightedGraph default weights Float64"] = 
        @benchmarkable add_edges(SimpleWeightedGraph{Int64, Float64}($n),
                                        $srcs, $dsts)

    bg["SimpleWeightedGraph with weights Float64"] = 
        @benchmarkable add_edges(SimpleWeightedGraph{Int64, Float64}($n),
                                        $srcs, $dsts, $weightsFloat64) 

     bg["MetaGraph no weights Float64"] = 
        @benchmarkable add_edges(MetaGraph{Int64, Float64}($n),
                                        $srcs, $dsts)
    bg["MetaGraph with weights Float64"] = 
        @benchmarkable add_edges(MetaGraph{Int64, Float64}($n),
                                        $srcs, $dsts, $weightsFloat64) 
    nothing

end

let
    bg = BenchmarkGroup()
    SUITE["adding edges"]["random"] = bg

    n = 100
    m = n * (n - 1) ÷ 2
    srcs = rand(1:n, m)
    dsts = rand(1:n, m)
    weightsFloat64 = rand(Float64, m)
    weightsInt8 = rand(Int8, m)

    bg["SimpleGraph"] =
        @benchmarkable add_edges(SimpleGraph{Int64}($n), $srcs, $dsts)
        
    bg["SimpleValueGraph default weights Float64"] = 
        @benchmarkable add_edges(SimpleValueGraph{Int64, Float64}($n), $srcs, $dsts)
        
    bg["SimpleValueGraph with weights Float64"] = 
        @benchmarkable add_edges(SimpleValueGraph{Int64, Float64}($n), 
                                        $srcs, $dsts, $weightsFloat64)
    
    bg["SimpleValueGraph with weights Nothing"] = 
        @benchmarkable add_edges(SimpleValueGraph{Int64, Nothing}($n), 
                                        $srcs, $dsts) 
      
    #=
    bg["SimpleValueGraph without weights Int8"] = 
   @benchmarkable add_edges(SimpleValueGraph{Int64, Int8}(n), srcs, dsts)
    bg["SimpleValueGraph with weights Int8"] = 
    @benchmarkable add_edges(SimpleValueGraph{Int64, Int8}(n), srcs, dsts, weightsInt8)
    =#

    
    bg["SimpleWeightedGraph default weights Float64"] = 
        @benchmarkable add_edges(SimpleWeightedGraph{Int64, Float64}($n),
                                        $srcs, $dsts)
    bg["SimpleWeightedGraph with weights Float64"] = 
        @benchmarkable add_edges(SimpleWeightedGraph{Int64, Float64}($n),
                                        $srcs, $dsts, $weightsFloat64) 

     bg["MetaGraph no weights Float64"] = 
        @benchmarkable add_edges(MetaGraph{Int64, Float64}($n),
                                        $srcs, $dsts)
    bg["MetaGraph with weights Float64"] = 
        @benchmarkable add_edges(MetaGraph{Int64, Float64}($n),
                                        $srcs, $dsts, $weightsFloat64) 
    nothing
end

#= only works for digraphs
SUITE["maxflow"] = BenchmarkGroup()

let
    bg = BenchmarkGroup()
    SUITE["maxflow"]["grid"] = bg

    g = Grid([10, 10, 10])
    g_valuegraph = SimpleValueGraph(g)
    
    source = 1
    target = nv(g)

    bg["SimpleGraph"] = @benchmarkable maximum_flow($g, $source, $target)
        
    bg["SimpleValueGraph default weights Float64"] = 
        @benchmarkable maximum_flow($g_valuegraph, $source, $target)

    nothing
end
=#

SUITE["spanning tree"] = BenchmarkGroup()
let
    bg = BenchmarkGroup()
    SUITE["spanning tree"]["grid"] = bg

    g = Grid([10, 10, 10, 10])
    g_valuegraph = SimpleValueGraph(g)
    map_edge_vals!((u, v, w) -> rand(), g_valuegraph)
    dense_weights = Matrix(weights(g_valuegraph))
    sparse_weights = SparseMatrixCSC(weights(g_valuegraph))

    g_simple_weighted = SimpleWeightedGraph(sparse_weights)

    g_meta = MetaGraph(g)
    for e in edges(g_valuegraph)
        set_prop!(g_meta, e.src, e.dst, weightfield(g_meta), e.value)
    end

    bg["SimpleGraph without weights"] =
        @benchmarkable kruskal_mst($g)

    bg["SimpleGraph with dense matrix weights"] =
        @benchmarkable kruskal_mst($g, $dense_weights)

    bg["SimpleGraph with sparse matrix weights"] =
        @benchmarkable kruskal_mst($g, $sparse_weights)
  
    bg["SimpleValueGraph with weights Float64"] = 
        @benchmarkable kruskal_mst($g_valuegraph)

 #   bg["SimpleValueGraph with weights Float64, modified kruskal"] = 
 #       @benchmarkable kruskal_mst_modified($g_valuegraph)

    bg["SimpleWeightedGraph with weights Float64"] = 
        @benchmarkable kruskal_mst($g_simple_weighted)

    bg["MetaGraph with weights Float64"] = 
        @benchmarkable kruskal_mst($g_meta)

    nothing
end


let
    bg = BenchmarkGroup()
    SUITE["spanning tree"]["random regular"] = bg

    g = random_regular_graph(1000, 100)
    g_valuegraph = SimpleValueGraph(g)
    map_edge_vals!((u, v, w) -> rand(), g_valuegraph)
    dense_weights = Matrix(weights(g_valuegraph))
    sparse_weights = SparseMatrixCSC(weights(g_valuegraph))

    g_simple_weighted = SimpleWeightedGraph(sparse_weights)

    g_meta = MetaGraph(g)
    for e in edges(g_valuegraph)
        set_prop!(g_meta, e.src, e.dst, weightfield(g_meta), e.value)
    end

    bg["SimpleGraph without weights"] =
        @benchmarkable kruskal_mst($g)

    bg["SimpleGraph with dense matrix weights"] =
        @benchmarkable kruskal_mst($g, $dense_weights)

    bg["SimpleGraph with sparse matrix weights"] =
        @benchmarkable kruskal_mst($g, $sparse_weights)
  
    bg["SimpleValueGraph with weights Float64"] = 
        @benchmarkable kruskal_mst($g_valuegraph)

 #   bg["SimpleValueGraph with weights Float64, modified kruskal"] = 
 #       @benchmarkable kruskal_mst_modified($g_valuegraph)

    bg["SimpleWeightedGraph with weights Float64"] = 
        @benchmarkable kruskal_mst($g_simple_weighted)

    bg["MetaGraph with weights Float64"] = 
        @benchmarkable kruskal_mst($g_meta)

    nothing
end
   
