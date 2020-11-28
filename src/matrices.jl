
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
[`AdjacencyMatrix`](@ref), [`ValMatrix`](@ref), [`weights`](@ref)

### Examples

```jldoctest
julia> using LightGraphs> star_graph
julia> gv = ValGraph((s, d) -> (1.0, ), star_graph(4), (Float64, ))
{4, 3} undirected ValGraph{Int64} graph with edge values of type (Float64,).

julia> adjacency_matrix(gv)
4×4 AdjacencyMatrix{ValGraph{Int64,Tuple{Float64},Tuple{Array{Array{Float64,1},1}}}}:
 0  1  1  1
 1  0  0  0
 1  0  0  0
 1  0  0  0
```
"""
LG.adjacency_matrix(g::AbstractValGraph) = AdjacencyMatrix(g)

LinearAlgebra.ishermitian(::AdjacencyMatrix{<:ValGraph}) = true
LinearAlgebra.issymmetric(::AdjacencyMatrix{<:ValGraph}) = true

LinearAlgebra.adjoint(matrix::AdjacencyMatrix{<:ValGraph}) = matrix
LinearAlgebra.transpose(matrix::AdjacencyMatrix{<:ValGraph}) = matrix

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
julia> gv = ValDiGraph((s, d) -> (rand(), "\$s-\$d"), path_digraph(3), (a=Float64, b=String))
{3, 2} directed ValDiGraph{Int64} graph with multiple named edge values of types (a = Float64, b = String).

julia> ValMatrix(gv, 1, 0.0)
3×3 ValMatrix{Float64,ValDiGraph{Int64,NamedTuple{(:a, :b),Tuple{Float64,String}},NamedTuple{(:a, :b),Tuple{Array{Array{Float64,1},1},Array{Array{String,1},1}}}},1}:
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

### weights

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

