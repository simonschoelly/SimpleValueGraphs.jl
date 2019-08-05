# ===== AbstractValueGraph ==========

abstract type AbstractValueGraph{V<:Integer, E_VAL} <: AbstractGraph{V} end


OneValueGraph{V, E_VAL} = AbstractValueGraph{V, E_VALS} where
    E_VALS <: Union{Tuple{<:E_VAL}, NamedTuple{S, Tuple{<:E_VAL}} where S}

ZeroValueGraph{V} = AbstractValueGraph{V, E_VALS} where
    E_VALS <: Union{Tuple{}, NamedTuple{S, Tuple{}} where S}


const default_edgevals = (Float64,)

const default_edgevals_type = Tuple{Float64}

#= TODO do we still need these?
default_edgeval(E_VAL)::E_VAL = oneunit(E_VAL)
default_edgeval(::Type{Nothing})::Nothing = nothing
default_edgeval(T::Type{<:AbstractTuple})::T = T( default_edgeval(U) for U in T.types )

default_zero_edgeval(::Type{Nothing}) = nothing
default_zero_edgeval(E_VAL) = zero(E_VAL)
default_zero_edgeval(E_VAL::Type{<:AbstractTuple}) = E_VAL( default_zero_edgeval(T) for T in E_VAL.types )
=#


eltype(::AbstractValueGraph{V}) where {V} = V

edgetype(G::Type{<:AbstractValueGraph{V, E_VALS}}) where {V, E_VALS} =
    is_directed(G) ? ValueDiEdge{V, E_VALS} : ValueEdge{V, E_VALS}

edgetype(g::AbstractValueGraph) = edgetype(typeof(g))

edgevals_type(::Type{<:AbstractValueGraph{V, E_VALS}}) where {V, E_VALS} = E_VALS
edgevals_type(g::AbstractValueGraph) = edgevals_type(typeof(g))

edges(g::AbstractValueGraph) = ValueEdgeIter(g)
edges_for_key(g::AbstractValueGraph, key) = ValueEdgeIter(g, g.edgevals[key])

nv(g::AbstractValueGraph) = eltype(g)(length(g.fadjlist))
ne(g::AbstractValueGraph) = g.ne

zero(G::AbstractValueGraph{V}) where {V} = G(zero(V))

vertices(g::AbstractValueGraph) = Base.OneTo(nv(g))
has_vertex(g::AbstractValueGraph, v) = v ∈ vertices(g)

# === Iterators =====================

struct ValueEdgeIter{G<:AbstractValueGraph} <: AbstractEdgeIter
    g::G
end

length(iter::ValueEdgeIter) = ne(iter.g)

function eltype(::Type{<:ValueEdgeIter{G}}) where
        {V, E_VALS, G <: AbstractValueGraph{V, E_VALS}}

    return (is_directed(G) ? ValueDiEdge : ValueEdge){V, E_VALS}
end
eltype(iter::ValueEdgeIter) = eltype(typeof(iter))


function is_validkey(
            g::AbstractValueGraph{V, E_VALS},
            key::Symbol) where {V, E_VALS <: NamedTuple}

    return key in E_VALS.names
end

function is_validkey(
            g::AbstractValueGraph{V, E_VALS},
            key::Integer) where {V, E_VALS <: AbstractTuple}

    return key in OneTo(length(E_VALS.types))
end

function validkey_or_throw(g, key)
    is_validkey(g, key) && return nothing

    error("$key is not a valid edge key for this graph.")
end




#
# === Display =====================

function show(io::IO, g::AbstractValueGraph)
    dir = is_directed(g) ? "directed" : "undirected"
    println(io, "{$(nv(g)), $(ne(g))} $dir $(eltype(g)) ValueGraph with edge values of type $(edgevals_type(g))")
end


