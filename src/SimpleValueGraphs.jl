module SimpleValueGraphs

using LightGraphs
using LightGraphs.SimpleGraphs: AbstractSimpleGraph, AbstractSimpleEdge, SimpleEdge

using Base: OneTo

import Base: eltype, show, reverse, iterate, length, replace_in_print_matrix, getindex, size, zero, Tuple
import SparseArrays: blockdiag
import LightGraphs:
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    add_vertex!, add_edge!, rem_vertex!, rem_edge!,
    has_vertex, has_edge, inneighbors, outneighbors,
    indegree, outdegree, degree, has_self_loops, num_self_loops,
    add_vertex!, adjacency_matrix, weights,
    SimpleGraph, SimpleDiGraph, IsDirected,

    # operators
    complement
     

export AbstractSimpleValueGraph, SimpleValueGraph, SimpleValueDiGraph, SimpleValueEdge,
    get_edgeval, set_edgeval!,
    val,
    outedgevals, inedgevals, all_edgevals,
    default_edgeval, edgeval_type,
    map_edgevals! #, kruskal_mst_modified

# ===== AbstractSimpleValueGraph ==========

abstract type AbstractSimpleValueGraph{V<:Integer, E_VAL} <: AbstractGraph{V} end


const TupleOrNamedTuple = Union{Tuple, NamedTuple} # TODO maybe somewhere else?

const default_edgeval_type = Float64
default_edgeval(E_VAL) = oneunit(E_VAL)
default_edgeval(::Type{Nothing}) = nothing
default_edgeval(T::Type{<:TupleOrNamedTuple}) = T( default_edgeval(U) for U in T.types )

default_zero_edgeval(::Type{Nothing}) = nothing
default_zero_edgeval(E_VAL) = zero(E_VAL)
default_zero_edgeval(E_VAL::Type{<:TupleOrNamedTuple}) = E_VAL( default_zero_edgeval(T) for T in E_VAL.types )


eltype(::AbstractSimpleValueGraph{V}) where {V} = V
edgetype(::AbstractSimpleValueGraph{V, E_VAL}) where {V, E_VAL} = SimpleValueEdge{V, E_VAL}
edgeval_type(g::AbstractSimpleValueGraph{V, E_VAL}) where {V, E_VAL} = E_VAL
edgeval_type(::Type{<:AbstractSimpleValueGraph{V, E_VAL}}) where {V, E_VAL} = E_VAL

edges(g::AbstractSimpleValueGraph) = SimpleValueEdgeIter(g)

nv(g::AbstractSimpleValueGraph) = eltype(g)(length(g.fadjlist))
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
    println(io, "{$(nv(g)), $(ne(g))} $dir $(eltype(g)) SimpleValueGraph with edge values of type $(edgeval_type(g))")
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
