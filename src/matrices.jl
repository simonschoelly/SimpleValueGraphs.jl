
using SparseArrays: AbstractSparseMatrix

#  ======================================================
#  AdjacencyMatrix
#  ======================================================

"""
    AdjacencyMatrix(g::AbstractGraph)

A matrix view of a graph.

Entry `(i, j)` is `true` if `i -> j` is and edge of `g` and `false` otherwise.
"""
struct AdjacencyMatrix{G <: AbstractGraph} <: AbstractSparseMatrix{Bool, Int}
    graph::G
end

Base.getindex(matrix::AdjacencyMatrix, s, d) = has_edge(matrix.graph, s, d)

function Base.size(matrix::AdjacencyMatrix)
    nvg = Int(nv(matrix.graph))
    return (nvg, nvg)
end

"""
    adjacency_matrix(g::AbstractEdgeValGraph)

Create an `AdjacencyMatrix` from a graph `g`.
"""
LG.adjacency_matrix(g::AbstractEdgeValGraph) = AdjacencyMatrix(g)

LinearAlgebra.ishermitian(::AdjacencyMatrix{<:EdgeValGraph}) = true
LinearAlgebra.issymmetric(::AdjacencyMatrix{<:EdgeValGraph}) = true

LinearAlgebra.adjoint(matrix::AdjacencyMatrix{<:EdgeValGraph}) = matrix
LinearAlgebra.transpose(matrix::AdjacencyMatrix{<:EdgeValGraph}) = matrix

#  ======================================================
#  ValMatrix
#  ======================================================

"""
    ValMatrix

A matrix view of the edge values for a specific key of a graph.
"""
struct ValMatrix{Tv, G <: AbstractGraph, key} <: AbstractSparseMatrix{Tv, Int} # TODO maybe not int

    graph::G
    zero_value::Tv
end

function ValMatrix(g::AbstractEdgeValGraph{V, E_VALS}, key::Union{Integer, Symbol}, zero_value) where {V, E_VALS}

    T = E_VAL_for_key(E_VALS, key)
    Z = typeof(zero_value)
    Tv = Union{T, Z}

    return ValMatrix{Tv, typeof(g), key}(g, zero_value)
end

function Base.size(matrix::ValMatrix)
    nvg = Int(nv(matrix.graph))
    return (nvg, nvg)
end

function Base.getindex(matrix::ValMatrix{Tv, G, key}, s, d) where {Tv, G, key}
    return get_edgevals_or(matrix.graph, s, d, key, matrix.zero_value)
end


LinearAlgebra.ishermitian(::ValMatrix{ <: Real, <:EdgeValGraph}) = true
LinearAlgebra.issymmetric(::ValMatrix{ <: Any, <:EdgeValGraph}) = true

LinearAlgebra.adjoint(matrix::ValMatrix{ <: Real, <:EdgeValGraph}) = matrix
LinearAlgebra.transpose(matrix::ValMatrix{ <: Any, <:EdgeValGraph}) = matrix

### weights

"""
    weights(g::AbstractEdgeValGraph[, key]; zerovalue)


Return a matrix where entry (i,j) is the value of the edge `i -- j` for the specific `key` in `g`.

If `g` has no edge values, `key` should be omitted and `DefaultDistance(g)` is returned.
Otherwise the result is a `ValMatrix`.
If `g` has a single value per edge, `key` can be omitted.
If the optional argument `zerovalue` is specified, then this value will be used
if entry (i, j) is not an edge in `g`. `zerovalue` cannot be used for graphs
without any edge values.
"""
function weights end

LG.weights(g::ZeroEdgeValGraph) = LG.DefaultDistance(nv(g))

LG.weights(g::OneEdgeValGraph) = weights(g, 1)

function LG.weights(g::AbstractEdgeValGraph, key; zerovalue=zero(E_VAL_for_key(g, key)))

    return ValMatrix(g, key, zerovalue)

end

