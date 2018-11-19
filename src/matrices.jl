# =============
# weight matrix
# =====================

struct SimpleValueMatrix{V, E_VAL, G <: AbstractSimpleValueGraph{V, E_VAL}} <: AbstractMatrix{E_VAL}
    g::G
end

weights(g::AbstractSimpleValueGraph) = SimpleValueMatrix(g)

function getindex(A::SimpleValueMatrix{V}, s::V, d::V) where {V <: Integer}
    return get_value(A.g, s, d)
end

function size(A::SimpleValueMatrix) 
    n = Int(nv(A.g))
    return (n, n)
end

function replace_in_print_matrix(A::SimpleValueMatrix{V}, s::V, d::V, str::AbstractString) where {V<:Integer}
    has_edge(A.g, s, d) ? str : Base.replace_with_centered_mark(str)
end
