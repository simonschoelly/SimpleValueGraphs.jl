# =============
# weight matrix
# =====================

struct SimpleValueMatrix{T, U, G <: AbstractSimpleValueGraph{T, U}} <: AbstractMatrix{U}
    g::G
end

weights(g::AbstractSimpleValueGraph) = SimpleValueMatrix(g)

function getindex(A::SimpleValueMatrix{T}, s::T, d::T) where {T <: Integer}
    return get_value(A.g, s, d)
end

function size(A::SimpleValueMatrix) 
    n = Int(nv(A.g))
    return (n, n)
end

function replace_in_print_matrix(A::SimpleValueMatrix{T}, s::T, d::T, str::AbstractString) where {T<:Integer}
    has_edge(A.g, s, d) ? str : Base.replace_with_centered_mark(str)
end
