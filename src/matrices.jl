# =============
# weight matrix
# =====================

using SparseArrays: AbstractSparseMatrix

import LinearAlgebra:ishermitian, issymmetric, transpose, adjoint


struct AdjacencyMatrix{G <: AbstractGraph} <: AbstractSparseMatrix{Bool, Int}
    graph::G
end

getindex(matrix::AdjacencyMatrix, s, d) = has_edge(matrix.graph, s, d) 

function size(matrix::AdjacencyMatrix)
    nvg = Int(nv(matrix.graph))
    return (nvg, nvg)
end

ishermitian(::AdjacencyMatrix{<:ValueGraph}) = true

adjoint(matrix::AdjacencyMatrix{<:ValueGraph}) = matrix
transpose(matrix::AdjacencyMatrix{<:ValueGraph}) = transpose

struct ValueMatrix{K, Tv, G <: AbstractValueGraph} <:
        AbstractSparseMatrix{Tv, Int} # TODO maybe not int

    graph::G
    zero_value::Tv
end

# TODO constructor

function ValueMatrix(g::AbstractValueGraph{V, E_VALS}, key;
        zero_value= zero(E_VAL_for_key(E_VALS, key))) where {V, E_VALS}
    
    T = E_VAL_for_key(E_VALS, key)
    Z = typeof(zero_value)
    Tv = Union{T, Z}

    return ValueMatrix{key, Tv, typeof(g)}(g, zero_value)
end

function ValueMatrix(g::OneValueGraph{V, E_VAL};
        zero_value= zero(E_VAL)) where {V, E_VAL}

    key = edgeval_keys(g)[1] # TODO implement keys

    return ValueMatrix(g, key; zero_value=zero_value)
end

function size(matrix::ValueMatrix)
    nvg = Int(nv(matrix.graph))
    return (nvg, nvg)
end

function getindex(matrix::ValueMatrix{K, Tv}, s, d) where {K, Tv}
    return get_edgeval_or(matrix.graph, s, d, matrix.zero_value, key=K)
end


issymmetric(::ValueMatrix{<:ValueGraph}) = true

transpose(matrix::ValueMatrix{<:ValueGraph}) = transpose

### weights

function weights(g::AbstractValueGraph; key=nokey)

    if g isa ZeroValueGraph && key == nokey
        return LightGraphs.DefaultDistance(nv(g))
    elseif g isa OneValueGraph && key == nokey
        return ValueMatrix(g)
    end

    return ValueMatrix(g, key)
end


