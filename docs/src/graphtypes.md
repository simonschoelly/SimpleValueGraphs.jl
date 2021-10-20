# Graph Types

SimpleValueGraphs currently defines an abstract graph type
and three concrete implementations.

## AbstractValGraph

The abstract type `AbstractValGraph` denotes a graph that can have multiple vertex
and edge values. It has the signature 
```julia
    AbstractValGraph{V, V_VALS, E_VALS} <: Graphs.AbstractGraph{V}
```
where the parameters have the following meaning:
- `V` is the type used for indexing vertices, called the *eltype* of the graph. Should
    be a subtype of `Integer`.
- `V_VALS` is the type of the vertex values.
- `E_VALS` is the type of the edge values.

The value types `V_VALS` and `E_VALS` are either subtypes of `Tuple`  for unnamed values or of
`NamedTuple` for named values. For example
```julia
    AbstractValGraph{Int16, NamedTuple{(:label,) Tuple{String}}, Tuple{Int64, Float32}}
```
is an `AbstractValGraph` with eltype `Int16`, a single vertex value of type `String` called `label`
and two unnamed edge values of type `Int64` and `Float32`.

Use the empty tuple type `Tuple{}` to denote that a graph does not have vertex or edge values.

### Querying for type information

!!! info
    Here we use the function `SimpleValueGraphs.swissmetro_graph()` to load
    an example graph. The signature of this graphs type looks a bit more complicated,
    but we can check what kind of `AbstractValGraph` it is:
    ```julia
    julia> g = SimpleValueGraphs.swissmetro_graph();
    
    julia> supertype(typeof(g))
    AbstractValGraph{
        Int8,
        NamedTuple{(:name, :population),Tuple{String,Int32}},
        NamedTuple{(:distance,),Tuple{Float64}}
    }
    ```

The eltype of an `AbstractValGraph` can be queried with the `eltype` function:
```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> eltype(g)
Int8
```

The types of the vertex and edge values can be queried with `vertexvals_type` 
and `edgevals_type`

```
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> vertexvals_type(g)
NamedTuple{(:name, :population),Tuple{String,Int32}}

julia> edgevals_type(g)
NamedTuple{(:distance,),Tuple{Float64}}
``` 

Furthermore we have `hasvertexkey` and `hasedgekey` to check if a graph has a vertex
or edge value for some specific key:

```julia
julia> g = SimpleValueGraphs.swissmetro_graph();

julia> hasvertexkey(g, :name)
true

julia> hasvertexkey(g, :code)
false

julia> hasedgekey(g, 1)
true
```

## Concrete graphs

```julia
     ValGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C} <: AbstractEdgeValGraph{V, V_VALS, E_VALS}
ValOutDiGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C} <: AbstractEdgeValGraph{V, V_VALS, E_VALS}
   ValDiGraph{V, V_VALS, E_VALS, C_VALS_C, E_VALS_C} <: AbstractEdgeValGraph{V, V_VALS, E_VALS}
```
``V_VALS_C`and `  E_VALS_C` are the types of the internal data structure used to store the  values. These types
are always based on `V_VALS` and `E_VALS`, and are calculated automatically by the constructor.

All three graph types represent simple graphs but also allow for self-loops.

#### ValGraph
Is an undirected graph

#### ValOutDiGraph
Is a directed graph that for each vertex only stores the outgoing edges. Therefore it only
support iterating over outgoing edges of a specific vertex. The advantage is that it uses much less
memory than `ValDiGraph`.

#### ValDiGraph
Is a directed graph that for each vertex only stores both the incoming as well as the outgoing edges.
Is supports iterating over incoming and outgoing edges of a specific vertex with the disadvantage
that it might use nearly twice as much memory as `ValOutDiGraph`.

### Constructors

The constructors for all three graph types are basically the same, so
we focus on `ValGraph` here.

#### Graphs without values

Graphs without any values an be created with 
```julia
    ValGraph{V = Int32}(n)
