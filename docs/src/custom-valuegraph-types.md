# Custom Value Graph types

While this package provides some concrete graph types, one is often interested in creating
their own graph types. This section will explain how one can create a custom graph type that
will work well with the methods from as package as well as the ones from
[Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl)

## The AbstractValGraph type

All value graphs should be subtypes of *AbstractValGraph* that has the signature

```julia
    AbstractValGraph{V <: Integer, V_VALS, E_VALS, G_VALS} <: Graphs.AbstractGraph{V}
```
where the parameters have the following meaning:
- `V` is the type used for indexing vertices, called the *eltype* of the graph. Should
    be a subtype of `Integer`.
- `V_VALS` is the type of the vertex values.
- `E_VALS` is the type of the edge values.
- `G_VALS` is the type of the graph values.

The value types `V_VALS`, `E_VALS` and `G_VALS` are either subtypes of `Tuple` for unnamed values or of
`NamedTuple` for named values.

A subtype of `AbstractValGraph` is free to restrict some of these parameters, for example
```julia
MyGraphType{W} <: AbstractValGraph{Int, Tuple{}, Tuple{Int, W}, Tuple{}}
```
is a graph  type that has neither vertex nor graph values and two edge values,
one of them of type `Int` and the other of type `W`.

As a subtype of `Graphs.AbstractGraph`, an `AbstractValGraph` should implement the
[methods required by Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) as well as some
other methods. Luckily a lot of the methods required for `AbstractGraph` already have a default
implementation, so the number of necessary methods is actually much shorter.

We distinguish between methods that need to be implemented, methods that only need to be
implemented in some cases to enable extra features, and methods that have a default implementation
that can be overridden for performance or other reasons.

### Necessary methods

| method                  | brief description                                     |
| :---------------------- | :------------------                                   |
| `nv(g)`                 | number of vertices                                    |
| `has_edge(g, s, d)`     | true if there is an edge from vertex `s` to `d`       |
| `is_directed(G)`        | true if graph type `G` is directed                    |
| `zero(G)`               | create an instance of graph type `G` without vertices |


### Necessary in some cases

| method                             | necessary if              | brief description                            |
| :----------------------            | :------------             | :------------------                          |
| `get_graphval(g, i)`               | `g` has graph values      | i-th graph value of `g`                      |
| `get_vertexval(g, v, i)`           | `g` has vertex values     | i-th vertex value of vertex `v`              |
| `get_edgevalval(g, s, d, i)`       | `g` has edge values       | i-th edge value of the edge `s -> d`         |
|                                    |                           |                                              |
| `set_graphval!(g, i, val)`         | one can set graph values  | set the i-th graph value of `g`              |
| `set_vertexval!(g, v, i, val)`     | one can set vertex values | set the i-th vertex value of vertex `v`      |
| `set_edgevalval!(g, s, d, i, val)` | one can set edge values   | set the i-th edge value of the edge `s -> d` |
|                                    |                           |                                              |
| `add_vertex!(g, vals)`             | one can add vertices      | add a vertex with values `vals`              |
| `rem_vertex!(g, v)`                | one can remove vertices   | remove vertex `v`                            |
|                                    |                           |                                              |
| `add_edge!(g, s, d, vals)`         | one can add edges         | add an edge `s -> d` with values `vals`      |
| `rem_edge!(g, s, d)`               | one can remove edges      | remove the edge `s -> d`                     |

### Methods with default implementations

| method                  | brief description                                     |
| :---------------------- | :------------------                                   |
| `ne(g)`                 | number of edges                                       |

TODO there are more


### Changing the edgetype
TODO
