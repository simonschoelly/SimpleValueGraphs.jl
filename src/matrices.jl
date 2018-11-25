# =============
# weight matrix
# =====================

# TODO would probably be better if the matrix stores the adjacency list instead of the key
# TODO These methods are not typestable

struct SimpleValueMatrix{E_VAL, K, G <: AbstractSimpleValueGraph} <: AbstractMatrix{E_VAL}
    key::K
    g::G
end

function weights(g::AbstractSimpleValueGraph{V, E_VAL}) where {V, E_VAL}
    SimpleValueMatrix{E_VAL, Nothing, typeof(g)}(nothing, g)
end

function weights(g::AbstractSimpleValueGraph, key)
    E_VAL = eltype(eltype(g.edgevals[key]))
    SimpleValueMatrix{E_VAL, typeof(key), typeof(g)}(key, g)
end

function getindex(A::SimpleValueMatrix{E_VAL, Nothing}, s::Integer, d::Integer) where {E_VAL}
    return something(get_edgeval(A.g, s, d), default_zero_edgeval(E_VAL), Some(nothing))
end

function getindex(A::SimpleValueMatrix{E_VAL}, s::Integer, d::Integer) where {E_VAL}
    return something(get_edgeval(A.g, s, d, A.key), default_zero_edgeval(E_VAL)[A.key], Some(nothing))
end

function size(A::SimpleValueMatrix) 
    n = Int(nv(A.g))
    return (n, n)
end

function replace_in_print_matrix(A::SimpleValueMatrix, s::Integer, d::Integer, str::AbstractString)
    has_edge(A.g, s, d) ? str : Base.replace_with_centered_mark(str)
end
