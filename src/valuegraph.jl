

# ======================================================
# Structures
# ======================================================


"""
    ValGraph{V <: Integer, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C} <: AbstractValGraph

A type representing an undirected simple graph with vertex, edge and graph values.

# Parameters
- `V`: The type of the vertex indices. Should be a concrete subtype of `Integer`.
- `V_VALS`: The type of the vertex values, either a `Tuple` or `NamedTuple`.
- `E_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
- `G_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
- `V_VALS_C`: Internal storage parameter, is derived from `V_VALS`
- `E_VALS_C`: Internal storage parameter, is derived from `E_VALS`

The internal parameters `V_VALS_C` and `E_VALS_C` are automatically calculated
by the constructors so that they should usually not be manually specified.
"""
mutable struct ValGraph{  V <: Integer,
                            V_VALS <: AbstractTuple,
                            E_VALS <: AbstractTuple,
                            G_VALS <: AbstractTuple,
                            V_VALS_C <: AbstractTuple,
                            E_VALS_C <: AbstractTuple
                        } <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    vertexvals::V_VALS_C
    edgevals::E_VALS_C
    graphvals::G_VALS
end

"""
    ValOutDiGraph{V <: Integer, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C} <: AbstractValGraph

A type representing a directed simple graph with vertex, edge and graph values.

# Parameters
- `V`: The type of the vertex indices. Should be a concrete subtype of `Integer`.
- `V_VALS`: The type of the vertex values, either a `Tuple` or `NamedTuple`.
- `E_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
- `G_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
- `V_VALS_C`: Internal storage parameter, is derived from `V_VALS`
- `E_VALS_C`: Internal storage parameter, is derived from `E_VALS`


The internal parameters `V_VALS_C` and `E_VALS_C` are automatically calculated
by the constructors so that they should usually not be manually specified.

Uses less memory than `ValDiGraph` by only storing outgoing edges.
"""
mutable struct ValOutDiGraph{ V <: Integer,
                                V_VALS <: AbstractTuple,
                                E_VALS <: AbstractTuple,
                                G_VALS <: AbstractTuple,
                                V_VALS_C <: AbstractTuple,
                                E_VALS_C <: AbstractTuple
                            } <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    vertexvals::V_VALS_C
    edgevals::E_VALS_C
    graphvals::G_VALS
end


"""
    ValDiGraph{V <: Integer, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C} <: AbstractValGraph

A type representing a directed simple graph with vertex, edge and graph values.

# Parameters
- `V`: The type of the vertex indices. Should be a concrete subtype of `Integer`.
- `V_VALS`: The type of the vertex values, either a `Tuple` or `NamedTuple`.
- `E_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
- `G_VALS`: The type of the edge values, either a `Tuple` or `NamedTuple`.
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
                                G_VALS <: AbstractTuple,
                                V_VALS_C <: AbstractTuple,
                                E_VALS_C <: AbstractTuple
                           } <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    badjlist::Adjlist{V}
    vertexvals::V_VALS_C
    edgevals::E_VALS_C
    redgevals::E_VALS_C
    graphvals::G_VALS
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

@generated function create_edgevals(n, ::Type{E_VALS}) where {E_VALS <: Tuple}
    args = Expr[]
    for T in fieldtypes(E_VALS)
        push!(args, :(Adjlist{$T}(n)))
    end
    return Expr(:call, :tuple, args...)
end

@generated function create_edgevals(n, ::Type{E_VALS}) where {E_VALS <: NamedTuple}
    args = Expr[]
    for T in fieldtypes(E_VALS)
        push!(args, :(Adjlist{$T}(n)))
    end
    names = fieldnames(E_VALS)
    return Expr(:call, Expr(:curly, :NamedTuple, names), Expr(:call, :tuple, args...))
end

create_vertexvals(n, V_VALS::Type{<:NTuple{0}}, ::Nothing) = ()
create_vertexvals(n, V_VALS::Type{<:NamedNTuple{0}}, ::Nothing) = (;)

@generated function create_vertexvals(n, ::Type{V_VALS}, ::UndefInitializer) where {V_VALS <: Tuple}
    args = Expr[]
    for T in fieldtypes(V_VALS)
        push!(args, :(Vector{$T}(undef, n)))
    end
    return Expr(:call, :tuple, args...)
end

@generated function create_vertexvals(n, ::Type{V_VALS}, ::UndefInitializer) where {V_VALS <: NamedTuple}
    args = Expr[]
    for T in fieldtypes(V_VALS)
        push!(args, :(Vector{$T}(undef, n)))
    end
    names = fieldnames(V_VALS)
    return Expr(:call, Expr(:curly, :NamedTuple, names), Expr(:call, :tuple, args...))
end


function create_vertexvals(n, V_VALS::Type{<:AbstractTuple}, f::Function)
    vertexvals = create_vertexvals(n, V_VALS, undef)
    for v in 1:n
        t = convert_to_tuple(V_VALS, f(v))
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
    ValGraph{V = $default_eltype}(n; vertexval_types=(), edgeval_types=(), vertexval_init=nothing, graphvals=())
    ValGraph{V, V_VALS, E_VALS}(n; vertexval_init=nothing, graphvals=())

Construct a `ValGraph` with `n` vertices, zero edges and graph values `graphvals`.  The
vertex value types are either `V_VALS` or `vertexval_types` and the edge value type are
`edgeval_types`.

If omitted, the element type `V` is $(default_eltype).
"""
function ValGraph{V, V_VALS, E_VALS}(n::Integer; vertexval_init=nothing, graphvals=()) where {V <: Integer, V_VALS <: AbstractTuple, E_VALS <: AbstractTuple}

    fadjlist = Adjlist{V}(n)
    vertexvals = create_vertexvals(n, V_VALS, vertexval_init)
    edgevals = create_edgevals(n, E_VALS)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)
    G_VALS = typeof(graphvals)

    return ValGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(0, fadjlist, vertexvals, edgevals, graphvals)
