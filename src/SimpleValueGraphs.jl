module SimpleValueGraphs

using LightGraphs: AbstractGraph, AbstractEdgeIter, AbstractEdge

using LightGraphs.SimpleGraphs: AbstractSimpleGraph, AbstractSimpleEdge,
    SimpleGraph, SimpleDiGraph, SimpleEdge, IsDirected

using Base: OneTo


import LightGraphs
const LG = LightGraphs

import LightGraphs:
    nv, ne, is_directed,
    eltype, vertices, add_vertex!, has_vertex,
    edgetype, edges, src, dst, reverse,
    weights,
    add_edge!, rem_edge!, has_edge,
    inneighbors, outneighbors,
    zero,
    adjacency_matrix

import Base: show, iterate, length,
    getindex, size, ==

import LinearAlgebra
import LinearAlgebra:
    ishermitian, issymmetric,
    adjoint, transpose


export
    ValGraph,
    ValOutDiGraph,
    ValDiGraph,

    AbstractValEdge,
    ValEdge,
    ValDiEdge,

    vertexvals_type,
    edgevals_type,

    hasvertexkey,
    hasedgekey,

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
    has_vertex,

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
    ==,

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

include("integrations/SimpleGraphs.jl")


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
        vertexval_initializer=v -> cities[v],
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
