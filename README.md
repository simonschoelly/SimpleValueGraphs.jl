# SimpleValueGraphs.jl

[![version](https://juliahub.com/docs/SimpleValueGraphs/version.svg)](https://juliahub.com/ui/Packages/SimpleValueGraphs/aub6U)
![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://simonschoelly.github.io/SimpleValueGraphs.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://simonschoelly.github.io/SimpleValueGraphs.jl/dev)
[![Build Status](https://travis-ci.com/simonschoelly/SimpleValueGraphs.jl.svg?branch=master)](https://travis-ci.com/simonschoelly/SimpleValueGraphs.jl)
![CI](https://github.com/simonschoelly/SimpleValueGraphs.jl/workflows/CI/badge.svg?branch=master)
[![codecov](https://codecov.io/gh/simonschoelly/SimpleValueGraphs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/simonschoelly/SimpleValueGraphs.jl)
[![](https://img.shields.io/badge/chat-Zulip%23graphs-yellow)](https://julialang.zulipchat.com/#narrow/stream/228745-graphs)

This is a experimental package that uses the interface from [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl).
It is similar to [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) and [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl).
It solves the following problem:
- The topology of `MetaGraphs` can be changed fast, but changing and querying edge values is slow.
- Changing the topology of `SimpleWeightedGraphs` is slow, but changing and querying edge values is fast.

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

