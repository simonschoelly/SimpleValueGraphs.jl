
using SparseArrays: AbstractSparseMatrix

#  ======================================================
#  AdjacencyMatrix
#  ======================================================

"""
    AdjacencyMatrix(g::AbstractGraph)

A matrix view of a graph.

Entry `(i, j)` is `true` if `i -> j` is and edge of `g` and `false` otherwise.

As this is as a view, the entries and the size of this matrix can change
when the underlying graph changes. The view itself is immutable. Convert
to a `Matrix` or `SparseMatrixCSC` to get a mutable matrix that does
not change when the graph does.

### See also
[`adjacency_matrix`](@ref), [`ValMatrix`](@ref), [`weigths`](@ref)

### Examples

```jldoctest
julia> g = complete_bipartite_graph(2, 2)
{4, 4} undirected simple Int64 graph

julia> AdjacencyMatrix(g)
4×4 AdjacencyMatrix{SimpleGraph{Int64}}:
 0  0  1  1
 0  0  1  1
 1  1  0  0
 1  1  0  0

julia> AdjacencyMatrix(g) |> Matrix
4×4 Matrix{Bool}:
 0  0  1  1
 0  0  1  1
 1  1  0  0
 1  1  0  0
```
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
    adjacency_matrix(g::AbstractValGraph)

Create an `AdjacencyMatrix` view from a graph `g`.

### See also
[`AdjacencyMatrix`](@ref), [`ValMatrix`](@ref), [`weights`](@ref)

### Examples

```jldoctest
julia> gv = ValGraph(star_graph(4), edgeval_types=(Float64,), edgeval_init=(s, d) -> (1.0, ))
{4, 3} undirected ValGraph with
              eltype: Int64
  vertex value types: ()
    edge value types: (Float64,)
   graph value types: ()

julia> adjacency_matrix(gv)
4×4 AdjacencyMatrix{ValGraph{Int64, Tuple{}, Tuple{Float64}, Tuple{}, Tuple{}, Tuple{Vector{Vector{Float64}}}}}:
 0  1  1  1
 1  0  0  0
 1  0  0  0
 1  0  0  0
```
"""
LG.adjacency_matrix(g::AbstractValGraph) = AdjacencyMatrix(g)

## ---------------------------------------------------------------
##       LinearAlgebra
## ---------------------------------------------------------------

LinearAlgebra.ishermitian(::AdjacencyMatrix{<:ValGraph}) = true
LinearAlgebra.issymmetric(::AdjacencyMatrix{<:ValGraph}) = true

LinearAlgebra.adjoint(matrix::AdjacencyMatrix{<:ValGraph}) = matrix
LinearAlgebra.transpose(matrix::AdjacencyMatrix{<:ValGraph}) = matrix

# TODO consider implementing matrix x matrix multiplication
# TODO consider implementing the 5-argument version of mul! instead
function LinearAlgebra.mul!(y::AbstractVector, matrix::AdjacencyMatrix, b::AbstractVector)

    Base.require_one_based_indexing(y, matrix, b)
    n = length(y)
    size(matrix, 1) == n || throw(DimensionMismatch())
    length(b) == n || throw(DimensionMismatch())
    g = matrix.graph

    for i in 1:n
        s = false * zero(eltype(b))
        @simd for j in outneighbors(g, i)
            @inbounds s += true * b[j]
        end
        @inbounds y[i] = s
    end
    return y
end

##  ------------------------------------------------------
##  AdjacencyMatrix ->SparseMatrixCSC
##  ------------------------------------------------------

function SparseMatrixCSC(matrix::AdjacencyMatrix{<: Union{ValGraph, ValDiGraph}})

    g = matrix.graph
    n = Int(nv(g))
    nnz = is_directed(g) ? ne(g) : (2 * ne(g) - num_self_loops(g))

    colptr = Vector{Int}(undef, n + 1)
    rowval = Vector{Int}(undef, nnz)
    nzval = fill(true, nnz)

    nnz_idx = 1
    @inbounds colptr[1] = 1
    for v in vertices(g)
        for u in inneighbors(g, v)
            @inbounds rowval[nnz_idx] = u
            nnz_idx += 1
        end
        @inbounds colptr[v + 1] = nnz_idx
    end

    return SparseMatrixCSC(n, n, colptr, rowval, nzval)
end

# TODO Create directly without transpose
function SparseMatrixCSC(matrix::AdjacencyMatrix{<: ValOutDiGraph})

    g = matrix.graph
    n = Int(nv(g))
    nnz = is_directed(g) ? ne(g) : (2 * ne(g) - num_self_loops(g))

    colptr = Vector{Int}(undef, n + 1)
    rowval = Vector{Int}(undef, nnz)
    nzval = fill(true, nnz)

    nnz_idx = 1
    @inbounds colptr[1] = 1
    for u in vertices(g)
        for v in outneighbors(g, u)
            @inbounds rowval[nnz_idx] = v
            nnz_idx += 1
        end
        @inbounds colptr[u + 1] = nnz_idx
    end

    return SparseMatrixCSC(transpose(SparseMatrixCSC(n, n, colptr, rowval, nzval)))
end

#  ======================================================
#  ValMatrix
#  ======================================================

"""
    ValMatrix{Tv, :< AbstractGraph, key}

A matrix view of the edge values for a specific key of a graph.

As this is as a view, the entries and the size of this matrix can change
when the underlying graph changes. The view itself is immutable. Convert
to a `Matrix` or `SparseMatrixCSC` to get a mutable matrix that does
not change when the graph does.
"""
struct ValMatrix{Tv, G <: AbstractValGraph, key} <: AbstractSparseMatrix{Tv, Int}

    graph::G
    zero_value::Tv
