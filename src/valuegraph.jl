


# ======================================================
# Structures
# ======================================================


"""
    ValGraph{V <: Integer, V_VALS, E_VALS, V_VALS_C, E_VALS_C} <: AbstractValGraph

A type representing an undirected simple graph with vertex and edge values.

# Parameters
- `V`: The type of the vertex indices. Should be a concrete subtype of `Integer`.
- `V_VALS`: The type of the vertex values, either a `Tuple` or `NamedTuple`.
- `E_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
- `V_VALS_C`: Internal storage parameter, is derived from `V_VALS`
- `E_VALS_C`: Internal storage parameter, is derived from `E_VALS`

The internal parameters `V_VALS_C` and `E_VALS_C` are automatically calculated
by the constructors so that they should usually not be manually specified.
"""
mutable struct ValGraph{  V <: Integer,
                            V_VALS <: AbstractTuple,
                            E_VALS <: AbstractTuple,
                            V_VALS_C,
                            E_VALS_C
                        } <: AbstractValGraph{V, V_VALS, E_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    vertexvals::V_VALS_C
    edgevals::E_VALS_C
end

"""
    ValOutDiGraph{V <: Integer, V_VALS, E_VALS, V_VALS_C, E_VALS_C} <: AbstractValGraph

A type representing a directed simple graph with vertex and edge values.

# Parameters
- `V`: The type of the vertex indices. Should be a concrete subtype of `Integer`.
- `V_VALS`: The type of the vertex values, either a `Tuple` or `NamedTuple`.
- `E_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
- `V_VALS_C`: Internal storage parameter, is derived from `V_VALS`
- `E_VALS_C`: Internal storage parameter, is derived from `E_VALS`


The internal parameters `V_VALS_C` and `E_VALS_C` are automatically calculated
by the constructors so that they should usually not be manually specified.

Uses less memory than `ValDiGraph` by only storing outgoing edges.
"""
mutable struct ValOutDiGraph{ V <: Integer,
                                V_VALS <: AbstractTuple,
                                E_VALS <: AbstractTuple,
                                V_VALS_C,
                                E_VALS_C
                              } <: AbstractValGraph{V, V_VALS, E_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    vertexvals::V_VALS_C
    edgevals::E_VALS_C
end


"""
    ValDiGraph{V <: Integer, V_VALS, E_VALS, V_VALS_C, E_VALS_C} <: AbstractValGraph

A type representing a directed simple graph with vertex and edge values.

# Parameters
- `V`: The type of the vertex indices. Should be a concrete subtype of `Integer`.
- `V_VALS`: The type of the vertex values, either a `Tuple` or `NamedTuple`.
- `E_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
- `V_VALS_C`: Internal storage parameter, is derived from `V_VALS`
- `E_VALS_C`: Internal storage parameter, is derived from `E_VALS`


The internal parameters `V_VALS_C` and `E_VALS_C` are automatically calculated
by the constructors so that they should usually not be manually specified.

Uses more memory than `ValOutDiGraph` by not only storing outgoing edges, but also
back edges.
"""
mutable struct ValDiGraph{    V <: Integer,
                                V_VALS <: AbstractTuple,
                                E_VALS <: AbstractTuple,
                                V_VALS_C,
                                E_VALS_C
                           } <: AbstractValGraph{V, V_VALS, E_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    badjlist::Adjlist{V}
    vertexvals::V_VALS_C
    edgevals::E_VALS_C
    redgevals::E_VALS_C
end

# ======================================================
# Constructors
# ======================================================

#  ------------------------------------------------------
#  helpers
#  ------------------------------------------------------

"""
The default eltype to use in a graph constructor when no eltype is specified.
"""
const default_eltype = Int32

# TODO these helpers maybe belong somewhere else and need a better name
construct_E_VAL(edgeval_types::Tuple) = Tuple{ (T for T in edgeval_types)... }
construct_E_VAL(edgeval_types::NamedTuple) =
    NamedTuple{ Tuple(typeof(edgeval_types).names), Tuple{ (T for T in edgeval_types)... }}

const default_edgeval_types = (weight=Float64,)

function create_edgevals(n, E_VAL::Type{<:Tuple})
    return Tuple( Adjlist{T}(n) for T in E_VAL.types )
end

function create_edgevals(n, E_VAL::Type{<:NamedTuple})
    return NamedTuple{Tuple(E_VAL.names)}(Tuple( Adjlist{T}(n) for T in E_VAL.types ))
end

function create_vertexvals(n, V_VALS::Type{<:NTuple{0}}, ::Nothing)
    return tuple()
end

function create_vertexvals(n, V_VALS::Type{<:NamedNTuple{0}}, ::Nothing)
    return NamedTuple()
end

function create_vertexvals(n, V_VALS::Type{<:Tuple}, ::UndefInitializer)
    return Tuple( Vector{T}(undef, n) for T in V_VALS.types )
end

function create_vertexvals(n, V_VALS::Type{<:NamedTuple}, ::UndefInitializer)
    return NamedTuple{Tuple(V_VALS.names)}(Tuple( Vector{T}(undef, n) for T in V_VALS.types ))
end

function create_vertexvals(n, V_VALS::Type{<:AbstractTuple}, f::Function)
    vertexvals = Tuple( Vector{T}(undef, n) for T in V_VALS.types )
    for v in 1:n
        t = f(v)
        for i in 1:length(V_VALS.types)
            vertexvals[i][v] = t[i]
        end
    end
    return vertexvals
end


#  ------------------------------------------------------
#  Constructors for empty graphs
#  ------------------------------------------------------

"""
    ValGraph{V = $default_eltype}(n; vertexval_types=(), edgeval_types=(), vertexval_initializer=nothing)
    ValGraph{V, V_VALS, E_VALS}(n, vertexval_initializer=nothing)

Construct a `ValGraph` with `n` vertices and 0 edges with of types
`edgeval_types`.

If omitted, the element type `V` is $(default_eltype).
"""
function ValGraph{V, V_VALS, E_VALS}(n::Integer, vertexval_initializer=nothing) where {V <: Integer, V_VALS <: AbstractTuple, E_VALS <: AbstractTuple}

    fadjlist = Adjlist{V}(n)
    vertexvals = create_vertexvals(n, V_VALS, vertexval_initializer)
    edgevals = create_edgevals(n, E_VALS)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C}(0, fadjlist, vertexvals, edgevals)
end

"""
    ValOutDiGraph{V = $default_eltype}(n; vertexval_types=(), edgeval_types=(), vertexval_initializer=nothing)
    ValOutDiGraph{V, V_VALS, E_VALS}(n, vertexval_initializer=nothing)

Construct a `ValOutDiGraph` with `n` vertices and 0 edges of types
`edgeval_types`.
If omitted, the element type `V` is $(default_eltype).

"""
function ValOutDiGraph{V, V_VALS, E_VALS}(n::Integer, vertexval_initializer=nothing) where {V<:Integer, V_VALS, E_VALS}

    fadjlist = Adjlist{V}(n)
    vertexvals = create_vertexvals(n, V_VALS, vertexval_initializer)
    edgevals = create_edgevals(n, E_VALS)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValOutDiGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C}(0, fadjlist, vertexvals, edgevals)
end


"""
    ValDiGraph{V = $default_eltype}(n; vertexval_types=(), edgeval_types=(), vertexval_initializer=nothing)
    ValDiGraph{V, E_VALS}(n, vertexval_initializer=nothing)

Construct a `ValDiGraph` with `n` vertices and 0 edges with value-types
`edgeval_types`.

If omitted, the element type `V` is $(default_eltype).
"""
function ValDiGraph{V, V_VALS, E_VALS}(n::Integer, vertexval_initializer=nothing) where {V<:Integer, V_VALS, E_VALS}

    fadjlist = Adjlist{V}(n)
    badjlist = Adjlist{V}(n)
    vertexvals = create_vertexvals(n, V_VALS, vertexval_initializer)
    edgevals = create_edgevals(n, E_VALS)
    redgevals = create_edgevals(n, E_VALS)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValDiGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C}(
                0, fadjlist, badjlist, vertexvals, edgevals, redgevals)
