module SimpleValueGraphs

using Graphs: AbstractGraph, AbstractEdgeIter, AbstractEdge, num_self_loops

using Graphs.SimpleGraphs: AbstractSimpleGraph, AbstractSimpleEdge,
    SimpleGraph, SimpleDiGraph, SimpleEdge, IsDirected

using Base: OneTo


import Graphs

import Graphs:
    nv, ne, is_directed,
    eltype, vertices, add_vertex!, rem_vertex!, has_vertex,
    edgetype, edges, src, dst, reverse,
    weights,
    add_edge!, rem_edge!, has_edge,
    inneighbors, outneighbors,
    zero,
    adjacency_matrix,
    squash, reverse

import Base: show, iterate, length,
    getindex, size, ==, hash

import LinearAlgebra
import LinearAlgebra:
    ishermitian, issymmetric,
    adjoint, transpose

import SparseArrays:
    SparseMatrixCSC


export
    ValGraph,
    ValOutDiGraph,
    ValDiGraph,

    AbstractValEdge,
    ValEdge,
    ValDiEdge,

    vertexvals_type,
    edgevals_type,
    graphvals_type,

    hasvertexkey,
    hasedgekey,
    hasgraphkey,

    get_vertexval,
    set_vertexval!,

    get_edgeval,
    get_edgeval_or,
    set_edgeval!,

    get_graphval,
    set_graphval!,

    inedgevals,
    outedgevals,

    AdjacencyMatrix,
    ValMatrix,

    # overridden methods from Graphs.jl
    nv,
    ne,
    is_directed,

    eltype,
    vertices,

    edgetype,
    edges,
    src,
    dst,
    reverse,

    weights,

    add_edge!,
    rem_edge!,
    has_edge,

    add_vertex!,
    rem_vertex!,
    has_vertex,

    inneighbors,
    outneighbors,

    adjacency_matrix,

    squash, reverse,

    zero,

    # overridden methods from Base
    iterate,
    length,
    size,
    getindex,
    show,
    ==,
    hash,

    # overridden methods from LinearAlgebra
    ishermitian,
    adjoint,
    transpose,
    issymmetric,

    # overriden methods from SparseArrays
    SparseMatrixCSC

# ==== Includes ===========================

include("AbstractTuples.jl")
include("utils.jl")

include("abstractvaluegraph.jl")
include("graphwrappers.jl")
include("valueedge.jl")
include("valuegraph.jl")
include("matrices.jl")
include("operators.jl")

include("integrations/SimpleGraphs.jl")

include("Experimental.jl")


# ==== Various ===========================

"""
    swissmetro_graph()

A small example graph for using in documentation.

Swissmetro was a planned (but never realised) Hyperloop style project in Switzerland.
All data was taken from Wikipedia: https://en.wikipedia.org/wiki/Swissmetro
"""
function swissmetro_graph()

    cities = [
        (name = "Basel", population = 117_595),
        (name = "Bern", population = 133_791),
        (name = "Genève", population = 201_818),
        (name = "Lausanne", population = 139_111),
        (name = "St. Gallen", population = 75_833),
        (name = "Zürich", population = 415_215),
    ]

    g = ValGraph{Int8}(
        6;
        vertexval_types=(name = String, population = Int32),
        vertexval_init=v -> cities[v],
        edgeval_types=(distance=Float64,)
    )

    add_edge!(g, 1, 6, (distance=89.0,))
    add_edge!(g, 2, 4, (distance=81.0,))
    add_edge!(g, 2, 6, (distance=104.0,))
    add_edge!(g, 3, 4, (distance=68.0,))
    add_edge!(g, 5, 6, (distance=69.0,))

    return g
end

end # module
