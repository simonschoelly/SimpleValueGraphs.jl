# SimpleValueGraphs.jl
![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)

This is a experimental package that uses the interface from [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl).
It is similar to [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) and [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl).
It solves the following problem:
- The topology of `MetaGraphs` can be changed fast, but changing and querying edge values is slow.
- Changing the topology of `SimpleWeightedGraphs` is slow, but changing and querying edge values is fast.
