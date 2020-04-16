
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

struct ValMatrix{G <: AbstractGraph, Tv, K} <: AbstractSparseMatrix{Tv, Int} # TODO maybe not int

    graph::G
    zero_value::Tv
    key::K
end

# TODO constructor

ValMatrix(g::OneEdgeValGraph) = ValMatrix(g, 1)

function ValMatrix(g::AbstractEdgeValGraph{V, E_VALS}, key)

end

function ValMatrix(g::AbstractEdgeValGraph{V, E_VALS}, key;
        zero_value= zero(E_VAL_for_key(E_VALS, key))) where {V, E_VALS}
    
    T = E_VAL_for_key(E_VALS, key)
    Z = typeof(zero_value)
    Tv = Union{T, Z}

    return ValMatrix{key, Tv, typeof(g)}(g, zero_value)
end

function ValMatrix(g::OneEdgeValGraph{V, E_VAL};
        zero_value= zero(E_VAL)) where {V, E_VAL}

    key = edgeval_keys(g)[1] # TODO implement keys

    return ValMatrix(g, key; zero_value=zero_value)
end

function Base.size(matrix::ValMatrix)
    nvg = Int(nv(matrix.graph))
    return (nvg, nvg)
end

function Base.getindex(matrix::ValMatrix{K, Tv}, s, d) where {K, Tv}
    return get_edgeval_or(matrix.graph, s, d, matrix.zero_value, key=K)
end


LinearAlgebra.issymmetric(::ValMatrix{<:EdgeValGraph}) = true

LinearAlgebra.transpose(matrix::ValMatrix{<:EdgeValGraph}) = matrix

### weights

function LG.weights(g::AbstractEdgeValGraph; key=nokey)

    if g isa ZeroEdgeValGraph && key == nokey
        return LightGraphs.DefaultDistance(nv(g))
    elseif g isa OneEdgeValGraph && key == nokey
        return ValMatrix(g)
    end

    return ValMatrix(g, key)
end


