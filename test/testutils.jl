# TODO this should contain helper functions for testing


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

