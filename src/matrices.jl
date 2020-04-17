
using SparseArrays: AbstractSparseMatrix

#  ======================================================
#  AdjacencyMatrix
#  ======================================================

struct AdjacencyMatrix{G <: AbstractGraph} <: AbstractSparseMatrix{Bool, Int}
    graph::G
end

Base.getindex(matrix::AdjacencyMatrix, s, d) = has_edge(matrix.graph, s, d)

function Base.size(matrix::AdjacencyMatrix)
    nvg = Int(nv(matrix.graph))
    return (nvg, nvg)
end

LinearAlgebra.ishermitian(::AdjacencyMatrix{<:EdgeValGraph}) = true
LinearAlgebra.issymmetric(::AdjacencyMatrix{<:EdgeValGraph}) = true

LinearAlgebra.adjoint(matrix::AdjacencyMatrix{<:EdgeValGraph}) = matrix
LinearAlgebra.transpose(matrix::AdjacencyMatrix{<:EdgeValGraph}) = matrix

#  ======================================================
#  ValMatrix
#  ======================================================

struct ValMatrix{Tv, G <: AbstractGraph, key} <: AbstractSparseMatrix{Tv, Int} # TODO maybe not int

    graph::G
    zero_value::Tv
end

# TODO constructor


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

LG.weights(g::ZeroEdgeValGraph) = LG.DefaultDistance(nv(g))

LG.weights(g::OneEdgeValGraph) = weights(g, 1)

# TODO allow zero value keyword argument

function LG.weights(g::AbstractEdgeValGraph, key; zerovalue=zero(E_VAL_for_key(g, key)))

    return ValMatrix(g, key, zerovalue)

end

