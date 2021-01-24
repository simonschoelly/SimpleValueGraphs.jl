### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ c7cd922c-1b76-11eb-2860-2bdefdcbf8b2
begin
	import Pkg
	Pkg.activate(".")

	using SimpleValueGraphs

	# For creating reproducable random matrices
	using Random: MersenneTwister
	using SparseArrays

	# We are going to test our new packages with some functions
	# from LightGraphs and GraphsRecipes
	using LightGraphs
	using GraphRecipes, Plots
	pyplot() # gr backend has issues showing edge labels so we use pyplot instead
end

# ╔═╡ 9ce46c16-2085-11eb-076f-256b70803020
md"""
# Creating a new value graph type

This notebook show how one create a new graph type that subclasses `AbstractValGraph`.

The new graph type will be a wrapper type around a matrix `A`, so that the graph has
a directed edge from vertex `i` to vertex `j` with weight `A[i, i]` if that entry is not zero.

We start by importing a few packages that we are going to use later:
"""

# ╔═╡ daf7b178-2087-11eb-23cb-6d4f29edc176
md"""
The definition of `AbstractValGraph` is
```julia
abstract type AbstractValGraph{V<:Integer, V_VALS, E_VALS, G_VALS} <: AbstractGraph{V} end
```
where
* `V` is the type of the vertices
* `V_VALS` are the types of the vertex values
* `E_VALS` are the types of the edge values
* `G_VALS` are the types of the edge values

As this type of `LightGraphs.AbstractGraph`, it can also be used with LightGraphs functions as long as we correctly implement the `AbstractGraph` interface.

In our case the vertex type will be `Int` as this type is also used for indexing rows and columns in a matrix.

We don't have any graph or vertex values, so use the empty tuple type for `V_VALS` and `G_VALS`.

For the edge values we have a single type (the type of the values in our matrix). We also want to give the name `:weight` to these values. This can be done by using the named tuple type `NamedTuple{(:weight,), Tuple{T}}` where `T` is the type of the matrix values.

Then our definition is:
"""

# ╔═╡ 9259d936-1b79-11eb-15cc-abaa483a07c0
struct GraphView{T, M<:AbstractMatrix{<:T}} <: SimpleValueGraphs.AbstractValGraph{
		Int,
		Tuple{},
		NamedTuple{(:weight,), Tuple{T}},
		Tuple{}
	}

	matrix::M
end

# ╔═╡ ec4e6c94-2082-11eb-3d82-d799a91863a7
md"""

## Implementing the AbstractValGraph interface

To be able to do anything meaningful with that graph, we have to implement the interface for `LightGraphs.AbstractGraph` as well as the interface for `SimpleGraphs.AbstractValGraph`. Luckily, SimpleValueGraphs provides already some sensible defaults (that can be overriden for performance or other reasons) for a lot of LightGraphs functions so that what we will have to implement is less than is usually required by LightGraphs. Nevertheless we need to implement the following functions:

* `nv(::GraphView)`
* `is_directed(::Type{<:GraphView})`
* `has_edge(::GraphView, s, d)`
* `zero(::Type{<:GraphView{T, M}) where {T, M}`

And because our graphs has edge values, we also need to implement
* `get_edgeval(::GraphView, s, d, :)`

"""

# ╔═╡ 3f533e8e-208e-11eb-090a-6543f23256a2
md"""
##### nv
`nv(g)` should return the number of vertices in our graph. We could make sure in the constructor that the wrapped matrix is square, but instead we just the minimum of the number of rows and columns as the number of vertices so that any additional values in the matrix are simply ignored.
"""

# ╔═╡ 5e162db8-208e-11eb-09e0-5f14ac2f631c
SimpleValueGraphs.nv(g::GraphView) = minimum(size(g.matrix))

