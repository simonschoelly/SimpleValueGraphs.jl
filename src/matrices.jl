# =============
# weight matrix
# =====================

# TODO would probably be better if the matrix stores the adjacency list instead of the key
# TODO These methods are not typestable

struct SimpleValueMatrix{T, K <: Union{Nothing, Val}, G <: AbstractSimpleValueGraph} <: AbstractMatrix{T}
    g::G
end

function weights(g::AbstractSimpleValueGraph{V, E_VAL}) where {V, E_VAL}
    SimpleValueMatrix{E_VAL, Nothing, typeof(g)}(g)
end

function weights(g::AbstractSimpleValueGraph{V, E_VAL}, key) where {V, E_VAL <: TupleOrNamedTuple}
    T = eltype(eltype(g.edgevals[key]))
    SimpleValueMatrix{T, Val{key}, typeof(g)}(g)
end

function getindex(A::SimpleValueMatrix{T, Nothing}, s::Integer, d::Integer) where {T}
    result = get_edgeval(A.g, s, d)
    return ifelse(result == nothing, default_zero_edgeval(T), result)
end

function getindex(A::SimpleValueMatrix{T, Val{key}}, s::Integer, d::Integer) where {T, key}
    result = get_edgeval(A.g, s, d, key)
    return ifelse(result == nothing, default_zero_edgeval(T), result)
end

function size(A::SimpleValueMatrix) 
    n = Int(nv(A.g))
    return (n, n)
end

function replace_in_print_matrix(A::SimpleValueMatrix, s::Integer, d::Integer, str::AbstractString)
    has_edge(A.g, s, d) ? str : Base.replace_with_centered_mark(str)
end
