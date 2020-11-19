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
    ValGraph,
    ValOutDiGraph,
    ValDiGraph,

    AbstractValEdge,
    ValEdge,
    ValDiEdge,

    default_edgeval,

    vertexvals_type,
    edgevals_type,

    get_vertexval,
    set_vertexval!,

    get_edgeval,
    get_edgeval_or,
    set_edgeval!,

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

    adjacency_matrix,

    # overridden methods from Base
    iterate,
    length,
    size,
    getindex,
    show,
    zero,

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

#   TODO temporarily disabled until initializors are fixed
#   include("integrations/SimpleGraphs.jl")

end # module