# ╔═╡ 5923245a-208e-11eb-0dd9-0fc7c7344c84
md"""
##### is_directed

`is_directed` returns whether the graph is directed or not. This should be a property of the graph type itself, regardless of the values in that graph. As our matrix is not necessarily symmetric (although we could ensure that with a check in the constructor), our graph will be directed.
"""

# ╔═╡ bb9187f8-1b7f-11eb-15c5-d7884b4cca33
SimpleValueGraphs.is_directed(::Type{<:GraphView}) = true

# ╔═╡ a3b59cc2-208f-11eb-32d0-238d11964bf9
md"""
##### has_edge
`has_edge(g, u, v)` should return true if there is an edge between the vertices `u` and `v`. This should be the case when the entry in the wrapped matrix is zero. We can check that by using the `iszero` function. This also means that our graph type does not work for value types that do not have `iszero` defined.

We also verify that `u` and `v` are actually vertices of our graph. For this we use the `vertices` function that alreay has a default implementation through the implementation of `nv`.
"""

# ╔═╡ e28e02c8-1b7f-11eb-2949-1fc7e27f6cc2
function SimpleValueGraphs.has_edge(g::GraphView, u, v)
	u ∉ vertices(g) && return false
	v ∉ vertices(g) && return false

	return !iszero(g.matrix[u, v])
end

# ╔═╡ 10913788-2091-11eb-31a9-8dc219364439
md"""
##### get_edgeval
`get_edgeval(g, u, v, key::Integer)` should return the edge value associated with the edge between `u` and `v` for a  specific key. We only have to implement this method for integer keys. As we only have a single value for each edge, we accept all values for the key - a more sophisticated approach would be to throw an error if the key is not correct.

In our case we do not explicetly verify that the edge exist altought we could do so and throw a specialised error message. But this is not part of the interface and functions that deal with value graphs should not relay on that.
"""

# ╔═╡ 5fce373e-56a0-11eb-015f-e39d395121d4
SimpleValueGraphs.get_edgeval(g::GraphView, u, v, key::Integer) = weight=g.matrix[u, v]

# ╔═╡ ed96451c-5596-11eb-1c39-8b28c0e661af
md"""
##### zero
This function is a bit of an anomaly and should in my opinion not be part of the LightGraphs interface. It is also rarely used in LightGraphs, so it might not be a very big issue to omit it. Nevertheless we implement it here for the sake of completeness.

`zero(G)` should create a graph with zero vertices, given a graph type. We do this here by trying to create a matrix of size (0, 0) and the correct matrix type, and then wrap a `GraphView` around it:
"""

# ╔═╡ d594af1c-5690-11eb-3b9d-4f3e1f6384ee
function SimpleValueGraphs.zero(::Type{<:GraphView{T, M}}) where {T, M}
	matrix = convert(M, Matrix{T}(undef, 0, 0))
	return GraphView{T, M}(matrix)
end

# ╔═╡ 455072ea-5692-11eb-1a6b-23f3cfac6a16
zero(GraphView{String, Matrix{String}})

# ╔═╡ a36d032a-5692-11eb-1b38-3772dea5f067
zero(GraphView{Float64, SparseMatrixCSC{Float64}})

# ╔═╡ 45463dee-56a0-11eb-2181-8f0089913ef5
md"## Using our new graph type"

# ╔═╡ 7757542e-2092-11eb-20b4-ff4234b49d32
md"""
Now we are ready to create `GraphView` of a matrix and verify that it indeed works.

We start by creating a sparse 5x5 matrix where each entry is _not_ zero with probability 0.3. For better reproducibility we used a `MersenneTwister` random generator with a fixed seed.

"""

# ╔═╡ 9ef5fe50-1b7d-11eb-1ad4-115e1adeeebe
A = sprand(MersenneTwister(1), Float64, 5, 5, 0.3)

# ╔═╡ 339348dc-2093-11eb-3896-d1e25cbfa433
md"""
Then we wrap this matrix in our `GraphView`. As `A` has 11 non-zero entries, our directed graph should also have 11 edges.
"""

