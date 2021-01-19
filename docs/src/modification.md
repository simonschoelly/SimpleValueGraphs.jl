# Modifying Graph Properties

Subtypes of `AbstractValGraph` are not by default modifiable, but `ValGraph`, `ValOutDiGraph` and `ValDiGraph`
are. Modifiable graphs may implement some of the methods here.

## Modifying vertices

To add a vertex, use the `add_vertex` method. If the graph has vertex values, they must
also be passed to this function.

```julia
julia> g2 = ValGraph(0, vertexval_types=(a=Int, ), vertexval_init=undef);

julia> add_vertex!(g2, (a=50,))
true

julia> g1 = ValGraph(4);

julia> add_vertex!(g1)
true

julia> g2 = ValGraph(0, vertexval_types=(a=Int, ), vertexval_init=undef);

julia> add_vertex!(g2, (a=50,))
true
```

Vertex values can be set using the `set_vertexval!` function.

```julia
julia> g = ValGraph(5, vertexval_types=(a=Int, String), vertexval_init=undef);

julia> set_vertexval!(g, 1, :a, 50)
true
```

### Modifying edges

To add an edge, one can use the `add_edge!` method. As with vertices, if the graph has edge values,
one must pass them to the function. If the edge already exists in that graph, it will change them
to the new values.

```julia
julia> g = ValDiGraph(5, edgeval_types=(Int,));

julia> add_edge!(g, 1, 2, (10,))
true

julia> add_edge!(g, 1, 2, (20,))
false

julia> get_edgeval(g, 1, 2, :)
(20,)
```

One can remove edges using the `rem_edge!` function.

```julia
julia> g = ValDiGraph(5, edgeval_types=(Int,));

julia> add_edge!(g, 1, 2, (10,))
true

julia> ne(g)
1

julia> rem_edge!(g, 1, 2)
true

julia> ne(g)
0
```

To modify edge values, one can use the `set_edgeval!` function

```julia
julia> g = ValDiGraph(5, edgeval_types=(a=Int,b=String));

julia> add_edge!(g, 1, 2, (a=10, b="xyz"))
true

julia> set_edgeval!(g, 1, 2, :a, 20)
true

julia> set_edgeval!(g, 1, 2, :, (30, "abc"))
true
```