end

"""
    ValOutDiGraph{V = $default_eltype}(n; vertexval_types=(), edgeval_types=(), vertexval_init=nothing, graphvals=())
    ValOutDiGraph{V, V_VALS, E_VALS}(n; vertexval_init=nothing, graphvals=())

Construct a `ValOutDiGraph` with `n` vertices, zero edges and graph values `graphvals`.  The
vertex value types are either `V_VALS` or `vertexval_types` and the edge value type are
`edgeval_types`.

If omitted, the element type `V` is $(default_eltype).
"""
function ValOutDiGraph{V, V_VALS, E_VALS}(n::Integer; vertexval_init=nothing, graphvals=()) where {V<:Integer, V_VALS, E_VALS}

    fadjlist = Adjlist{V}(n)
    vertexvals = create_vertexvals(n, V_VALS, vertexval_init)
    edgevals = create_edgevals(n, E_VALS)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)
    G_VALS = typeof(graphvals)

    return ValOutDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(0, fadjlist, vertexvals, edgevals, graphvals)
end


"""
    ValDiGraph{V = $default_eltype}(n; vertexval_types=(), edgeval_types=(), vertexval_init=nothing, graphvals=())
    ValDiGraph{V, E_VALS}(n, vertexval_init=nothing; graphvals=())

Construct a `ValDiGraph` with `n` vertices, zero edges and graph values `graphvals`.  The
vertex value types are either `V_VALS` or `vertexval_types` and the edge value type are
`edgeval_types`.

If omitted, the element type `V` is $(default_eltype).
"""
function ValDiGraph{V, V_VALS, E_VALS}(n::Integer; vertexval_init=nothing, graphvals=()) where {V<:Integer, V_VALS, E_VALS}

    fadjlist = Adjlist{V}(n)
    badjlist = Adjlist{V}(n)
    vertexvals = create_vertexvals(n, V_VALS, vertexval_init)
    edgevals = create_edgevals(n, E_VALS)
    redgevals = create_edgevals(n, E_VALS)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)
    G_VALS = typeof(graphvals)

    return ValDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(
                0, fadjlist, badjlist, vertexvals, edgevals, redgevals, graphvals)
end