end


for G in (:ValGraph, :ValOutDiGraph, :ValDiGraph)
    @eval function $G(n::Integer; vertexval_types::AbstractTupleOfTypes=(), edgeval_types::AbstractTupleOfTypes=(), vertexval_initializer=nothing)
        V_VALS = construct_E_VAL(vertexval_types)
        E_VALS = construct_E_VAL(edgeval_types)
        return $G{default_eltype, V_VALS, E_VALS}(n, vertexval_initializer)
    end

    @eval function $G{V}(n::Integer; vertexval_types::AbstractTupleOfTypes=(), edgeval_types::AbstractTupleOfTypes=(), vertexval_initializer=nothing) where {V <: Integer}
        V_VALS = construct_E_VAL(vertexval_types)
        E_VALS = construct_E_VAL(edgeval_types)
        return $G{V, E_VALS, V_VALS}(V(n), vertexval_initializer)
    end
end


# =========================================================
# Interface
# =========================================================

#  ------------------------------------------------------
#  nv
#  ------------------------------------------------------

LG.nv(g::ValGraph) = eltype(g)(length(g.fadjlist))
LG.nv(g::ValOutDiGraph) = eltype(g)(length(g.fadjlist))
LG.nv(g::ValDiGraph) = eltype(g)(length(g.fadjlist))

