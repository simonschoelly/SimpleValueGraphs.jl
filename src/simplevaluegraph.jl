
#  ======================================================
#  Constructors
#  ======================================================

"""
    SimpleValueGraph{V <: Integer, E_VAL, E_VAL_C}

A type representing an undirected simple graph with edge values.
The element type `V` specifies the type of the vertex indices and `E_VAL` specifies the
type of the edge values. User should usually not specify `E_VAL_C` by themself but rather let
a constructor do that.
"""
mutable struct SimpleValueGraph{V <: Integer,
                                E_VAL,
                                E_VAL_C <: EdgeValContainer{E_VAL}
                               } <: AbstractSimpleValueGraph{V, E_VAL}
    ne::Int
    fadjlist::Adjlist{V}
    edgevals::E_VAL_C
end

"""
    SimpleValueGraph{V}(n, E_VAL=$(default_edgeval_type))

Construct a `SimpleValueGraph` with `n` vertices and 0 edges with edge values of type `E_VAL`.
If omitted, the element type `V` is the type of `n`.
"""
function SimpleValueGraph(n::V,
                          E_VAL::Type=default_edgeval_type
                         ) where {V<:Integer}
    fadjlist = Adjlist{V}(n)
    edgevals = create_edgeval_list(n, E_VAL)
    return SimpleValueGraph{V, E_VAL, typeof(edgevals)}(V(0), fadjlist, edgevals)
end

SimpleValueGraph{V}(nv::Integer, E_VAL::Type=default_edgeval_type) where {V} = SimpleValueGraph(V(nv), E_VAL)
SimpleValueGraph{V, E_VAL}(nv::Integer) where {V, E_VAL} = SimpleValueGraph(V(nv), E_VAL)


"""
    SimpleValueGraph([edgeval_initializer],
                     g::SimpleGraph,
                     E_VAL=$(default_edgeval_type))

Construct a `SimpleValueGraph` with the same structure as `g`.
The optional argument `edgeval_initializer` takes a
function that assigns to each edge (s, d) an edge value. If it is not given,
then each edge gets the value `default_edgeval(E_VAL)`.
"""
function SimpleValueGraph(edgeval_initializer::Base.Callable,
                          g::SimpleGraph,
                          E_VAL::Type=default_edgeval_type)
    gv = SimpleValueGraph(undef, g, E_VAL)

    n = nv(g)
    # TODO there is a more efficient method for this
    for e in edges(g)
        s, d = Tuple(e)
        set_edgeval!(gv, s, d, edgeval_initializer(s, d))
    end

    return gv
end

function SimpleValueGraph(g::SimpleGraph, E_VAL::Type=default_edgeval_type)
    gv = SimpleValueGraph(undef, g, E_VAL)

    n = nv(g)
    # TODO there is a more efficient method for this
    for e in edges(g)
        s, d = Tuple(e)
        set_edgeval!(gv, s, d, default_edgeval(E_VAL))
    end

    return gv
end

"""
    SimpleValueGraph(undef, g::SimpleGraph, E_VAL=$(default_edgeval_type))

Construct a `SimpleValueGraph` with the same structure as `g` with uninitialized edge values of type `E_VAL`.
"""
function SimpleValueGraph(::UndefInitializer,
                          g::SimpleGraph{V}, 
                          E_VAL::Type=default_edgeval_type) where {V}
    n = nv(g)
    fadjlist = deepcopy_adjlist(g.fadjlist)
    edgevals = Vector{Vector{E_VAL}}(undef, n)
    for s in OneTo(n)
        edgevals[s] = Vector{E_VAL}(undef, length(fadjlist[s]))
    end
    SimpleValueGraph{V, E_VAL, typeof(edgevals)}(ne(g), fadjlist, edgevals)
end

function SimpleValueGraph(::UndefInitializer,
                          g::SimpleGraph{V},
                          E_VAL::Type{<:TupleOrNamedTuple}) where {V}
    n = nv(g)
    fadjlist = deepcopy_adjlist(g.fadjlist)

    E_VAL_C = edgevals_container_type(Val(E_VAL))
    edgevals = E_VAL_C( T(undef, n) for T in E_VAL_C.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VAL.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s])) 
        end
    end
    return SimpleValueGraph{V, E_VAL, E_VAL_C}(ne(g), fadjlist, edgevals)
end


# =========================================================
# Interface
# =========================================================


