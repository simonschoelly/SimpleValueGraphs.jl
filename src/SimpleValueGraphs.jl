module SimpleValueGraphs

using LightGraphs
using LightGraphs.SimpleGraphs: AbstractSimpleGraph, AbstractSimpleEdge, SimpleEdge

import Base: eltype, show, reverse, iterate, length, replace_in_print_matrix, getindex, size, zero, Tuple
import SparseArrays: blockdiag
import LightGraphs:
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    add_vertex!, add_edge!, rem_vertex!, rem_edge!,
    has_vertex, has_edge, inneighbors, outneighbors,
    indegree, outdegree, degree, has_self_loops, num_self_loops,
    add_vertex!, adjacency_matrix, weights, edgetype,
    SimpleGraph, SimpleDiGraph, IsDirected,

    # operators
    complement
     

export AbstractSimpleValueGraph, SimpleValueGraph, SimpleValueDiGraph, SimpleValueEdge,
    outedgevals, inedgevals, edgevals, all_edgevals, get_value, map_edge_vals! #, kruskal_mst_modified

# ===== AbstractSimpleValueGraph ==========

abstract type AbstractSimpleValueGraph{T<:Integer, U} <: AbstractGraph{T} end

const default_value_type = Float64
#default_value(g::AbstractSimpleValueGraph{T, U}) where {T, U} = default_value(U)
#default_value(::Type{<:AbstractSimpleValueGraph{T, U}}) where {T, U} = oneunit(U)
value_type(g::AbstractSimpleValueGraph{T, U}) where {T, U} = U
default_value(U) = oneunit(U)
default_value(::Type{Nothing}) = nothing


eltype(::AbstractSimpleValueGraph{T, U}) where {T, U} = T
edgetype(::AbstractSimpleValueGraph{T, U}) where {T, U} = SimpleValueEdge{T, U}

edges(g::AbstractSimpleValueGraph) = SimpleValueEdgeIter(g)

nv(g::AbstractSimpleValueGraph) = length(g.fadjlist)
ne(g::AbstractSimpleValueGraph) = g.ne

zero(G::AbstractSimpleValueGraph{T}) where {T} = G(zero(T))

vertices(g::AbstractSimpleValueGraph) = Base.OneTo(nv(g))
has_vertex(g::AbstractSimpleValueGraph, v) = v ∈ vertices(g)

struct SimpleValueEdgeIter{G<:AbstractSimpleValueGraph} <: AbstractEdgeIter
    g::G
end

length(iter::SimpleValueEdgeIter) = ne(iter.g)
eltype(::Type{SimpleValueEdgeIter{<:AbstractSimpleValueGraph{T, U}}}) where {T, U} =
        SimpleValueEdge{T, U}

function show(io::IO, g::AbstractSimpleValueGraph)
    dir = is_directed(g) ? "directed" : "undirected"
    println(io, "{$(nv(g)), $(ne(g))} $dir $(eltype(g)) SimpleValueGraph with values of type $(eltype(g))")
end

# ==== Includes ===========================


include("simplevalueedge.jl")
include("simplevaluegraph.jl")
include("simplevaluedigraph.jl")
include("matrices.jl")

include("operators.jl")
# include("modified_functions.jl")

include("export.jl")


end # module
