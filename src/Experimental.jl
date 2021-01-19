
"""
    Experimental

This module contains experimental stuff that does not respect SemVer
"""
module Experimental

using LightGraphs: AbstractGraph, weights, nv, vertices, outneighbors, DijkstraState, DefaultDistance
using DataStructures: PriorityQueue, dequeue!
using SimpleValueGraphs: ValGraph, edgevals_type, outedgevals
using SimpleWeightedGraphs: SimpleWeightedGraph, weighttype

struct InternalEdgeVals{key} end

internaledgevals_or_weights(g::AbstractGraph) = weights(g)

internaledgevals_or_weights(g::SimpleWeightedGraph) = InternalEdgeVals{nothing}()

internaledgevals_or_weights(g::ValGraph, key=1) = InternalEdgeVals{key}()

outneighbors_and_edgevals(g::AbstractGraph, weights, u) =
    ((v, @inbounds weights[u, v]) for v in outneighbors(g, u))

outneighbors_and_edgevals(g::ValGraph, ::InternalEdgeVals{key}, u) where key =
    zip(outneighbors(g, u), outedgevals(g, u, key))

function outneighbors_and_edgevals(g::SimpleWeightedGraph, ::InternalEdgeVals, u)

    w = g.weights
    zip(outneighbors(g, u), view(w.nzval, w.colptr[1]:w.colptr[u+1]-1))
end

function _edgevals_type(g::ValGraph, ::InternalEdgeVals{key}) where key

    return edgevals_type(g, key)
end

function _edgevals_type(g::SimpleWeightedGraph, ::InternalEdgeVals)

    return weighttype(g)
end

function dijkstra_shortest_paths(g::AbstractGraph, srcs::Vector{<:Integer}, distmx=internaledgevals_or_weights(g);
    allpaths=false,
    trackvertices=false)

    srcs ⊆ vertices(g) || error("srcs must be vertices of g")

    V = eltype(g)
    W = if distmx isa InternalEdgeVals
        _edgevals_type(g, distmx)
    else
        size(distmx, 1) >= nv(g) || error("distmx is too small")
        size(distmx, 2) >= nv(g) || error("distmx is too small")

        eltype(distmx)
    end

    nvg = Int(nv(g))
    dists = fill(typemax(W), nvg)
    parents = zeros(V, nvg)
    visited = falses(nvg)
    pathcounts = zeros(nvg)
    closest_vertices = sizehint!(Vector{V}(), nvg)
    preds = fill(Vector{V}(), nvg)

    q = PriorityQueue{V, W}()

    for src in srcs
        @inbounds dists[src] = zero(W)
        @inbounds visited[src] = true
        @inbounds pathcounts[src] = one(Float64)
        q[src] = zero(W)
    end


    while !isempty(q)
        u = dequeue!(q)

        if trackvertices
            push!(closest_vertices, u)
        end

        @inbounds d = dists[u]
        @inbounds for (v, w) in outneighbors_and_edgevals(g, distmx, u)
            alt = d + w

            if !visited[v]
                visited[v] = true
                dists[v] = alt
                parents[v] = u

                pathcounts[v] = pathcounts[u]
                if allpaths
                    preds[v] = u
                end
                q[v] = alt
            elseif alt < dists[v]
                dists[v] = alt
                parents[v] = u
                pathcounts[v] = pathcounts[u]
                if allpaths
                    resize!(preds[v], 1)
                    preds[v][1] = u
                end
                q[v] = alt
            elseif alt == dists[v]
                pathcounts[v] += pathcounts[u]
                if allpaths
                    push!(preds[v], u)
                end
            end
        end
    end

    for src in srcs
        @inbounds pathcounts[src] = one(Float64)
        @inbounds parents[src] = 0
        @inbounds empty!(preds[src])
    end

    return DijkstraState{W, V}(parents, dists, preds, pathcounts, closest_vertices)
end

dijkstra_shortest_paths(g::AbstractGraph, src::Integer, distmx=internaledgevals_or_weights(g); kwargs...) =
    dijkstra_shortest_paths(g, [src], distmx; kwargs...)

end # end module