"""
    add_edge!(g::AbstractSimpleValueGraph{V, E_VAL}, s, d, value=default_edgeval(E_VAL))
    add_edge!(g::AbstractSimpleValueGraph{V, E_VAL}, e::SimpleValueEdge)
    add_edge!(g::AbstractSimpleValueGraph{V, E_VAL}, e::Edge, value=default_edgeval(E_VAL))
Add an edge `e = (s, d, [value])` to a graph `g` and set the edge value.
Return `true` if the edge was added successfully, otherwise return `false`.
Note that if the edge already exists, the function returns `false` but still changes
the edge value.
"""
function add_edge!(g::SimpleValueGraph{V, E_VAL},
                   s::Integer,
                   d::Integer,
                   value=default_edgeval(E_VAL)) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_value_for_index!(edgevals, s, index, value)
        s == d && return false # selfloop
        index = searchsortedfirst(g.fadjlist[d], s)
        set_value_for_index!(edgevals, d, index, value)
        return false
    end

    insert!(list, index, d)
    insert_value_for_index!(edgevals, s, index, value)
    g.ne += 1

    s == d && return true # selfloop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    insert_value_for_index!(edgevals, d, index, value)
    return true # edge successfully added
end


add_edge!(g::SimpleValueGraph, e::SimpleEdge)      = add_edge!(g, src(e), dst(e))
add_edge!(g::SimpleValueGraph, e::SimpleEdge, u)   = add_edge!(g, src(e), dst(e), u)
add_edge!(g::SimpleValueGraph, e::SimpleValueEdge) = add_edge!(g, src(e), dst(e), val(e))


