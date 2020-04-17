module SimpleValueGraphs

using LightGraphs: AbstractGraph, AbstractEdgeIter, AbstractEdge

using LightGraphs.SimpleGraphs: AbstractSimpleGraph, AbstractSimpleEdge,
    SimpleGraph, SimpleDiGraph, SimpleEdge, IsDirected

using Base: OneTo


import LightGraphs
const LG = LightGraphs

import LightGraphs:
    nv, ne, is_directed,
    eltype, vertices, has_vertex,
    edgetype, edges, src, dst, reverse,
    weights,
    add_edge!, rem_edge!, has_edge,
    inneighbors, outneighbors,
    zero,
    adjacency_matrix

import Base: show, iterate, length,
    getindex, size

import LinearAlgebra


export
    AbstractEdgeValGraph,
    EdgeValGraph,
    EdgeValOutDiGraph,
    EdgeValDiGraph,

    AbstractValEdge,
    ValEdge,
    ValDiEdge,

    val,
    vals,

    default_edgeval,

    edgevals_type,

    allkeys,

    get_edgevals,
    get_edgevals_or,
    set_edgevals!,

    inedgevals,
    outedgevals,

    AdjacencyMatrix,
    ValMatrix,

    # overridden methods from LightGraphs
    nv,
    ne,
    is_directed,

    eltype,
    vertices,
    has_vertex,

    edgetype,
    edges,
    src,
    dst,
    reverse,

    weights,

    add_edge!,
    rem_edge!,
    has_edge,

    inneighbors,
    outneighbors,

    zero,

    adjacency_matrix,

    # overridden methods from Base
    iterate,
    length,
    size,
    getindex,
    show,

    # overridden methods from LinearAlgebra
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
include("matrices.jl")

end # module
