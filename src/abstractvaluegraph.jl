
# ======================================================
# AbstractValGraph structure
# ======================================================

"""
    AbstractValGraph{V, V_VALS, E_VALS} <: AbstractGraph{V}

Abstract value graph with vertex type `V`, vertex values of types `V_VALS`
and edge values of types `E_VALS`.

### See also
[`AbstractGraph`](@ref), [`AbstractEdgeValGraph`](@ref)
"""
abstract type AbstractValGraph{V<:Integer, V_VALS, E_VALS} <: AbstractGraph{V} end

#  ------------------------------------------------------
#  specialised types
#  ------------------------------------------------------

OneEdgeValGraph{V, V_VALS, E_VAL} = AbstractValGraph{V, V_VALS, <: AbstractNTuple{1, E_VAL}}

ZeroEdgeValGraph{V, V_VALS} = AbstractValGraph{V, V_VALS, <: AbstractNTuple{0}}

OneVertexValGraph{V, V_VAL, E_VALS} = AbstractValGraph{V, <: AbstractNTuple{1, V_VAL}, E_VALS}

ZeroVertexValGraph{V, E_VALS} = AbstractValGraph{V, <: AbstractNTuple{0}, E_VALS}

# ======================================================
# Type parameter information
# ======================================================

#  ------------------------------------------------------
#  eltype
#  ------------------------------------------------------

LG.eltype(::Type{<:AbstractValGraph{V}}) where {V} = V

# This should not be necessary, as Base implements `eltype(x) = eltype(typeof(x))`
# but unfortunately LightGraphs redefines `eltype(::AbstractGraph)` as not defined
LG.eltype(g::AbstractValGraph) = eltype(typeof(g))


#  ------------------------------------------------------
#  vertexvals_type
#  ------------------------------------------------------

# TODO might also implement this for SimpleGraph
"""
    vertexvals_type(g::AbstractValGraph)
    vertexvals_type(::Type{<:AbstractValGraph})

Return the types of the vertex values of a graph `g`.
"""
vertexvals_type(g::AbstractValGraph) = vertexvals_type(typeof(g))

vertexvals_type(::Type{<:AbstractValGraph{V, V_VALS}}) where {V, V_VALS} = V_VALS


#  ------------------------------------------------------
#  edgevals_type
#  ------------------------------------------------------

# TODO might also implement this for SimpleGraph
"""
    edgevals_type(g::AbstractValGraph)
    edgevals_type(::Type{<:AbstractValGraph})

Return the types of the edge values of a graph `g`.
"""
edgevals_type(g::AbstractValGraph) = edgevals_type(typeof(g))

edgevals_type(::Type{<:AbstractValGraph{V, V_VALS, E_VALS}}) where {V, V_VALS, E_VALS} = E_VALS


#  ------------------------------------------------------
#  hasedgekey & hasedgekey_or_throw
#  ------------------------------------------------------

"""
    hasedgekey(g::AbstractValGraph, key)
    hasedgekey(::Type{<:AbstractValGraph}, key)

Return true if `key` is an edge value key for this graph.
"""
hasedgekey(g::AbstractValGraph, key) = hasedgekey(typeof(g), key)

function hasedgekey(
            G::Type{<:AbstractValGraph{V, V_VALS, E_VALS}},
            key::Symbol) where {V, V_VALS, E_VALS <: NamedTuple}

    return key in E_VALS.names
end

function hasedgekey(
            G::Type{<:AbstractValGraph{V, V_VALS, E_VALS}},
            key::Integer) where {V, V_VALS, E_VALS <: AbstractTuple}

    return key in OneTo(length(E_VALS.types))
end


function hasedgekey_or_throw(G::Type{<:AbstractValGraph}, key)
    hasedgekey(G, key) && return nothing

    error("$key is not a valid edge key for this graph.")
end

hasedgekey_or_throw(g::AbstractValGraph, key) = hasedgekey_or_throw(typeof(g), key)


#  ------------------------------------------------------
#  hasvertexkey & hasvertexkey_or_throw
#  ------------------------------------------------------

"""
    hasvertexkey(g::AbstractValGraph, key)
    hasvertexkey(::Type{<:AbstractValGraph}, key)

Return true if `key` is a vertex value key for this graph.
"""
function hasvertexkey(
            G::Type{<:AbstractValGraph{V, V_VALS}},
            key::Symbol) where {V, V_VALS <: NamedTuple}

    return key in V_VALS.names
