
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
4×4 Array{Bool,2}:
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
[`AdjacencyMatrix`](@ref), [`ValMatrix`](@ref), [`weigths`](@ref)

### Examples

```jldoctest
julia> gv = EdgeValGraph((s, d) -> (1.0, ), star_graph(4), (Float64, ))
{4, 3} undirected EdgeValGraph{Int64} graph with edge values of type (Float64,).


julia> adjacency_matrix(gv)
4×4 AdjacencyMatrix{EdgeValGraph{Int64,Tuple{Float64},Tuple{Array{Array{Float64,1},1}}}}:
 0  1  1  1
 1  0  0  0
 1  0  0  0
 1  0  0  0
```
"""
LG.adjacency_matrix(g::AbstractValGraph) = AdjacencyMatrix(g)

LinearAlgebra.ishermitian(::AdjacencyMatrix{<:EdgeValGraph}) = true
LinearAlgebra.issymmetric(::AdjacencyMatrix{<:EdgeValGraph}) = true

LinearAlgebra.adjoint(matrix::AdjacencyMatrix{<:EdgeValGraph}) = matrix
LinearAlgebra.transpose(matrix::AdjacencyMatrix{<:EdgeValGraph}) = matrix

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
struct ValMatrix{Tv, G <: AbstractGraph, key} <: AbstractSparseMatrix{Tv, Int}

    graph::G
    zero_value::Tv
end

"""
    ValMatrix(g::AbstractGraph, key, zero_value)

Construct a new `ValMatrix` view for a graph `g` where the values are
the edge values specified by `key`. Entries that are not in the graph
are represented by `zero_value` in the matrix.

### See also
[`AdjacencyMatrix`](@ref), [`adjacency_matrix`](@ref), [`weigths`](@ref)

### Examples
```jldoctest
julia> gv = EdgeValDiGraph((s, d) -> (rand(), "\$s-\$d"), path_digraph(3), (a=Float64, b=String))
{3, 2} directed EdgeValDiGraph{Int64} graph with multiple named edge values of types (a = Float64, b = String).

julia> ValMatrix(gv, 1, 0.0)
3×3 ValMatrix{Float64,EdgeValDiGraph{Int64,NamedTuple{(:a, :b),Tuple{Float64,String}},NamedTuple{(:a, :b),Tuple{Array{Array{Float64,1},1},Array{Array{String,1},1}}}},1}:
 0.0  0.706577  0.0
 0.0  0.0       0.680497
 0.0  0.0       0.0

 julia> ValMatrix(gv, :b, nothing) |> Matrix
 3×3 Array{Union{Nothing, String},2}:
  nothing  "1-2"    nothing
  nothing  nothing  "2-3"
  nothing  nothing  nothing
```
"""
function ValMatrix(g::AbstractValGraph{V, V_VALS, E_VALS}, key::Union{Integer, Symbol}, zero_value) where {V, V_VALS, E_VALS}

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
    return get_val_or(matrix.graph, s, d, key, matrix.zero_value)
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

LG.weights(g::AbstractValGraph{V, V_VALS, <: AbstractNTuple{0}}) where {V, V_VALS} = LG.DefaultDistance(nv(g))

LG.weights(g::AbstractValGraph{V, V_VALS, <: AbstractNTuple{1}}; kwargs...) where {V, V_VALS} = LG.weights(g, 1; kwargs...)

function LG.weights(g::AbstractValGraph, key; zerovalue=zero(E_VAL_for_key(edgevals_type(g), key)))

    return ValMatrix(g, key, zerovalue)
end