for G in (:ValGraph, :ValOutDiGraph, :ValDiGraph)

    @eval function $G(n::Integer; vertexval_types::AbstractTypeTuple=(), edgeval_types::AbstractTypeTuple=(), vertexval_init=nothing, graphvals=())

        V_VALS = typetuple_to_type(vertexval_types)
        E_VALS = typetuple_to_type(edgeval_types)
        return $G{default_eltype, V_VALS, E_VALS}(n, vertexval_init=vertexval_init, graphvals=graphvals)
    end

    @eval function $G{V}(n::Integer; vertexval_types::AbstractTypeTuple=(), edgeval_types::AbstractTypeTuple=(), vertexval_init=nothing, graphvals=()) where {V <: Integer}

        V_VALS = typetuple_to_type(vertexval_types)
        E_VALS = typetuple_to_type(edgeval_types)
        return $G{V, V_VALS, E_VALS}(V(n), vertexval_init=vertexval_init, graphvals=graphvals)
    end
end

#  ------------------------------------------------------
#  Constructors from other value graphs
#  ------------------------------------------------------

function ValGraph{V}(g::ValGraph) where {V}

    neg = ne(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    vertexvals = copy_vertexvals(g.vertexvals)
    edgevals = copy_edgevals(g.edgevals)

    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    G_VALS = graphvals_type(g)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(neg, fadjlist, vertexvals, edgevals, g.graphvals)
end

ValGraph(g::ValGraph) = ValGraph{eltype(g)}(g)


function ValDiGraph{V}(g::ValDiGraph) where {V}

    neg = ne(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    badjlist = deepcopy_adjlist(V, g.badjlist)
    vertexvals = copy_vertexvals(g.vertexvals)
    edgevals = copy_edgevals(g.edgevals)
    redgevals= copy_edgevals(g.redgevals)

    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    G_VALS = graphvals_type(g)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(neg, fadjlist, badjlist, vertexvals, edgevals, redgevals, g.graphvals)
end

ValDiGraph(g::ValDiGraph) = ValDiGraph{eltype(g)}(g)

function ValDiGraph{V}(g::ValGraph) where {V}

    neg = ne(g) - num_self_loops(g) + ne(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    badjlist = deepcopy_adjlist(V, g.fadjlist)
    vertexvals = copy_vertexvals(g.vertexvals)
    edgevals = copy_edgevals(g.edgevals)
    redgevals= copy_edgevals(g.edgevals)

    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    G_VALS = graphvals_type(g)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(neg, fadjlist, badjlist, vertexvals, edgevals, redgevals, g.graphvals)
end

ValDiGraph(g::ValGraph) = ValDiGraph{eltype(g)}(g)

# TODO ValOutDiGraph -> ValDiGraph


function ValOutDiGraph{V}(g::ValOutDiGraph) where {V}

    neg = ne(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    vertexvals = copy_vertexvals(g.vertexvals)
    edgevals = copy_edgevals(g.edgevals)

    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    G_VALS = graphvals_type(g)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValOutDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(neg, fadjlist, vertexvals, edgevals, g.graphvals)
end

ValOutDiGraph(g::ValOutDiGraph) = ValOutDiGraph{eltype(g)}(g)

function ValOutDiGraph{V}(g::ValDiGraph) where {V}

    neg = ne(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    vertexvals = copy_vertexvals(g.vertexvals)
    edgevals = copy_edgevals(g.edgevals)

    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    G_VALS = graphvals_type(g)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValOutDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(neg, fadjlist, vertexvals, edgevals, g.graphvals)
end

ValOutDiGraph(g::ValDiGraph) = ValOutDiGraph{eltype(g)}(g)

function ValOutDiGraph{V}(g::ValGraph) where {V}

    neg = ne(g) - num_self_loops(g) + ne(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    vertexvals = copy_vertexvals(g.vertexvals)
    edgevals = copy_edgevals(g.edgevals)

    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    G_VALS = graphvals_type(g)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = typeof(edgevals)

    return ValOutDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(neg, fadjlist, vertexvals, edgevals, g.graphvals)
end

ValOutDiGraph(g::ValGraph) = ValOutDiGraph{eltype(g)}(g)

# =========================================================
# Interface
# =========================================================

#  ------------------------------------------------------
#  nv
#  ------------------------------------------------------

Graphs.nv(g::ValGraph) = eltype(g)(length(g.fadjlist))
Graphs.nv(g::ValOutDiGraph) = eltype(g)(length(g.fadjlist))
Graphs.nv(g::ValDiGraph) = eltype(g)(length(g.fadjlist))

#  ------------------------------------------------------
#  ne
#  ------------------------------------------------------

Graphs.ne(g::ValGraph) = g.ne
Graphs.ne(g::ValDiGraph) = g.ne
Graphs.ne(g::ValOutDiGraph) = g.ne

#  ------------------------------------------------------
#  add_edge!
#  ------------------------------------------------------

function Graphs.add_edge!(g::ValGraph, s::Integer, d::Integer, values)

    E_VALS = edgevals_type(g)
    values = convert_to_tuple(E_VALS, values)
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

function Graphs.add_edge!(g::ValOutDiGraph, s::Integer, d::Integer, values)

    E_VALS = edgevals_type(g)
    values = convert_to_tuple(E_VALS, values)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace values, but return false
        set_values_for_index!(edgevals, s, index, values)
        return false
    end

    insert!(list, index, d)
    insert_values_for_index!(edgevals, s, index, values)
    g.ne += 1
    return true # edge successfully added
end

function Graphs.add_edge!(g::ValDiGraph, s::Integer, d::Integer, values)

    E_VALS = edgevals_type(g)
    values = convert_to_tuple(E_VALS, values)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace values, but return false
        set_values_for_index!(g.edgevals, s, index, values)
        return false
    end

    insert!(list, index, d)
    insert_values_for_index!(g.edgevals, s, index, values)
    g.ne += 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    insert_values_for_index!(g.redgevals, d, index, values)

    return true # edge successfully added
end

#  ------------------------------------------------------
#  rem_edge!
#  ------------------------------------------------------

function Graphs.rem_edge!(g::ValGraph, s::Integer, d::Integer)
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

function Graphs.rem_edge!(g::ValOutDiGraph, s::Integer, d::Integer)
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


function Graphs.rem_edge!(g::ValDiGraph, s::Integer, d::Integer)
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

function Graphs.add_vertex!(g::ValGraph, values)

    V = eltype(g)
    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    values = convert_to_tuple(V_VALS, values)

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

function Graphs.add_vertex!(g::ValOutDiGraph, values)

    V = eltype(g)
    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    values = convert_to_tuple(V_VALS, values)

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

function Graphs.add_vertex!(g::ValDiGraph, values)

    V = eltype(g)
    V_VALS = vertexvals_type(g)
    E_VALS = edgevals_type(g)
    values = convert_to_tuple(V_VALS, values)

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
#  rem_vertex!
#  ------------------------------------------------------

# TODO

#  ------------------------------------------------------
#  has_edge
#  ------------------------------------------------------

function Graphs.has_edge(g::ValGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        d = s
        list_s = list_d
    end
    return Graphs.insorted(d, list_s)
end

function Graphs.has_edge(g::ValOutDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]

    return Graphs.insorted(d, list_s)
end

function Graphs.has_edge(g::ValDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_fadj = g.fadjlist[s]
    @inbounds list_badj = g.badjlist[d]
    if length(list_fadj) > length(list_badj)
        d = s
        list_fadj = list_badj
    end
    return Graphs.insorted(d, list_fadj)
end

#  ------------------------------------------------------
#  get_edgeval
#  ------------------------------------------------------

@inbounds function get_edgeval(g::ValGraph, s::Integer, d::Integer, key::Integer)

    hasedgekey_or_throw(g, key) # TODO might be sufficient to just check index
    return _get_edgeval(g, s, d, g.edgevals[key])
end

@inbounds function get_edgeval(g::ValGraph, s::Integer, d::Integer, key::Symbol)

    hasedgekey_or_throw(g, key)
    return _get_edgeval(g, s, d, g.edgevals[key])
end

function _get_edgeval(g::ValGraph, s::Integer, d::Integer, adjlist::Adjlist)

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
        return adjlist[s][index]
    end
    # TODO more specific error
    error("No such edge")
end


@inline function get_edgeval(g::ValOutDiGraph, s::Integer, d::Integer, key::Integer)

    hasedgekey_or_throw(g, key)
    return _get_edgeval(g, s, d, g.edgevals[key])
end

@inbounds function get_edgeval(g::ValOutDiGraph, s::Integer, d::Integer, key::Symbol)

    hasedgekey_or_throw(g, key)
    return _get_edgeval(g, s, d, g.edgevals[key])
end

function _get_edgeval(g::ValOutDiGraph, s::Integer, d::Integer, adjlist::Adjlist)

    verts = vertices(g)
    (s in verts && d in verts) || error("No such edge")
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return adjlist[s][index]
    end
    error("No such edge")
end

@inline function get_edgeval(g::ValDiGraph, s::Integer, d::Integer, key::Integer)

    hasedgekey_or_throw(g, key)

    return _get_edgeval(g, s, d, g.edgevals[key])
end

@inbounds function get_edgeval(g::ValDiGraph, s::Integer, d::Integer, key::Symbol)

    hasedgekey_or_throw(g, key)
    return _get_edgeval(g, s, d, g.edgevals[key])
end

function _get_edgeval(g::ValDiGraph, s::Integer, d::Integer, adjlist::Adjlist)

    verts = vertices(g)
    (s in verts && d in verts) || error("No such edge")
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return adjlist[s][index]
    end
    error("No such edge")
end

#  ------------------------------------------------------
#  get_edgeval_or
#  ------------------------------------------------------

@inline function get_edgeval_or(g::ValGraph, s::Integer, d::Integer, key::Integer, alternative)

    hasedgekey_or_throw(g, key)
    return _get_edgeval_or(g, s, d, g.edgevals[key], alternative)
end

@inline function get_edgeval_or(g::ValGraph, s::Integer, d::Integer, key::Symbol, alternative)

    hasedgekey_or_throw(g, key)
    return _get_edgeval_or(g, s, d, g.edgevals[key], alternative)
end

function _get_edgeval_or(g::ValGraph, s::Integer, d::Integer, adjlist::Adjlist, alternative)

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
        return adjlist[s][index]
    end
    return alternative
end

@inline function get_edgeval_or(g::ValOutDiGraph, s::Integer, d::Integer, key::Integer, alternative)

    hasedgekey_or_throw(g, key)
    return _get_edgeval_or(g, s, d, g.edgevals[key], alternative)
end

@inline function get_edgeval_or(g::ValOutDiGraph, s::Integer, d::Integer, key::Symbol, alternative)

    hasedgekey_or_throw(g, key)
    return _get_edgeval_or(g, s, d, g.edgevals[key], alternative)
end

function _get_edgeval_or(g::ValOutDiGraph, s::Integer, d::Integer, adjlist::Adjlist, alternative)

    verts = vertices(g)
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return adjlist[s][index]
    end
    return alternative
end

@inline function get_edgeval_or(g::ValDiGraph, s::Integer, d::Integer, key::Integer, alternative)

    hasedgekey_or_throw(g, key)
    return _get_edgeval_or(g, s, d, g.edgevals[key], alternative)
end

@inline function get_edgeval_or(g::ValDiGraph, s::Integer, d::Integer, key::Symbol, alternative)

    hasedgekey_or_throw(g, key)
    return _get_edgeval_or(g, s, d, g.edgevals[key], alternative)
end

function _get_edgeval_or(g::ValDiGraph, s::Integer, d::Integer, adjlist::Adjlist, alternative)

    verts = vertices(g)
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return adjlist[s][index]
    end
    return alternative
end

#  ------------------------------------------------------
#  get_edgeval(g, s, d, :)
#  ------------------------------------------------------

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
#  get_edgeval_or(g, s, d, :)
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

    E_VALS = edgevals_type(g)
    values = convert_to_tuple(E_VALS, values)

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

    E_VALS = edgevals_type(g)
    values = convert_to_tuple(E_VALS, values)

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

    E_VALS = edgevals_type(g)
    values = convert_to_tuple(E_VALS, values)

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

@inline function get_vertexval(g::ValGraph, v::Integer, key::Integer)

    # TODO verify key, vertex
    return _get_vertexval(g, v, g.vertexvals[key])
end

@inline function get_vertexval(g::ValGraph, v::Integer, key::Symbol)

    # TODO verify key, vertex
    return _get_vertexval(g, v, g.vertexvals[key])
end

_get_vertexval(g::ValGraph, v::Integer, list::Vector) = list[v]

@inline function get_vertexval(g::ValOutDiGraph, v::Integer, key::Integer)

    # TODO verify key, vertex
    return _get_vertexval(g, v, g.vertexvals[key])
end

@inline function get_vertexval(g::ValOutDiGraph, v::Integer, key::Symbol)

    # TODO verify key, vertex
    return _get_vertexval(g, v, g.vertexvals[key])
end

_get_vertexval(g::ValOutDiGraph, v::Integer, list::Vector) = list[v]

@inline function get_vertexval(g::ValDiGraph, v::Integer, key::Integer)

    # TODO verify key, vertex
    return _get_vertexval(g, v, g.vertexvals[key])
end

@inline function get_vertexval(g::ValDiGraph, v::Integer, key::Symbol)

    # TODO verify key, vertex
    return _get_vertexval(g, v, g.vertexvals[key])
end

_get_vertexval(g::ValDiGraph, v::Integer, list::Vector) = list[v]


#  ------------------------------------------------------
#  set_vertexval!
#  ------------------------------------------------------

function set_vertexval!(g::ValGraph, v::Integer, key::Integer, value)

    has_vertex(g, v) || return false
    g.vertexvals[key][v] = value

    return true
end

function set_vertexval!(g::ValOutDiGraph, v::Integer, key::Integer, value)

    has_vertex(g, v) || return false
    g.vertexvals[key][v] = value

    return true
end

function set_vertexval!(g::ValDiGraph, v::Integer, key::Integer, value)

    has_vertex(g, v) || return false
    g.vertexvals[key][v] = value

    return true
end


#  ------------------------------------------------------
#  get_graphval
#  ------------------------------------------------------

function get_graphval(g::ValGraph, key::Integer)

    # TODO verify key

    return g.graphvals[key]
end

function get_graphval(g::ValOutDiGraph, key::Integer)

    # TODO verify key

    return g.graphvals[key]
end

function get_graphval(g::ValDiGraph, key::Integer)

    # TODO verify key

    return g.graphvals[key]
end

function get_graphval(g::ValGraph, ::Colon)

    return g.graphvals
end

function get_graphval(g::ValOutDiGraph, ::Colon)

    return g.graphvals
end

function get_graphval(g::ValDiGraph, ::Colon)

    return g.graphvals
end

#  ------------------------------------------------------
#  set_graphval!
#  ------------------------------------------------------

function set_graphval!(g::ValGraph, key::Integer, value)

    g.graphvals = replace_in_tuple(g.graphvals, key, value)
    return true
end

function set_graphval!(g::ValOutDiGraph, key::Integer, value)

    g.graphvals = replace_in_tuple(g.graphvals, key, value)
    return true
end

function set_graphval!(g::ValDiGraph, key::Integer, value)

    g.graphvals = replace_in_tuple(g.graphvals, key, value)
    return true
end

#  ------------------------------------------------------
#  is_directed
#  ------------------------------------------------------

Graphs.is_directed(::Type{<:ValGraph}) = false
Graphs.is_directed(::Type{<:ValOutDiGraph}) = true
Graphs.is_directed(::Type{<:ValDiGraph}) = true

#  ------------------------------------------------------
#  outneighbors
#  ------------------------------------------------------

Graphs.outneighbors(g::ValGraph, v::Integer) = g.fadjlist[v]
Graphs.outneighbors(g::ValDiGraph, v::Integer) = g.fadjlist[v]
Graphs.outneighbors(g::ValOutDiGraph, v::Integer) = g.fadjlist[v]

#  ------------------------------------------------------
#  inneighbors
#  ------------------------------------------------------

Graphs.inneighbors(g::ValGraph, v::Integer) = outneighbors(g, v)
Graphs.inneighbors(g::ValDiGraph, v::Integer) = g.badjlist[v]

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


@inline function Base.iterate(eit::ValEdgeIter{<:ValGraph, key}, state=(one(eltype(eit.graph)), 1)) where {key}

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
        e = if key == nothing
                ValEdge(u, list_u[i], ())
            else
                ValEdge(u, list_u[i], values_for_index(edgevals, edgevals_type(g), u, i))
            end

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
            iter::ValEdgeIter{<:Union{ValOutDiGraph, ValDiGraph}, key},
            state=(one(eltype(iter.graph)), 1)) where {key}

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
        e = if key == nothing
                ValDiEdge(u, fadjlist[u][i], ())
            else
                ValDiEdge(u, fadjlist[u][i], values_for_index(edgevals, edgevals_type(g), u, i))
            end
        return e, (u, i + 1)
    end

    return nothing
end