end

function hasvertexkey(
            G::Type{<:AbstractValGraph{V, V_VALS}},
            key::Integer) where {V, V_VALS <: AbstractTuple}

    return key in OneTo(length(V_VALS.types))
end

hasvertexkey(g::AbstractValGraph, key) = hasvertexkey(typeof(g), key)

function hasvertexkey_or_throw(G::Type{<:AbstractValGraph}, key)
    hasvertexkey(G, key) && return nothing

    error("$key is not a valid vertex key for this graph.")
end

hasvertexkey_or_throw(g::AbstractValGraph, key) = hasvertexkey_or_throw(typeof(g), key)


# ======================================================
#  show
# ======================================================

function Base.show(io::IO, ::MIME"text/plain", g::AbstractValGraph)
    print(io, "{$(nv(g)), $(ne(g))}")
    print(io, " ", is_directed(g) ? "directed" : "undirected")
    print(io, " $(typeof(g).name) with")
    println(io)
    print(io, "              eltype: $(eltype(g))")
    println(io)
    print(io, "  vertex value types: $(tuple_of_types(vertexvals_type(g)))")
    println(io)
    print(io, "    edge value types: $(tuple_of_types(edgevals_type(g)))")
end


# ======================================================
# Partial default implementation of LightGraphs interface
# ======================================================

LG.vertices(g::AbstractValGraph) = OneTo{eltype(g)}(nv(g))

LG.has_vertex(g::AbstractValGraph, v) = v ∈ vertices(g)

LG.edges(g::AbstractValGraph) = ValEdgeIter(g)

LG.edgetype(g::AbstractValGraph) = eltype(edges(g))

LG.ne(g::AbstractValGraph) = length(edges(g))

# TODO a Base.Generator would be better here, but it causes problems with sort. Maybe
# add a custom iterator
LG.outneighbors(g::AbstractValGraph, u) = [v for v ∈ vertices(g) if has_edge(g, u, v)]

LG.inneighbors(g::AbstractValGraph, v) = is_directed(g) ? [u for u ∈ vertices(g) if has_edge(g, u, v)] : outneighbors(g, v)


# ======================================================
# Modifiers
# ======================================================

#  -----------------------------------------------------
#  add_edge!
#  -----------------------------------------------------

"""
    add_edge!(g::AbstractValGraph, s, d, [values])

Add an edge `e = (s, d, values)` to a graph `g` and set the edge values.

If `g` does not have and edge values, `values` can be omitted.

Return `true` if the edge was added successfully, otherwise return `false`.
If the edge already exists, return `false` but still change the edge values.
"""
function add_edge! end

LG.add_edge!(g::ZeroEdgeValGraph, s, d) = add_edge!(g, s, d, edgevals_type(g)(()))


#  -----------------------------------------------------
#  add_vertex!
#  -----------------------------------------------------

"""
    add_vertex!(g::AbstractValGraph[, values])

Add an vertex to a graph `g` and set the vertex values.

If `g` does not have vertex values, `values` can be omitted.

Return `true` if the vertex was added successfully, otherwise return `false`.
"""
function add_vertex! end

LG.add_vertex!(g::ZeroVertexValGraph) = add_vertex!(g, vertexvals_type(g)(()))


# ======================================================
# Accessors
# ======================================================

#  -----------------------------------------------------
#  get_vertexval
#  -----------------------------------------------------

"""
    get_vertexval(g::AbstractValGraph, v, key)

Return the vertex value for vertex `v` and key `key`. If `g` has a single
vertex value, `key` can be omitted.
"""
function get_vertexval end

get_vertexval(g::AbstractValGraph, v, key::Symbol) =
    get_vertexval(g, v, Base.fieldindex(vertexvals_type(g), key))

get_vertexval(g::OneVertexValGraph, v) = get_vertexval(g, v, 1)

"""
    get_vertexval(g::AbstractValGraph, v, :)

Return all vertex value for vertex `v`.
"""
function get_vertexval(g::AbstractValGraph, v, ::Colon)

    V_VALS = vertexvals_type(g)
    return V_VALS(get_vertexval(g, v, i) for i in OneTo(length(V_VALS.types)))