function rem_edge!(g::SimpleValueGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_value_for_index!(edgevals, s, index)

    g.ne -= 1
    s == d && return true # self-loop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    delete_value_for_index!(edgevals, d, index)

    return true
end

rem_edge!(g::SimpleValueGraph, e::SimpleEdge) = rem_edge!(g, src(e), dst(e))
rem_edge!(g::SimpleValueGraph, e::SimpleValueEdge) = rem_edge!(g, src(e), dst(e))


# TODO rem_vertex!, rem_vertices!


function has_edge(g::SimpleValueGraph, s::Integer, d::Integer)
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


"""
    has_edge!(g::AbstractSimpleValueGraph, s, d, value)
    has_edge!(g::AbstractSimpleValueGraph, e::Edge, value)
    has_edge!(g::AbstractSimpleValueGraph, e::SimpleValueEdge)
Return `true` if `g` has an edge from node `s` to `d` and if the edge value of that edge
is equal to `value` (compared with `==`).
"""
function has_edge(g::SimpleValueGraph{V, E_VAL}, s::Integer, d::Integer, value) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds return (index <= length(list_s) && list_s[index] == d && value_for_index(g.edgevals, E_VAL, s, index) == value)
end

has_edge(g::SimpleValueGraph, e::SimpleEdge)      = has_edge(g, src(e), dst(e))
has_edge(g::SimpleValueGraph, e::SimpleEdge, u)   = has_edge(g, src(e), dst(e), u)
has_edge(g::SimpleValueGraph, e::SimpleValueEdge) = has_edge(g, src(e), dst(e), val(e))

"""
    get_edgeval(g::AbstractSimpleValueGraph, s, d, default=nothing)
    get_edgeval(g::AbstractSimpleValueGraph, e, default=nothing)
Return the edge value for the edge `e: s => d` and `default` if that edge does not exist.
"""
function get_edgeval(g::SimpleValueGraph{V, E_VAL}, s::Integer, d::Integer, default=nothing) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return default
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return value_for_index(g.edgevals, E_VAL, s, index)
    end
    return default
end

get_edgeval(g::SimpleValueGraph, e::SimpleEdge, default=nothing) = get_edgeval(g, src(e), dst(e), default)

"""
    get_edgeval_for_key(g::AbstractSimpleValueGraph, s, d, key, default=nothing)
    get_edgeval_for_key(g::AbstractSimpleValueGraph, e, key, default=nothing)
For a graph `g` with edge values of type `Tuple` or `NamedTuple` return the value associated with
the key `key` for the edge `e: s => d`. Return `default` if that edge does not exist.
"""
function get_edgeval_for_key(g::SimpleValueGraph{V, E_VAL, <: TupleOrNamedTuple},
                             s::Integer,
                             d::Integer,
                             key,
                             default=nothing
                            ) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return default
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return value_for_index(g.edgevals, E_VAL, s, index, key)
    end
    return default
end

get_edgeval_for_key(g::SimpleValueGraph, e::SimpleEdge, key, default=nothing) = get_edgeval(g, src(e), dst(e), key, default)


"""
    set_edgeval!(g::AbstractSimpleValueGraph, s, d, value)
    set_edgeval!(g::AbstractSimpleValueGraph, e, value)
Set the value of the edge `e: s -> d` to `value`. Return `true` if such an edge exists and
`false` otherwise.
"""
function set_edgeval!(g::SimpleValueGraph, s::Integer, d::Integer, value)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_value_for_index!(edgevals, s, index, value)

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    set_value_for_index!(edgevals, d, index, value)

    return true
end

set_edgeval!(g::SimpleValueGraph, e::SimpleEdge, u)  = set_edgeval!(g, src(e), dst(e), u)

"""
    set_edgeval_for_key!(g::AbstractSimpleValueGraph, s, d, key, value)
    set_edgeval_for_key!(g::AbstractSimpleValueGraph, e, key, value)

For a graph `g` with edge values of type `Tuple` or `NamedTuple` set the value associated with
the key `key` for the edge `e: s => d`. Return `true` if such an edge exists and `false` otherwise.
"""
function set_edgeval_for_key!(g::SimpleValueGraph{V, E_VAL, <: TupleOrNamedTuple}, s::Integer, d::Integer, key, value) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_value_for_index!(edgevals, s, index, key, value)

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    set_value_for_index!(edgevals, d, index, key, value)

    return true
end

set_edgeval_for_key!(g::SimpleValueGraph, e::SimpleEdge, u) = set_edgeval_for_key!(g, src(e), dst(e), u)


is_directed(::Type{<:SimpleValueGraph}) = false
is_directed(g::SimpleValueGraph)        = false


outneighbors(g::SimpleValueGraph, v::Integer) = g.fadjlist[v]
inneighbors(g::SimpleValueGraph,  v::Integer) = outneighbors(g, v)

"""
    outedgevals(g::AbstractSimpleValueGraph, v)
Return an iterator the edge values of outgoing edges from `v` to its neighbors.
The order of the neighbors is the same as for `outneighbors(g, v)`.
"""
outedgevals(g::SimpleValueGraph{V, E_VAL, <: Adjlist}, v::Integer) where {V, E_VAL} =
    g.edgevals[v]

outedgevals(g::SimpleValueGraph{V, E_VAL, E_VAL_C},
            v::Integer) where {V, E_VAL, E_VAL_C <: TupleOrNamedTuple} = 
    EdgevalsIterator{E_VAL, E_VAL_C}(Int(v), outdegree(g, v), g.edgevals)


"""
    inedgevals(g::SimpleValueGraph, v)
Return an iterator the edge values of incoming edges from `v` to its neighbors.
The order of the neighbors is the same as for `inneighbors(g, v)`.
"""
inedgevals(g::SimpleValueGraph, v::Integer) = outedgevals(g, v)


"""
    outedgevals_for_key(g::SimpleValueGraph, v, key)
Return an iterator the edge value given by `key` of outgoing edges from `v` to its neighbors.
The order of the neighbors is the same as for `outneighbors(g, v)`.
For this, the edge value of `v` must be either of type `Tuple` or `NamedTuple`.
"""
outedgevals_for_key(g::SimpleValueGraph{V, E_VAL, <: TupleOrNamedTuple}, v::Integer, key) where {V, E_VAL} =
    g.edgevals[key][v]


"""
    inedgevals_for_key(g::SimpleValueGraph, v, key)
Return an iterator the edge value given by `key` of incoming edges from `v` to its neighbors.
The order of the neighbors is the same as for `inneighbors(g, v)`.
For this, the edge value of `v` must be either of type `Tuple` or `NamedTuple`.
"""
inedgevals_for_key(g::SimpleValueGraph{V, E_VAL}, v::Integer, key) where {V, E_VAL} =
    outedgevals(g, v, key)


function add_vertex!(g::SimpleValueGraph{V, E_VAL, E_VAL_C}) where {V, E_VAL, E_VAL_C}
    _, overflow = Base.Checked.add_with_overflow(nv(g), one(V))
    overflow && return false

    push!(g.fadjlist, V[])
    if E_VAL_C <: TupleOrNamedTuple
        for (i, T) in enumerate(E_VAL.types)
            push!(g.edgevals[i], T[])
        end
    else
        push!(g.edgevals, E_VAL[])
    end
    return true
end


# ====================================================================
# Iterators
# ====================================================================

function iterate(iter::SimpleValueEdgeIter{<:SimpleValueGraph}, state=(one(eltype(iter.g)), 1) )
    g = iter.g
    fadjlist = g.fadjlist
    V = eltype(g)
    E_VAL = edgeval_type(g)
    n::V = nv(g)
    u::V, i = state

    @inbounds while u < n
        if i > length(fadjlist[u])
            u += V(1)
            i = searchsortedfirst(fadjlist[u], u)
            continue
        end
        e = SimpleValueEdge(u, fadjlist[u][i], value_for_index(g.edgevals, E_VAL, u, i))
        return e, (u, i + 1)
    end
    
    (n == 0 || i > length(fadjlist[n])) && return nothing

    e = SimpleValueEdge(n, n, value_for_index(g.edgevals, E_VAL, n, 1))
    return e, (u, i + 1)
end