# ╔═╡ bee02bdc-1b7d-11eb-2f87-bb568e3e6b7c
g = GraphView(A)

# ╔═╡ 8d4cc722-2093-11eb-0b98-8741fa511c84
md"Let's verify that our graph has the correct number of edges"

# ╔═╡ bc09149c-2093-11eb-3d18-1b90f05311a8
ne(g)

# ╔═╡ dad3ce14-2093-11eb-076d-e1c784c74c8c
md"We can also look at the list of edges in our graph:"

# ╔═╡ e8b78692-2093-11eb-233b-63061135f033
edges(g) |> collect

# ╔═╡ ecaf3358-2093-11eb-33a9-a1404f9571b0
md"""
This seems to work as it should. By using the `weights` function, we can also get a matrix of the weights in our graph:
"""

# ╔═╡ 4c9dc1f8-2094-11eb-0660-75c6a339a717
weights(g)

# ╔═╡ 598a9a44-2094-11eb-0518-9f2b052d0140
md"We can verify that these are the same values as in our wrapped matrix:"

# ╔═╡ 6f99a4f6-2094-11eb-3987-3d079af43bd8
weights(g) == A

# ╔═╡ 7a02edde-56a0-11eb-28cd-f15320b018ed
md"""
We should also quickly check that `zero` works and then forget about it:
"""

# ╔═╡ 90c970ba-56a0-11eb-039b-45777dda3357
zero(typeof(g))

# ╔═╡ 75a1a2a6-2094-11eb-2989-d5fa04fb8a33
md"""
### Plotting

Using [GraphRecipes.jl](https://github.com/JuliaPlots/GraphRecipes.jl) we can now also plot our graph:
"""

# ╔═╡ a6f47b56-2094-11eb-05ce-a336e6dd028b
graphplot(g)

# ╔═╡ d035e7d4-2094-11eb-2121-3b675521b9db
md"""
Let's add some vertex labels and the eddge weights so that is easier to verify that this corresponds to our matrix:
"""

# ╔═╡ ff2d75f6-2045-11eb-3d9c-218b3f5adfb3
graphplot(g,
	names=vertices(g),
	edgelabel=trunc.(weights(g), digits=2), # truncate weights for better readability
	nodecolor=:lightgreen,
	nodesize=0.2
)

# ╔═╡ 9a2272c8-2096-11eb-349d-91f34702dd1f
md"""
### Shortest paths


Let's use some functions from LightGraphs to find the shortest path from vertex `2` to `5`:
"""

# ╔═╡ 1147357a-2095-11eb-224e-61ad831db786
path = enumerate_paths(dijkstra_shortest_paths(g, 2), 5)

# ╔═╡ f24f1466-2098-11eb-11ad-479e850f798d
md"""
We want to visualize this path with GraphRecipes. For that we create a `Dict` that assigns to each edge (a tuple of source and destination of that edge) a color.
"""

# ╔═╡ be361882-2097-11eb-3003-a3503eefca35
begin
	edgecolor = Dict()
	# Set all edgecolors to black
	for e in edges(g)
		edgecolor[(src(e), dst(e))] = :black
	end
	# Set the edgecolor for edges on the path to red
	for i in 1:length(path)-1
		edgecolor[(path[i], path[i+1])] = :red
	end
end

# ╔═╡ a33449d8-2099-11eb-3740-a91b14a285f6
md"""
Now we can pass `edgecolor` to the plotting function:
"""

# ╔═╡ 4abed890-2099-11eb-2287-6b1dce2dd4f2
graphplot(g,
	names=vertices(g),
	edgelabel=trunc.(weights(g), digits=2),
	edgecolor=edgecolor,
	nodecolor=:lightgreen,
	nodesize=0.2
)

# ╔═╡ e8acb5ca-1b7d-11eb-3f4e-4f4dfb631517


# ╔═╡ 4daf3fde-1bcb-11eb-2eec-ebe2c0c0f11d