end


#  -----------------------------------------------------
#  get_edgeval
#  -----------------------------------------------------

"""
    get_edgeval(g::AbstractValGraph, s, d, key)

Return the value associated with the edge `s -> d` for the key `key` in `g`.

Throw an exception if the graph does not contain such an edge or if the key is not a valid edge key.

For graphs that only have one value per edge, `key` can be omitted.

### See also
[`get_edgeval_or`](@ref), [`set_val!`](@ref)

### Examples
```jldoctest
julia> gv = ValDiGraph((s, d) -> (rand(),), path_digraph(3), (a=Float64,))
{3, 2} directed ValDiGraph{Int64} graph with named edge values of type (a = Float64,).

julia> get_edgeval(gv, 1, 2, :a)
0.6238826396606063

julia> get_edgeval(gv, 1, 2, 1)
0.6238826396606063

julia> get_edgeval(gv, 1, 2)
0.6238826396606063

julia> get_edgeval(gv, 1, 3)
ERROR: No such edge

julia> get_edgeval(gv, 1, 2, :b)
ERROR: type NamedTuple has no field b
```
"""
get_edgeval(g::AbstractValGraph, s, d, key::Symbol) =
    get_edgeval(g, s, d, Base.fieldindex(edgevals_type(g), key))

get_edgeval(g::OneEdgeValGraph, s, d) = get_edgeval(g, s, d, 1)

"""
    get_edgeval(g::AbstractValGraph, s, d, :)

Return all values associated with the edge `s -> d` in `g`.

Throw an exception if the graph does not contain such an edge.

### See also
[`get_edgeval_or`](@ref), [`set_val!`](@ref)

### Examples
```jldoctest
julia> gv = ValDiGraph((s, d) -> (rand(), 10), path_digraph(3), (a=Float64, b=Int))
{3, 2} directed ValDiGraph{Int64} graph with multiple named edge values of types (a = Float64, b = Int64).

julia> get_edgeval(gv, 1, 2, :)
(a = 0.38605078026294826, b = 10)

julia> get_edgeval(gv, 1, 3, :)
ERROR: Values not found
```
"""
function get_edgeval(g::AbstractValGraph, s, d, ::Colon)

    E_VALS = edgevals_type(g)
    return E_VALS(get_edgeval(g, s, d, i) for i in OneTo(length(E_VALS.types)))
end

#  -----------------------------------------------------
#  get_edgeval_or
#  -----------------------------------------------------

"""
    get_edgeval_or(g::ValGraph, s, d, alternative)
    get_edgeval_or(g::ValDiGraph, s, d, alternative)
    get_edgeval_or(g::ValOutDiGraph, s, d, alternative)

Return all values associated with the edge `s -> d` in `g`.

If there is no such edge return `alternative`.

### See also
[`get_edgeval`](@ref), [`set_edgeval!`](@ref)

### Examples
```jldoctest
julia> gv = ValDiGraph((s, d) -> (rand(), 10), path_digraph(3), (a=Float64, b=Int))
{3, 2} directed ValDiGraph{Int64} graph with multiple named edge values of types (a = Float64, b = Int64).

julia> get_edgeval_or(gv, 1, 2, :, missing)
(a = 0.34307617867033446, b = 10)

julia> get_edgeval_or(gv, 1, 3, :, missing)
missing
```
"""
get_edgeval_or(g::AbstractValGraph, s, d, key, alternative) =
    has_edge(g, s, d) ? get_edgeval(g, s, d, key) : alternative

get_edgeval_or(g::OneEdgeValGraph, s, d, alternative) = get_edgeval_or(g, s, d, 1, alternative)


#  -----------------------------------------------------
#  set_edgeval!
#  -----------------------------------------------------

set_edgeval!(g::OneEdgeValGraph, s, d, value) = set_edgeval!(g, s, d, 1, value)

set_edgeval!(g::AbstractValGraph, s, d, key::Symbol, value) =
    set_edgeval!(g, s, d, Base.fieldindex(edgevals_type(g), key), value)

