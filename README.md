# SimpleValueGraphs.jl

![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
[![version](https://juliahub.com/docs/SimpleValueGraphs/version.svg)](https://juliahub.com/ui/Packages/SimpleValueGraphs/aub6U)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://simonschoelly.github.io/SimpleValueGraphs.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://simonschoelly.github.io/SimpleValueGraphs.jl/dev)
![CI](https://github.com/simonschoelly/SimpleValueGraphs.jl/workflows/CI/badge.svg?branch=master)
[![codecov](https://codecov.io/gh/simonschoelly/SimpleValueGraphs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/simonschoelly/SimpleValueGraphs.jl)
[![](https://img.shields.io/badge/chat-Zulip%23graphs-yellow)](https://julialang.zulipchat.com/#narrow/stream/228745-graphs)

This is [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl) compatible package for graphs with multiple, homogeneous vertex and edge metadata. In particular it provides:
- an abstract interface for graphs with metadata
- concrete implementations of mutable graphs with metadata

Compared to [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl) it has the following advantages:
- vertex metadata
- multiple edge metadata
- faster structural modifications of graphs

Compared to [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) it has the following advantages:
- faster access and modifications of metadata
- better type stability when accessing metadata

## Example

```julia
using SimpleValueGraphs

using LightGraphs: smallgraph
using Plots
using GraphRecipes: graphplot
using Colors: RGB, Color

# Load a LightGraphs.SimpleGraph
gs = smallgraph(:house)

# Convert to a ValGraph with vertex and edge values
gv = ValGraph(gs;
    # Two names vertex values:
    # - color: A random color
    # - label: The vertex identifier as a string
    vertexval_types=(color=Color, label=String),
    vertexval_init=v -> (rand(RGB), string(v)),
    # One unnamed edge value:
    # A string s -- d from source to destination of each edge
    edgeval_types=(String, ),
    edgeval_init=(s, d) -> ("$s -- $d",)
)

# Plot this graph using the vertex and edge values
graphplot(gv;
    nodecolor = [get_vertexval(gv, v, :color) for v in vertices(gv)],
    names = [get_vertexval(gv, v, :label) for v in vertices(gv)],
    edgelabel=weights(gv; zerovalue="")
)
```
![example output](https://github.com/simonschoelly/SimpleValueGraphs.jl/blob/master/docs/assets/readme-example-output.png)

## Benchmarks

This is a comparison of running `LightGraphs.dijkstra_shortest_paths` on the [egonets-Facebook](https://snap.stanford.edu/data/egonets-Facebook.html) graph for multiple graph types.

| graph type                                        | time (ms) |
| ------------------------------------------------- | --------- |
| LightGraphs.SimpleGraph + Matrix weights          | 6.5       |
| LightGraphs.SimpleGraph + SparseMatrixCSC weights | 11.4      |
| SimpleWeightedGraphs.SimpleWeightedGraph          | 11.7      |
| MetaGraphs.MetaGraph                              | 141.9     |
| SimpleValueGraphs.ValGraph                        | 12.4      |

Currently a lot of LightGraphs algorithm do not optimally work with graphs that store edge metadata
internally. The next benchmark is an optimized version of the same algorithm that can be found
in `SimpleValueGraphs.Experimental.dijkstra_shortests_pasts`. Clearly, this is a huge improvement for
`ValGraph` and `SimpleWeightedGraph`.

| graph type                                        | time (ms) |
| ------------------------------------------------- | --------- |
| LightGraphs.SimpleGraph + Matrix weights          | 6.8       |
| LightGraphs.SimpleGraph + SparseMatrixCSC weights | 10.8      |
| SimpleWeightedGraphs.SimpleWeightedGraph          | 2.9       |
| MetaGraphs.MetaGraph                              | 147.3     |
| SimpleValueGraphs.ValGraph                        | 3.1       |