#  ------------------------------------------------------
#  ne
#  ------------------------------------------------------

LG.ne(g::ValGraph) = g.ne
LG.ne(g::ValDiGraph) = g.ne
LG.ne(g::ValOutDiGraph) = g.ne

#  ------------------------------------------------------
#  add_edge!
#  ------------------------------------------------------

function LG.add_edge!(g::ValGraph{V, V_VALS, E_VALS},
                   s::Integer,
                   d::Integer,
                   values::E_VALS) where {V, V_VALS, E_VALS}

    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds

    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_values_for_index!(edgevals, s, index, values)
        s == d && return false # selfloop
        index = searchsortedfirst(g.fadjlist[d], s)
        set_values_for_index!(edgevals, d, index, values)
        return false
    end

    insert!(list, index, d)
    insert_values_for_index!(edgevals, s, index, values)
    g.ne += 1

    s == d && return true # selfloop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    insert_values_for_index!(edgevals, d, index, values)
    return true # edge successfully added
end

function LG.add_edge!(g::ValOutDiGraph{V, V_VALS, E_VALS},
                   s::Integer,
                   d::Integer,
                   value::E_VALS) where {V, V_VALS, E_VALS}

    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_values_for_index!(edgevals, s, index, value)
        return false
    end

    insert!(list, index, d)
    insert_values_for_index!(edgevals, s, index, value)
    g.ne += 1
    return true # edge successfully added
end

function LG.add_edge!(g::ValDiGraph{V, V_VALS, E_VALS},
                   s::Integer,
                   d::Integer,
                   value::E_VALS) where {V, V_VALS, E_VALS}

    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_values_for_index!(g.edgevals, s, index, value)
        return false
    end

    insert!(list, index, d)
    insert_values_for_index!(g.edgevals, s, index, value)
    g.ne += 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    insert_values_for_index!(g.redgevals, d, index, value)

    return true # edge successfully added
end

#  ------------------------------------------------------
#  rem_edge!
#  ------------------------------------------------------

