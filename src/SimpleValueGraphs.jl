module SimpleValueGraphs

using LightGraphs
using LightGraphs.SimpleGraphs: AbstractSimpleGraph, AbstractSimpleEdge,
    SimpleEdge, IsDirected

using SimpleTraits

using Base: OneTo

import Base: eltype, show, reverse, iterate, length, replace_in_print_matrix,
    getindex, size, zero, Tuple

import SparseArrays: blockdiag

import LightGraphs
const LG = LightGraphs

import LightGraphs:
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    add_vertex!, add_edge!, rem_vertex!, rem_edge!,
    has_vertex, has_edge, inneighbors, outneighbors,
    indegree, outdegree, degree, has_self_loops, num_self_loops,
    add_vertex!, adjacency_matrix, weights,
    SimpleGraph, SimpleDiGraph, IsDirected,

    # operators
    complement
     

export AbstractValGraph,
    AbstractEdgeValGraph,
    EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph,
    AbstractValEdge, ValEdge, ValDiEdge,
    get_edgeval, get_edgeval_or, get_edgevals, get_edgevals_or,
    set_edgeval!, set_edgevals!,
    val, vals,
    outedgevals, inedgevals,
    outedgevals_for_key, inedgevals_for_key,
    default_edgeval, edgevals_type,
    transform_edgevals!,
    KeyView, keyview,
    ValMatrix, AdjacencyMatrix,

    # overridden methods from other packages
    eltype,
    vertices,
    has_vertex,
    edgetype,
    edges,
    nv,
    ne,
    src,
    dst,
    add_edge!,
    rem_edge!,
    has_edge,
    outneighbors,
    inneighbors,
    iterate,
    reverse,
    is_diected,
    weights,
    zero,
    length,
    show,
    getindex,
    size,
    ishermitian,
    adjoint,
    transpose,
    issymmetric

# ==== Includes ===========================

include("AbstractTuples.jl")
include("utils.jl")

include("abstractvaluegraph.jl")
include("valueedge.jl")
include("valuegraph.jl")
#include("keyview.jl")
include("matrices.jl")

#include("operators.jl")
#include("modified_functions.jl")

#include("export.jl") # Temporary disabled


end # module