"""
    set_edgeval!(g::AbstractValGraph, s, d, :, values)

Set the values of the edge `e: s -> d` to `values`. Return `true` if such an edge exists and
`false` otherwise.
"""
function set_edgeval!(g::AbstractValGraph, s, d, ::Colon, values)

    has_edge(g, s, d) || return false

    E_VALS = edgevals_type(g)

    # TODO currently we cannot convert from tuples to named tuples or vice versa
    values = convert(E_VALS, values)
    for (i, value) in values
        set_edgeval!(g, s, d, i, value)
    end

    return true
end


#  ------------------------------------------------------
#  set_vertexval!
#  ------------------------------------------------------

set_vertexval!(g::OneVertexValGraph, v, value) = set_vertexval!(g, v, 1, value)

set_vertexval!(g::AbstractValGraph, v, key::Symbol, value) =
    set_vertexval!(g, v, Base.fieldindex(vertexvals_type(g), key), value)

"""
    set_vertexval!(g::AbstractValGraph, v, :, values)

Set the values of the vertex `v` to `values`. Return `true` if such an vertex exists
and `false` otherwise.
"""
function set_vertexval!(g::AbstractValGraph, v, ::Colon, values)

    has_vertex(g, v) || return false

    V_VALS = vertexvals_type(g)

    # TODO currently we cannot convert from tuples to named tuples or vice versa
    values = convert(V_VALS, values)
    for (i, value) in enumerate(values)
        set_vertexval!(g, v, i, value)
    end

    return true
end


#  ------------------------------------------------------
#  outedgevals
#  ------------------------------------------------------

"""
    outedgevals(g::AbstractValGraph, v [, key])

Return an iterator of edge values of outgoing edges from `v` to its neighbors.

If `g` has multiple edge values, the key cannot be omitted.
The order of the neighbors is the same as for `outneighbors(g, v)`.
"""
function outedgevals end

outedgevals(g::OneEdgeValGraph, v) = outedgevals(g, v, 1)

outedgevals(g::AbstractValGraph, v, key::Symbol) =
    outedgevals(g, v, Base.fieldindex(edgevals_type(g), key))

outedgevals(g::AbstractValGraph, u, key::Integer) =
    [get_edgeval(g, u, v, key) for v in outneighbors(g, u)]


#  ------------------------------------------------------
#  inedgevals
#  ------------------------------------------------------

"""
    inneighbors(g::AbstractValGraph, v [, key])

Return an iterator of edge values of ingoing edges from neighbors of `v`.

If `g` has multiple edge values, the key cannot be omitted.
The order of the neighbors is the same as for `inneighbors(g, v)`.
"""
function inedgevals end

inedgevals(g::OneEdgeValGraph, v) = inedgevals(g, v, 1)

inedgevals(g::AbstractValGraph, v, key::Symbol) =
    inedgevals(g, v, Base.fieldindex(edgevals_type(g), key))

inedgevals(g::AbstractValGraph, v, key::Integer) =
    [get_edgeval(g, u, v, key) for v in inneighbors(g, v)]



# ======================================================
# Edge Iterator
# ======================================================

struct ValEdgeIter{G<:AbstractValGraph} <: AbstractEdgeIter
    graph::G
end

Base.length(iter::ValEdgeIter) = count(_ -> true, iter)

function Base.eltype(::Type{<:ValEdgeIter{G}}) where
        {V, V_VALS, E_VALS, G <: AbstractValGraph{V, V_VALS, E_VALS}}

    return (is_directed(G) ? ValDiEdge : ValEdge){V, E_VALS}
end
Base.eltype(iter::ValEdgeIter) = eltype(typeof(iter))

function Base.iterate(iter::ValEdgeIter)

    verts = vertices(iter.graph)

    isempty(verts) && return nothing

    iterate(iter, (vertices=verts, i=1, j=1))
end

function Base.iterate(iter::ValEdgeIter, state)

    verts = state.vertices
    i = state.i
    j = state.j
    graph = iter.graph

    while i <= length(verts)
        u = verts[i]
        while j <= length(verts)
            v = verts[j]
            if !is_directed(graph) && u > v
                j += 1
                continue
            end
            if has_edge(graph, u, v)
                new_state = (vertices=verts, i=i, j=j+1)
                edge = eltype(iter)(u, v, get_edgeval(graph, u, v, :))
                return (edge, new_state)
            end
            j += 1
        end
        i += 1
        j = 1
    end
    return nothing
end