function LG.rem_edge!(g::ValGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_values_for_index!(edgevals, s, index)

    g.ne -= 1
    s == d && return true # self-loop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    delete_values_for_index!(edgevals, d, index)

    return true
end

function LG.rem_edge!(g::ValOutDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_values_for_index!(edgevals, s, index)

    g.ne -= 1
    return true
end


function LG.rem_edge!(g::ValDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_values_for_index!(g.edgevals, s, index)

    g.ne -= 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    delete_values_for_index!(g.redgevals, d, index)

    return true
end

#  ------------------------------------------------------
#  add_vertex!
#  ------------------------------------------------------

function LG.add_vertex!(g::ValGraph{V, V_VALS, E_VALS}, values::V_VALS) where {V, V_VALS, E_VALS}

    if V != BigInt && nv(g) == typemax(V)
        # maybe consider capping at nv(g) - 1
        return false # cannot add more vertices
    end

    push!(g.fadjlist, V[])
    for i in 1:length(g.edgevals)
        push!(g.edgevals[i], E_VALS.types[i][])
    end

    for i in 1:length(g.vertexvals)
        push!(g.vertexvals[i], values[i])
    end

    return true
end

function LG.add_vertex!(g::ValOutDiGraph{V, V_VALS, E_VALS}, values::V_VALS) where {V, V_VALS, E_VALS}

    if V != BigInt && nv(g) == typemax(V)
        # maybe consider capping at nv(g) - 1
        return false # cannot add more vertices
    end

    push!(g.fadjlist, V[])
    for i in 1:length(g.edgevals)
        push!(g.edgevals[i], E_VALS.types[i][])
    end

    for i in 1:length(g.vertexvals)
        push!(g.vertexvals[i], values[i])
    end

    return true
end

function LG.add_vertex!(g::ValDiGraph{V, V_VALS, E_VALS}, values::V_VALS) where {V, V_VALS, E_VALS}

    if V != BigInt && nv(g) == typemax(V)
        # maybe consider capping at nv(g) - 1
        return false # cannot add more vertices
    end

    push!(g.fadjlist, V[])
    push!(g.badjlist, V[])
    for i in 1:length(g.edgevals)
        push!(g.edgevals[i], E_VALS.types[i][])
        push!(g.redgevals[i], E_VALS.types[i][])
    end

    for i in 1:length(g.vertexvals)
        push!(g.vertexvals[i], values[i])
    end

    return true
end

#  ------------------------------------------------------
#  has_edge
#  ------------------------------------------------------

function LG.has_edge(g::ValGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        d = s
        list_s = list_d
    end
    return LightGraphs.insorted(d, list_s)
end

function LG.has_edge(g::ValOutDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]

    return LightGraphs.insorted(d, list_s)
end

function LG.has_edge(g::ValDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_fadj = g.fadjlist[s]
    @inbounds list_badj = g.badjlist[d]
    if length(list_fadj) > length(list_badj)
        d = s
        list_fadj = list_badj
    end
    return LightGraphs.insorted(d, list_fadj)
end

#  ------------------------------------------------------
#  get_edgeval
#  ------------------------------------------------------


function get_edgeval(g::ValGraph, s::Integer, d::Integer, key::Integer)

    hasedgekey_or_throw(g, key) # TODO might be sufficient to just check index

    verts = vertices(g)

    (s in verts && d in verts) || error("No such edge")
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end

    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    # TODO more specific error
    error("No such edge")
end

function get_edgeval(g::ValOutDiGraph, s::Integer, d::Integer, key::Integer)

   hasedgekey_or_throw(g, key)

    verts = vertices(g)
    (s in verts && d in verts) || error("No such edge")
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    error("No such edge")
end

function get_edgeval(g::ValDiGraph, s::Integer, d::Integer, key::Integer)

    hasedgekey_or_throw(g, key)

    verts = vertices(g)
    (s in verts && d in verts) || error("No such edge")
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    error("No such edge")
end

function get_edgeval_or(g::ValGraph, s::Integer, d::Integer, key::Integer, alternative)

    hasedgekey_or_throw(g, key)

    verts = vertices(g)

    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end

    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    return alternative
end

function get_edgeval_or(g::ValOutDiGraph, s::Integer, d::Integer, key::Integer, alternative)

    hasedgekey_or_throw(g, key)

    verts = vertices(g)
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    return alternative
end

function get_edgeval_or(g::ValDiGraph, s::Integer, d::Integer, key::Integer, alternative)

    hasedgekey_or_throw(g, key)

    verts = vertices(g)
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    return alternative
end


function get_edgeval(g::ValGraph, s::Integer, d::Integer, ::Colon)

    verts = vertices(g)
    (s in verts && d in verts) || error("Values not found")
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return values_for_index(g.edgevals, edgevals_type(g), s, index)
    end
    error("Values not found")
end

function get_edgeval(g::ValOutDiGraph, s::Integer, d::Integer, ::Colon)

    verts = vertices(g)
    (s in verts && d in verts) ||  error("Values not found")

    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return values_for_index(g.edgevals, edgevals_type(g), s, index)
    end
    error("Values not found")
end

# TODO could probably be made faster by checking the shorter list
function get_edgeval(g::ValDiGraph, s::Integer, d::Integer, ::Colon)

    verts = vertices(g)
    (s in verts && d in verts) || error("Values not found")

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return values_for_index(g.edgevals, edgevals_type(g), s, index)
    end
    error("Values not found")
end


#  -----------------------------------------------------
#  get_edgeval_or
#  -----------------------------------------------------

function get_edgeval_or(g::ValGraph, s::Integer, d::Integer, ::Colon, alternative)

    verts = vertices(g)
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return values_for_index(g.edgevals, edgevals_type(g), s, index)
    end
    return alternative
end

function get_edgeval_or(g::ValOutDiGraph, s::Integer, d::Integer, ::Colon, alternative)

    verts = vertices(g)
    (s in verts && d in verts) ||  return alternative

    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return values_for_index(g.edgevals, edgevals_type(g), s, index)
    end
    return alternative
end

# TODO could probably be made faster by checking the shorter list
function get_edgeval_or(g::ValDiGraph, s::Integer, d::Integer, ::Colon, alternative)

    verts = vertices(g)
    (s in verts && d in verts) || return alternative

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return values_for_index(g.edgevals, edgevals_type(g), s, index)
    end
    return alternative
end


#  ------------------------------------------------------
#  set_edgeval!
#  ------------------------------------------------------

function set_edgeval!(g::ValGraph, s::Integer, d::Integer, key::Integer, value)

    hasedgekey_or_throw(g, key)

    verts = vertices(g)
    edgevals = g.edgevals[key]

    (s in verts && d in verts) || return false

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds edgevals[s][index] = value

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    @inbounds edgevals[d][index] = value

    return true
end

function set_edgeval!(g::ValOutDiGraph, s::Integer, d::Integer, key::Integer, value)

    hasedgekey_or_throw(g, key)

    verts = vertices(g)
    edgevals = g.edgevals[key]

    (s in verts && d in verts) || return false

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds edgevals[s][index] = value

    return true

end

function set_edgeval!(g::ValDiGraph, s::Integer, d::Integer, key::Integer, value)

    hasedgekey_or_throw(g, key)

    verts = vertices(g)
    edgevals = g.edgevals[key]

    (s in verts && d in verts) || return false

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds edgevals[s][index] = value

    redgevals = g.redgevals[key]

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    @inbounds redgevals[d][index] = value

    return true
end

function set_edgeval!(g::ValGraph, s::Integer, d::Integer, ::Colon, values)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_values_for_index!(edgevals, s, index, values)

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    set_values_for_index!(edgevals, d, index, values)

    return true
end

function set_edgeval!(g::ValOutDiGraph, s::Integer, d::Integer, ::Colon, values)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_values_for_index!(edgevals, s, index, values)

    return true
end

function set_edgeval!(g::ValDiGraph, s::Integer, d::Integer, ::Colon, values)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_values_for_index!(g.edgevals, s, index, values)

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    set_values_for_index!(g.redgevals, d, index, values)

    return true
end


#  ------------------------------------------------------
#  get_vertexval
#  ------------------------------------------------------

# TODO maybe implement also for Colon

function get_vertexval(g::ValGraph, v::Integer, key::Integer)

    # TODO verify key, vertex

    return g.vertexvals[key][v]
end

function get_vertexval(g::ValOutDiGraph, v::Integer, key::Integer)

    # TODO verify key, vertex

    return g.vertexvals[key][v]
end

function get_vertexval(g::ValDiGraph, v::Integer, key::Integer)

    # TODO verify key, vertex

    return g.vertexvals[key][v]
end
#
#  ------------------------------------------------------
#  set_vertexval!
#  ------------------------------------------------------

function set_vertexval!(g::ValGraph, v::Integer, key::Integer, value)

    has_vertex(g, v) || return false
    g.vertexvals[key][v] = value
end

function set_vertexval!(g::ValOutDiGraph, v::Integer, key::Integer, value)

    has_vertex(g, v) || return false
    g.vertexvals[key][v] = value
end

function set_vertexval!(g::ValDiGraph, v::Integer, key::Integer, value)

    has_vertex(g, v) || return false
    g.vertexvals[key][v] = value
end


#  ------------------------------------------------------
#  is_directed
#  ------------------------------------------------------

LG.is_directed(::Type{<:ValGraph}) = false
LG.is_directed(::Type{<:ValOutDiGraph}) = true
LG.is_directed(::Type{<:ValDiGraph}) = true

#  ------------------------------------------------------
#  outneighbors
#  ------------------------------------------------------

LG.outneighbors(g::ValGraph, v::Integer) = g.fadjlist[v]
LG.outneighbors(g::ValDiGraph, v::Integer) = g.fadjlist[v]
LG.outneighbors(g::ValOutDiGraph, v::Integer) = g.fadjlist[v]

#  ------------------------------------------------------
#  inneighbors
#  ------------------------------------------------------

LG.inneighbors(g::ValGraph, v::Integer) = outneighbors(g, v)
LG.inneighbors(g::ValDiGraph, v::Integer) = g.badjlist[v]

#  ------------------------------------------------------
#  outedgevals
#  ------------------------------------------------------

outedgevals(g::ValGraph, v::Integer, key::Integer) = g.edgevals[key][v]
outedgevals(g::ValDiGraph, v::Integer, key::Integer) = g.edgevals[key][v]
outedgevals(g::ValOutDiGraph, v::Integer, key::Integer) = g.edgevals[key][v]


#  ------------------------------------------------------
#  inedgevals
#  ------------------------------------------------------

inedgevals(g::ValGraph, v::Integer, key::Integer) = outedgevals(g, v, key)
inedgevals(g::ValDiGraph, v::Integer, key::Integer) = g.redgevals[key][v]


# ====================================================================
# Iterators
# ====================================================================


@inline function Base.iterate(eit::ValEdgeIter{<:ValGraph}, state=(one(eltype(eit.graph)), 1))

    g = eit.graph
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    V = eltype(g)
    n = V(nv(g))
    u, i = state

    @inbounds while u < n
        list_u = fadjlist[u]
        if i > length(list_u)
            u += one(u)
            i = searchsortedfirst(fadjlist[u], u)
            continue
        end
        e = ValEdge(u, list_u[i], values_for_index(edgevals, edgevals_type(g), u, i))
        state = (u, i + 1)
        return e, state
    end

    # i > length(fadjlist[end]) || fadlist[end][i] == n

    @inbounds (n == 0 || i > length(fadjlist[n])) && return nothing

    e = ValEdge(n, n, values_for_index(edgevals, edgevals_type(g), u, i))
    state = (u, i + 1)
    return e, state
end

function Base.iterate(
            iter::ValEdgeIter{<:Union{ValOutDiGraph, ValDiGraph}},
            state=(one(eltype(iter.graph)), 1)
    )

    g = iter.graph
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    V = eltype(g)
    n = V(nv(g))
    u, i = state

    @inbounds while u <= n
        if i > length(fadjlist[u])
            u == n && return nothing

            u += one(u)
            i = 1
            continue
        end
        e = ValDiEdge(u, fadjlist[u][i], values_for_index(edgevals, edgevals_type(g), u, i))
        return e, (u, i + 1)
    end

    return nothing
end


