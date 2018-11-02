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

abstract type AbstractSimpleValueGraph{T<:Integer, U} <: AbstractGraph{T} end

const default_value_type = Float64
#default_value(g::AbstractSimpleValueGraph{T, U}) where {T, U} = default_value(U)
#default_value(::Type{<:AbstractSimpleValueGraph{T, U}}) where {T, U} = oneunit(U)
value_type(g::AbstractSimpleValueGraph{T, U}) where {T, U} = U
default_value(U) = oneunit(U)
default_value(::Type{Nothing}) = nothing

include("simplevalueedge.jl")
include("simplevaluegraph.jl")
include("simplevaluedigraph.jl")

include("operators.jl")
# include("modified_functions.jl")

end # module
