# Accessing Graph Properties

## Accessing vertices

To get the number of vertices of a graph one can use the `nv` function:

```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> nv(g)
6
```

The vertex ids of a graph can be queried with the `vertices` function

```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> vertices(g)
Base.OneTo(6)

julia> vertices(g) |> collect
6-element Array{Int8,1}:
 1
 2
 3
 4
 5
 6
```

One can check if a graph has a specific vertex with the `has_vertex` function:
```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> has_vertex(g, 1)
true

julia> has_vertex(g, 8)
false
```

To query for the vertex value of a graph `g`, one an use the function `get_vertexval(g, vertex_id, key)`, where `key` is a `Integer` or in the case of named values also a `Symbol` that specifies which vertex value we are interested in:

```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

# The first value of vertex 6, i.e. :name
julia> get_vertexval(g, 6, 1)
"Zürich"

# The value of vertex 6 that is called :population
julia> get_vertexval(g, 6, :population)
415215
```

One can also query for all values of a vertex with the colon operator `:` as key:
```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> get_vertexval(g, 6, :)
(name = "Zürich", population = 415215)
```

To iterate over neighboring vertices of a vertex, one can use the functions
`inneighbors`, `outneighbors`, and `all_neighbors`. Note that while `innehgbors` and `all_neighbors` work also for graphs of type `ValOutDiGraph`, they may be rather slow.

```julia
julia> g = ValOutDiGraph(path_digraph(3));

julia> inneighbors(g, 2)
1-element Array{Int64,1}:
 1

julia> outneighbors(g, 2)
1-element Array{Int64,1}:
 3

julia> all_neighbors(g, 2)
2-element Array{Int64,1}:
 3
 1
```

## Accessing edges

To get the number of vertices of a graph one can use the `ne` function:

```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> ne(g)
5
```

To get all edges of `g` use the `edges` function. This function has an optional `key` argument, if it is set to `:`, then also all edge values are returned.

```julia
g = SimpleValueGraphs.swissmetro_graph();

julia> collect(edges(g))
5-element Array{ValEdge{Int8,Tuple{}},1}:
 ValEdge 1 -- 6

 ValEdge 2 -- 4

 ValEdge 2 -- 6

 ValEdge 3 -- 4

 ValEdge 5 -- 6


julia> collect(edges(g, :))
5-element Array{ValEdge{Int8,NamedTuple{(:distance,),Tuple{Float64}}},1}:
 ValEdge 1 -- 6 with value distance = 89.0

 ValEdge 2 -- 4 with value distance = 81.0

 ValEdge 2 -- 6 with value distance = 104.0

 ValEdge 3 -- 4 with value distance = 68.0

 ValEdge 5 -- 6 with value distance = 69.0


julia> 

```

To check if `g` has an edge between two vertices, one can use the `has_edge` function:
```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> has_edge(g, 1, 2)
false

julia> has_edge(g, 1, 6)
true

julia> has_edge(g, 6, 1)
true
```

To query for the edge value between vertices `s` and `d` in `g`, one an use the function `get_edgeval(g, s, d, key)`, where `key` is a `Integer` or in the case of named values also a `Symbol` that specifies which edge value we are interested in:

```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

# The first value of the edge between 1 and 6, i.e. :name
julia> get_edgeval(g, 1, 6, 1)
89.0

# We can also use the name :distance
julia> get_edgeval(g, 1, 6, :distance)
89.0
```

One can also query for all values of an edge with the colon operator `:` as key:
```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> get_edgeval(g, 1, 6, :)
(distance = 89.0,)
```

There is also the function `get_edgeval_or` that returns an alternative value if that edge does not exist:

```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> get_edgeval_or(g, 1, 1, :distance, missing)
missing

julia> get_edgeval_or(g, 1, 6, :distance, missing)
89.0
``` 

To query for the ingoing or outgoing edge values for some vertex `v`, one can use the `inedgevals` and `outedgevals` functions.

```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

# ingoing edge values for vertex 6 and values for key 1
julia> inedgevals(g, 6, 1)
3-element Array{Float64,1}:
  89.0
 104.0
  69.0

# outgoing edge values for vertex 6 and values for key :distance
julia> outedgevals(g, 6, :distance)
3-element Array{Float64,1}:
  89.0
 104.0
  69.0
```