# ╔═╡ a3d03dde-1bcb-11eb-37ff-b558b6ecde1a


# ╔═╡ 6f14c1fa-1bcb-11eb-1ea3-5547297c6fa0


# ╔═╡ Cell order:
# ╟─9ce46c16-2085-11eb-076f-256b70803020
# ╠═c7cd922c-1b76-11eb-2860-2bdefdcbf8b2
# ╟─daf7b178-2087-11eb-23cb-6d4f29edc176
# ╠═9259d936-1b79-11eb-15cc-abaa483a07c0
# ╠═ec4e6c94-2082-11eb-3d82-d799a91863a7
# ╟─3f533e8e-208e-11eb-090a-6543f23256a2
# ╠═5e162db8-208e-11eb-09e0-5f14ac2f631c
# ╟─5923245a-208e-11eb-0dd9-0fc7c7344c84
# ╠═bb9187f8-1b7f-11eb-15c5-d7884b4cca33
# ╟─a3b59cc2-208f-11eb-32d0-238d11964bf9
# ╠═e28e02c8-1b7f-11eb-2949-1fc7e27f6cc2
# ╟─10913788-2091-11eb-31a9-8dc219364439
# ╠═5fce373e-56a0-11eb-015f-e39d395121d4
# ╟─ed96451c-5596-11eb-1c39-8b28c0e661af
# ╠═d594af1c-5690-11eb-3b9d-4f3e1f6384ee
# ╠═455072ea-5692-11eb-1a6b-23f3cfac6a16
# ╠═a36d032a-5692-11eb-1b38-3772dea5f067
# ╟─45463dee-56a0-11eb-2181-8f0089913ef5
# ╟─7757542e-2092-11eb-20b4-ff4234b49d32
# ╠═9ef5fe50-1b7d-11eb-1ad4-115e1adeeebe
# ╟─339348dc-2093-11eb-3896-d1e25cbfa433
# ╠═bee02bdc-1b7d-11eb-2f87-bb568e3e6b7c
# ╟─8d4cc722-2093-11eb-0b98-8741fa511c84
# ╠═bc09149c-2093-11eb-3d18-1b90f05311a8
# ╟─dad3ce14-2093-11eb-076d-e1c784c74c8c
# ╠═e8b78692-2093-11eb-233b-63061135f033
# ╟─ecaf3358-2093-11eb-33a9-a1404f9571b0
# ╠═4c9dc1f8-2094-11eb-0660-75c6a339a717
# ╟─598a9a44-2094-11eb-0518-9f2b052d0140
# ╠═6f99a4f6-2094-11eb-3987-3d079af43bd8
# ╟─7a02edde-56a0-11eb-28cd-f15320b018ed
# ╠═90c970ba-56a0-11eb-039b-45777dda3357
# ╟─75a1a2a6-2094-11eb-2989-d5fa04fb8a33
# ╠═a6f47b56-2094-11eb-05ce-a336e6dd028b
# ╟─d035e7d4-2094-11eb-2121-3b675521b9db
# ╠═ff2d75f6-2045-11eb-3d9c-218b3f5adfb3
# ╟─9a2272c8-2096-11eb-349d-91f34702dd1f
# ╠═1147357a-2095-11eb-224e-61ad831db786
# ╟─f24f1466-2098-11eb-11ad-479e850f798d
# ╠═be361882-2097-11eb-3003-a3503eefca35
# ╟─a33449d8-2099-11eb-3740-a91b14a285f6
# ╠═4abed890-2099-11eb-2287-6b1dce2dd4f2
# ╟─e8acb5ca-1b7d-11eb-3f4e-4f4dfb631517
# ╟─4daf3fde-1bcb-11eb-2eec-ebe2c0c0f11d
# ╟─a3d03dde-1bcb-11eb-37ff-b558b6ecde1a
# ╟─6f14c1fa-1bcb-11eb-1ea3-5547297c6fa0
