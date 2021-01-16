# Matrices

SimpleValueGraphs currently supports two kind of matrices from graphs: adjacency matrices
that contain the topology of the graph.

## Adjacency matrices

The `adjacency_matrix` function creates an adjacency matrix from a value graph . In contrast
to LightGraphs, this is just a immutable *matrix view* of the graph, i.e if the graph
changes, then so does this matrix. Therefore to get a mutable adjacency matrix one has to convert
it before to some other matrix type.

It is also possible to use the constructor `AdjacencyMatrix` to create a view of any
`LightGraphs.AbstractGraph`.

```julia
julia> g1 = SimpleValueGraphs.swissmetro_graph();

julia> adjacency_matrix(g)
6×6 AdjacencyMatrix{ValGraph{[...]}:
 0  0  0  0  0  1
 0  0  0  1  0  1
 0  0  0  1  0  0
 0  1  1  0  0  0
 0  0  0  0  0  1
 1  1  0  0  1  0

julia> g2 = smallgraph(:housex)
{5, 8} undirected simple Int64 graph

julia> AdjacencyMatrix(g2)
5×5 AdjacencyMatrix{SimpleGraph{Int64}}:
 0  1  1  1  0
 1  0  1  1  0
 1  1  0  1  1
 1  1  1  0  1
 0  0  1  1  0
```
 
## Value matrices
 
One can also create a matrix view of the edge values of a graph, where entry `(i,j)` of the matrix contains
the edge value of the edge `i -> j`. Entries in the matrix for non-existing edges are represented by some extra
value.
 
```julia
julia> g = ValGraph(3, edgeval_types = (a = Int, b = String));

julia> add_edge!(g, 1, 2, (a=10, b="abc"))
true

julia> add_edge!(g, 1, 3, (a=20, b="xyz"))
true

julia> ValMatrix(g, :a, 0)
3×3 ValMatrix{Int64,ValGraph{[...]},:a}:
  0  10  20
 10   0   0
 20   0   0

julia> ValMatrix(g, :b, nothing)
3×3 ValMatrix{Union{Nothing, String},ValGraph{[...]},:b}:
 nothing  "abc"    "xyz"
 "abc"    nothing  nothing
 "xyz"    nothing  nothing
```
 
One can also use the `LightGraphs.weights` function to obtain this matrix. If the graph
does not have any edge values, this returns a `LightGraphs.DefaultDistance` instead.
 
```julia
 julia> weights(g1, :a)
3×3 ValMatrix{Int64,ValDiGraph{[...]},:a}:
 0  10   0
 0   0  20
 0   0   0

julia> g2 = ValDiGraph(3);

julia> add_edge!(g2, 1, 2);

julia> weights(g2)
3 × 3 default distance matrix (value = 1)
```
 
 
 
 
 