```
where `n` is the number of vertices. One notable difference to Graphs.jl is that the
eltype is not bases on the type of `n` but is always taken from the parameter `V`.

```julia
julia> g1 = ValGraph(4)
{4, 0} undirected ValGraph with
              eltype: Int32
  vertex value types: ()
    edge value types: ()

julia> g2 = ValDiGraph{Int8}(4)
{4, 0} directed ValDiGraph with
              eltype: Int8
  vertex value types: ()
    edge value types: ()
```

#### Graphs with edge values

If the graph should have edge values, their types can be specified in the constructor
with the keyword argument `edgeval_types`. This is either a `Tuple` of types for unnamed
edge values or a `NamedTuple` of types for named edge values. 
Note that we still need to use a `Tuple` or `NamedTuple` if we have just a single type.

```julia
# Single unnamed edge value
julia> g1 = ValGraph(4; edgeval_types=(Int64,))
{4, 0} undirected ValGraph with
              eltype: Int32
  vertex value types: ()
    edge value types: (Int64,)

# Two named edge values
julia> g2 = ValDiGraph{Int8}(4; edgeval_types=(a=String, b=Bool))
{4, 0} directed ValDiGraph with
              eltype: Int8
  vertex value types: ()
    edge value types: (a = String, b = Bool)
```

#### Graphs with vertex values

Similar to edge vales, vertex values can be specified with the `verteval_types` keyword argument.
But the problem here is, that we already create some vertices in the constructor,
so we also must specify how to initialize the values for these vertices.
We do that by using the `vertexval_init` keyword argument, which is either `undef `in
case we do not actually want to initialize these values (similar to `undef` for arrays)
or a function `v -> values` that take a vertex index and returns a tuple or named tuple
of vertex values

```julia
# Single unnamed vertex value, use undef for initialization
julia> g1 = ValGraph(4; vertexval_types=(Int64,), vertexval_init=undef)
{4, 0} undirected ValGraph with
              eltype: Int32
  vertex value types: (Int64,)
    edge value types: ()

# Two named vertex values, use a function for initialization
julia> g2 = ValDiGraph{Int8}(4;
                vertexval_types=(a=String, b=Bool),
                vertexval_init= v -> (a="$v", b=false)
            )
{4, 0} directed ValDiGraph with
              eltype: Int8
  vertex value types: (a = String, b = Bool)
    edge value types: ()
```

#### Graph from Graphs.jl SimpleGraphs

One can also initialize a graph from a Graphs.jl `SimpleGraph` or `SimpleDiGraph`. If
edge values are specified (with the `edgeval_types` keyword) we also need an initializer for
edge values. We do that by using the `edgeval_init` keyword argument which can be
either `undef` or a function `(s, d) -> values` that takes a source and target vertex and
and return a tuple or named tuple of edge values.  The constructor takes care that it calls
this function only with `s <= d`  for undirected graphs, so that we do not have to worry
about symmetry. This is not the case if one uses `undef` though.

Furthermore, if the eltype is not specified as a parameter, it is taken from the simple
graph.

```julia
julia> using Graphs.jl: smallgraph, PathDiGraph

julia> g_simple = smallgraph(:house)
{5, 6} undirected simple Int64 graph

julia> g1 = ValGraph(g_simple;
                edgeval_types=(Int64, ),
                edgeval_init=(s, d) -> (s + d, )
            )
{5, 6} undirected ValGraph with
              eltype: Int64
  vertex value types: ()
    edge value types: (Int64,)

julia> g_simple_directed = PathDiGraph(3)
{3, 2} directed simple Int64 graph

julia> g2 = ValOutDiGraph{Int8}(g_simple_directed;
                vertexval_types=(String, ),
                vertexval_init=undef
            )
{3, 2} directed ValOutDiGraph with
              eltype: Int8
  vertex value types: (String,)
    edge value types: ()
```







