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
    outedgevals, inedgevals, edgevals, all_edgevals, get_value, set_value!, map_edge_vals! #, kruskal_mst_modified

# ===== AbstractSimpleValueGraph ==========

abstract type AbstractSimpleValueGraph{V<:Integer, E_VAL} <: AbstractGraph{V} end


const TupleOrNamedTuple = Union{Tuple, NamedTuple} # TODO maybe somewhere else?

const default_edge_val_type = Float64
edge_val_type(g::AbstractSimpleValueGraph{V, E_VAL}) where {V, E_VAL} = E_VAL
default_edge_val(E_VAL) = oneunit(E_VAL)
default_edge_val(::Type{Nothing}) = nothing
default_edge_val(T::Type{<:TupleOrNamedTuple}) = T( default_edge_val(U) for U in T.types )

default_zero_edge_val(E_VAL) = zero(E_VAL)
default_zero_edge_val(T::Type{<:TupleOrNamedTuple}) = T( default_zero_edge_val(U) for U in T.types )


eltype(::AbstractSimpleValueGraph{V}) where {V} = V
edgetype(::AbstractSimpleValueGraph{V, E_VAL}) where {V, E_VAL} = SimpleValueEdge{V, E_VAL}

edges(g::AbstractSimpleValueGraph) = SimpleValueEdgeIter(g)

nv(g::AbstractSimpleValueGraph) = length(g.fadjlist)
ne(g::AbstractSimpleValueGraph) = g.ne

zero(G::AbstractSimpleValueGraph{V}) where {V} = G(zero(V))

vertices(g::AbstractSimpleValueGraph) = Base.OneTo(nv(g))
has_vertex(g::AbstractSimpleValueGraph, v) = v ∈ vertices(g)

struct SimpleValueEdgeIter{G<:AbstractSimpleValueGraph} <: AbstractEdgeIter
    g::G
end

length(iter::SimpleValueEdgeIter) = ne(iter.g)
eltype(::Type{SimpleValueEdgeIter{<:AbstractSimpleValueGraph{V, E_VAL}}}) where {V, E_VAL} =
        SimpleValueEdge{V, E_VAL}

function show(io::IO, g::AbstractSimpleValueGraph)
    dir = is_directed(g) ? "directed" : "undirected"
    println(io, "{$(nv(g)), $(ne(g))} $dir $(eltype(g)) SimpleValueGraph with values of type $(eltype(g))")
end

# ==== Includes ===========================

include("utils.jl")
include("simplevalueedge.jl")
include("simplevaluegraph.jl")
include("simplevaluedigraph.jl")
include("matrices.jl")

include("operators.jl")
# include("modified_functions.jl")

include("export.jl")


end # module
