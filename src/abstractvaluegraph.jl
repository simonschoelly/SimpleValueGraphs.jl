# ===== AbstractValGraph ==========

"""
    AbstractValGraph{V, V_VALS, E_VALS} <: AbstractGraph{V}

Abstract value graph with vertex type `V`, vertex values of types `V_VALS}`
and edge values of types `E_VALS`.

### See also
[`AbstractGraph`](@ref), [`AbstractEdgeValGraph`](@ref)
"""
abstract type AbstractValGraph{V<:Integer, V_VALS, E_VALS} <: AbstractGraph{V} end

LG.eltype(::Type{<:AbstractValGraph{V}}) where {V} = V
# This should not be necessary, as Base implements `eltype(x) = eltype(typeof(x))`
# but unfortunately LightGraphs redefines `eltype(::AbstractGraph)` as not defined
LG.eltype(g::AbstractValGraph) = eltype(typeof(g))

# TODO examples
# TODO might also implement this for SimpleGraph
"""
	edgevals_type(g::AbstractValGraph)

Return the types of the edgevalues of a graph `g`.
"""
function edgevals_type end

vertexvals_type(::Type{<:AbstractValGraph{V, V_VALS, E_VALS}}) where {V, V_VALS, E_VALS} = V_VALS
vertexvals_type(g::AbstractValGraph) = vertexvals_type(typeof(g))

edgevals_type(::Type{<:AbstractValGraph{V, V_VALS, E_VALS}}) where {V, V_VALS, E_VALS} = E_VALS
edgevals_type(g::AbstractValGraph) = edgevals_type(typeof(g))


# === Type information =====================

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

hasedgekey(g::AbstractValGraph, key) = hasedgekey(typeof(g), key)

function hasedgekey_or_throw(G::Type{<:AbstractValGraph}, key)
    hasedgekey(G, key) && return nothing

    error("$key is not a valid edge key for this graph.")
end

hasedgekey_or_throw(g::AbstractValGraph, key) = hasedgekey_or_throw(typeof(g), key)


function hasvertexkey(
            G::Type{<:AbstractValGraph{V, V_VALS}},
            key::Symbol) where {V, V_VALS <: NamedTuple}

    return key in V_VALS.names
end

function hasvertexkey(
            G::Type{<:AbstractValGraph{V, V_VALS}},
            key::Integer) where {V, V_VALS <: AbstractTuple}

    return key in OneTo(length(E_VALS.types))
end

hasvertexkey(g::AbstractValGraph, key) = hasvertexkey(typeof(g), key)

function hasvertexkey_or_throw(G::Type{<:AbstractValGraph}, key)
    hasvertexkey(G, key) && return nothing

    error("$key is not a valid vertex key for this graph.")
end

hasvertexkey_or_throw(g::AbstractValGraph, key) = hasvertexkey_or_throw(typeof(g), key)


# === Partial default implementation of the LightGraphs interface =====================

LG.vertices(g::AbstractValGraph) = OneTo{eltype(g)}(nv(g))

LG.has_vertex(g::AbstractValGraph, v) = v ∈ vertices(g)

LG.edges(g::AbstractValGraph) = ValEdgeIter(g)

LG.edgetype(g::AbstractValGraph) = eltype(edges(g))

LG.ne(g::AbstractValGraph) = length(edges(g))

# TODO a Base.Generator would be better here, but it causes problems with sort. Maybe
# add a custom iterator
LG.outneighbors(g::AbstractValGraph, u) = [v for v ∈ vertices(g) if has_edge(g, u, v)]

LG.inneighbors(g::AbstractValGraph, v) = is_directed(g) ? [u for u ∈ vertices(g) if has_edge(g, u, v)] : outneighbors(g, v)

#
# === Accessors =====================

# TODO might consider adding a check
get_val(g::AbstractValGraph{V, Tuple{}}, v::Integer, ::Colon) where {V} = ()
get_val(g::AbstractValGraph{V, NamedTuple{(), Tuple{}}}, v::Integer, ::Colon) where {V} = NamedTuple()




get_val(g::AbstractValGraph{V, V_VALS, Tuple{}}, s::Integer, d::Integer, ::Colon) where {V, V_VALS} = ()
get_val(g::AbstractValGraph{V, V_VALS, NamedTuple{(), Tuple{}}}, s::Integer, d::Integer, ::Colon) where {V, V_VALS} = NamedTuple()

get_val(g::AbstractValGraph, s::Integer, d::Integer, key::Union{Integer, Symbol}) = get_val(g, s, d, :)[key]

get_val_or(g::AbstractValGraph, s::Integer, d::Integer, key::Union{Integer, Symbol}, alternative) = has_edge(g, s, d) ? get_val(g, s, d, key) : alternative


# === Edge Iterator =====================

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
        while j <= length(verts) nothing
            u = verts[i]
            v = verts[j]
            if has_edge(graph, u, v)
                new_state = (vertices=verts, i=i, j=j+1)
                edge = eltype(iter)(u, v, get_val(graph, u, v, :))
                return (edge, new_state)
            end
            j += 1
        end
        i += 1
        j = 1
    end
    return nothing
end


#= TODO
function Base.iterate(iter::ValEdgeIter)

    iterate(iter, (srcs=vertices(iter.graph), dsts=nothing))
end

function Base.iterate(iter::ValEdgeIter, state)

    srcs, dsts = state
    graph = iter.graph
    # Not ideal, should passed along in each iteration
    verts = vertices(graph)

    while srcs != nothing
        s, srcs_state = srcs
        while dsts != nothing
            d = dsts, dsts_state
            if (is_directed(graph) || d >= s) && has_edge(graph, s, d)
                v = get_val(graph, s, d, :)
                return is_directed(graph) ? ValDiEdge(s, d, v) : ValEdge(s, d, v)
            end
            dsts = iterate(vertices(g), dsts_state)
        end
        srcs = iterate(vertices(g), 

    end
end
=#



# ===== AbstractEdgeValGraph ==========

abstract type AbstractEdgeValGraph{V<:Integer, E_VALS} <: AbstractValGraph{V, Tuple{}, E_VALS} end

OneEdgeValGraph{V, E_VAL} = AbstractEdgeValGraph{V, E_VALS} where E_VALS <: AbstractNTuple{1, E_VAL}

ZeroEdgeValGraph{V} = AbstractEdgeValGraph{V, E_VALS} where E_VALS <: AbstractNTuple{0}

const default_eltype = Int32

LG.edgetype(G::Type{<:AbstractEdgeValGraph{V, E_VALS}}) where {V, E_VALS} =
    is_directed(G) ? ValDiEdge{V, E_VALS} : ValEdge{V, E_VALS}

LG.edges(g::AbstractEdgeValGraph) = ValEdgeIter(g)

LG.nv(g::AbstractEdgeValGraph) = eltype(g)(length(g.fadjlist))


