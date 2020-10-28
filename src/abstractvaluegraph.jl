# ===== AbstractValGraph ==========

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

edgevals_type(::Type{<:AbstractValGraph{V, V_VALS, E_VALS}}) where {V, V_VALS, E_VALS} = E_VALS
edgevals_type(g::AbstractValGraph) = edgevals_type(typeof(g))

LG.vertices(g::AbstractValGraph) = OneTo{eltype(g)}(nv(g))
LG.has_vertex(g::AbstractValGraph, v) = v ∈ vertices(g)

LG.edgetype(g::AbstractValGraph) = eltype(edges(g))
LG.ne(g::AbstractValGraph) = length(edges(g))

LG.inneighbors(g::AbstractValGraph, v) = (u for u ∈ vertices(g) if has_edge(g, u, v))
LG.outneighbors(g::AbstractValGraph, u) = (v for v ∈ vertices(g) if has_edge(g, u, v))

# ===== AbstractEdgeValGraph ==========

abstract type AbstractEdgeValGraph{V<:Integer, E_VALS} <: AbstractValGraph{V, Tuple{}, E_VALS} end

OneEdgeValGraph{V, E_VAL} = AbstractEdgeValGraph{V, E_VALS} where E_VALS <: AbstractNTuple{1, E_VAL}

ZeroEdgeValGraph{V} = AbstractEdgeValGraph{V, E_VALS} where E_VALS <: AbstractNTuple{0}

const default_eltype = Int32

LG.edgetype(G::Type{<:AbstractEdgeValGraph{V, E_VALS}}) where {V, E_VALS} =
    is_directed(G) ? ValDiEdge{V, E_VALS} : ValEdge{V, E_VALS}

LG.edgetype(g::AbstractEdgeValGraph) = edgetype(typeof(g))


LG.edges(g::AbstractEdgeValGraph) = ValEdgeIter(g)

LG.nv(g::AbstractEdgeValGraph) = eltype(g)(length(g.fadjlist))
LG.ne(g::AbstractEdgeValGraph) = g.ne

function is_validedgekey(
            G::Type{<:AbstractEdgeValGraph{V, E_VALS}},
            key::Symbol) where {V, E_VALS <: NamedTuple}

    return key in E_VALS.names
end

function is_validedgekey(
            G::Type{<:AbstractEdgeValGraph{V, E_VALS}},
            key::Integer) where {V, E_VALS <: AbstractTuple}

    return key in OneTo(length(E_VALS.types))
end

is_validedgekey(g::AbstractEdgeValGraph, key) = is_validedgekey(typeof(g), key)

function validedgekey_or_throw(G::Type{<:AbstractEdgeValGraph}, key)
    is_validedgekey(G, key) && return nothing

    error("$key is not a valid edge key for this graph.")
end

validedgekey_or_throw(g::AbstractEdgeValGraph, key) = validedgekey_or_throw(typeof(g), key)


# === Iterators =====================

struct ValEdgeIter{G<:AbstractEdgeValGraph} <: AbstractEdgeIter
    g::G
end

Base.length(iter::ValEdgeIter) = ne(iter.g)

function Base.eltype(::Type{<:ValEdgeIter{G}}) where
        {V, E_VALS, G <: AbstractEdgeValGraph{V, E_VALS}}

    return (is_directed(G) ? ValDiEdge : ValEdge){V, E_VALS}
end
Base.eltype(iter::ValEdgeIter) = eltype(typeof(iter))