end

"""
    ValMatrix(g::AbstractGraph, key, zero_value)

Construct a new `ValMatrix` view for a graph `g` where the values are
the edge values specified by `key`. Entries that are not in the graph
are represented by `zero_value` in the matrix.

### See also
[`AdjacencyMatrix`](@ref), [`adjacency_matrix`](@ref), [`weights`](@ref)

### Examples
```jldoctest
julia> gv = ValDiGraph(path_digraph(3),  edgeval_types=(a=Float64, b=String), edgeval_init=(s, d) -> (rand(MersenneTwister(0)), "\$s-\$d"))
{3, 2} directed ValDiGraph with
              eltype: Int64
  vertex value types: ()
    edge value types: (a = Float64, b = String)
   graph value types: ()

julia> ValMatrix(gv, 1, 0.0)
3×3 ValMatrix{Float64, ValDiGraph{Int64, Tuple{}, NamedTuple{(:a, :b), Tuple{Float64, String}}, Tuple{}, Tuple{}, NamedTuple{(:a, :b), Tuple{Vector{Vector{Float64}}, Vector{Vector{String}}}}}, 1}:
 0.0  0.823648  0.0
 0.0  0.0       0.823648
 0.0  0.0       0.0

julia> ValMatrix(gv, :b, nothing)
3×3 ValMatrix{Union{Nothing, String}, ValDiGraph{Int64, Tuple{}, NamedTuple{(:a, :b), Tuple{Float64, String}}, Tuple{}, Tuple{}, NamedTuple{(:a, :b), Tuple{Vector{Vector{Float64}}, Vector{Vector{String}}}}}, :b}:
 nothing  "1-2"    nothing
 nothing  nothing  "2-3"
 nothing  nothing  nothing
```
"""
function ValMatrix(g::AbstractValGraph, key::Union{Integer, Symbol}, zero_value)

    T = edgevals_type(g, key)
    Z = typeof(zero_value)
    Tv = Union{T, Z}

    return ValMatrix{Tv, typeof(g), key}(g, zero_value)
end

function Base.size(matrix::ValMatrix)

    nvg = Int(nv(matrix.graph))
    return (nvg, nvg)
end

function Base.getindex(matrix::ValMatrix{Tv, G, key}, s, d) where {Tv, G, key}

    return get_edgeval_or(matrix.graph, s, d, key, matrix.zero_value)
end


LinearAlgebra.ishermitian(::ValMatrix{ <: Real, <: ValGraph}) = true
LinearAlgebra.issymmetric(::ValMatrix{ <: Any, <: ValGraph}) = true

LinearAlgebra.adjoint(matrix::ValMatrix{ <: Real, <: ValGraph}) = matrix
LinearAlgebra.transpose(matrix::ValMatrix{ <: Any, <: ValGraph}) = matrix


##  ------------------------------------------------------
##  SparseMatrixCSC
##  ------------------------------------------------------

function SparseMatrixCSC(matrix::ValMatrix{Tv, <: Union{ValGraph, ValDiGraph}, key}) where {Tv, key}

    g = matrix.graph
    n = Int(nv(g))
    nnz = is_directed(g) ? ne(g) : (2 * ne(g) - num_self_loops(g))

    colptr = Vector{Int}(undef, n + 1)
    rowval = Vector{Int}(undef, nnz)
    nzval = Vector{Tv}(undef, nnz)

    nnz_idx = 1
    @inbounds colptr[1] = 1
    for v in vertices(g)
        for (u, val) in zip(inneighbors(g, v), inedgevals(g, v, key))
            @inbounds rowval[nnz_idx] = u
            @inbounds nzval[nnz_idx] = val
            nnz_idx += 1
        end
        @inbounds colptr[v + 1] = nnz_idx
    end

    return SparseMatrixCSC(n, n, colptr, rowval, nzval)
end

# TODO instead of using transpose, a better way should be found that
# does not allocate a temporary SparseMatrixCSC
function SparseMatrixCSC(matrix::ValMatrix{Tv, <: ValOutDiGraph, key}) where {Tv, key}

    g = matrix.graph
    n = Int(nv(g))
    nnz = ne(g)

    colptr = Vector{Int}(undef, n + 1)
    rowval = Vector{Int}(undef, nnz)
    nzval = Vector{Tv}(undef, nnz)

    nnz_idx = 1
    @inbounds colptr[1] = 1
    for u in vertices(g)
        for (v, val) in zip(outneighbors(g, u), outedgevals(g, u, key))
            @inbounds rowval[nnz_idx] = v
            @inbounds nzval[nnz_idx] = val
            nnz_idx += 1
        end
        @inbounds colptr[u + 1] = nnz_idx
    end

    return SparseMatrixCSC(transpose(SparseMatrixCSC(n, n, colptr, rowval, nzval)))
end


##  ------------------------------------------------------
##  weights
##  ------------------------------------------------------

"""
    weights(g::AbstractValGraph[, key]; zerovalue)


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

LG.weights(g::OneEdgeValGraph; kwargs...) = LG.weights(g, 1; kwargs...)

function LG.weights(g::AbstractValGraph, key; zerovalue=zero(edgevals_type(g, key)))

    return ValMatrix(g, key, zerovalue)
end

