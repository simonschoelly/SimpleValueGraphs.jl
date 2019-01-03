#  ======================================================
#  Constructors
#  ======================================================

"""
    SimpleValueDiGraph{V <: Integer, E_VAL, E_VAL_C, RE_VAL_C}

A type representing a directed simple graph with edge values.
The element type `V` specifies the type of the vertex indices and `E_VAL` specifies the
type of the edge values. User should usually not specify `E_VAL_C` and `RE_VAL_C` by themself but rather let a constructor do that.
"""
mutable struct SimpleValueDiGraph{V <: Integer,
                                  E_VAL,
                                  E_VAL_C <: EdgeValContainer{E_VAL},
                                  RE_VAL_C <: Union{Nothing, EdgeValContainer{E_VAL}},
                                 } <: AbstractSimpleValueGraph{V, E_VAL}
    ne::Int
    fadjlist::Adjlist{V}
    badjlist::Adjlist{V}
    edgevals::E_VAL_C
    redgevals::RE_VAL_C
end

const OutValueDiGraph{V, E_VAL} = SimpleValueDiGraph{V, E_VAL, <: EdgeValContainer{E_VAL}, Nothing}
const InOutValueDiGraph{V, E_VAL} = SimpleValueDiGraph{V, E_VAL, E_VAL_C, E_VAL_C} where {E_VAL_C <: EdgeValContainer{E_VAL}}

edgeval_container_type(g::SimpleValueDiGraph{V, E_VAL, E_VAL_C}) where {V, E_VAL, E_VAL_C} = E_VAL_C

"""
    SimpleValueDiGraph{V}(n, E_VAL=$(default_edgeval_type); reverse_edgevals=false)

Construct a `SimpleValueDiGraph` with `n` vertices and 0 edges with edge values of type `E_VAL`.
If `reverse_edgevals` is true, then edge values are also attached to incoming edges, other only
to outgoing edges. If omitted, the element type `V` is the type of `n`.
"""
function SimpleValueDiGraph(n::V,
                            E_VAL::Type=default_edgeval_type;
                            reverse_edgevals::Bool=false
                           ) where {V <: Integer}
    fadjlist = Adjlist{V}(n)
    badjlist = Adjlist{V}(n)
    edgevals = create_edgeval_list(n, E_VAL)
    if !reverse_edgevals
        return OutValueDiGraph{V, E_VAL, typeof(edgevals)}(0,
                                                          fadjlist, badjlist,
                                                          edgevals, nothing)
    end
    redgevals = create_edgeval_list(n, E_VAL)
    return InOutValueDiGraph{V, E_VAL, typeof(edgevals), typeof(redgevals)}(0,
                                                                            fadjlist,
                                                                            badjlist,
                                                                            edgevals,
                                                                            redgevals)
end

SimpleValueDiGraph{V}(n::Integer, E_VAL::Type=default_edgeval_type; args...) where {V} = SimpleValueDiGraph(V(n), E_VAL, args...)
SimpleValueDiGraph{V, E_VAL}(n::Integer, args...) where {V, E_VAL} = SimpleValueDiGraph(V(n), E_VAL, args...)

"""
    SimpleValueDiGraph([edgeval_initializer],
                     g::SimpleDiGraph,
                     E_VAL=$(default_edgeval_type);
                     reverse_edgevals=false)

Construct a `SimpleValueDiGraph` with the same structure as `g`.
The optional argument `edgeval_initializer` takes a
function that assigns to each edge (s, d) an edge value. If it is not given,
then each edge gets the value `default_edgeval(E_VAL)`.
If `reverse_edgevals` is true, then edge values are also attached to incoming edges, other only
to outgoing edges.
"""
function SimpleValueDiGraph(edgeval_initializer::Base.Callable,
                            g::SimpleDiGraph,
                            E_VAL::Type=default_edgeval_type;
                            reverse_edgevals::Bool=false
                            )
    gv = SimpleValueDiGraph(undef, g, E_VAL, reverse_edgevals=reverse_edgevals)

    n = nv(g)
    # TODO there is a more efficient method for this
    for e in edges(g)
        s, d = Tuple(e)
        set_edgeval!(gv, s, d, edgeval_initializer(s, d))
    end

    return gv
end

function SimpleValueDiGraph(g::SimpleDiGraph,
                            E_VAL::Type=default_edgeval_type;
                            reverse_edgevals::Bool=false
                           )
    gv = SimpleValueDiGraph(undef, g, E_VAL, reverse_edgevals=reverse_edgevals)

    n = nv(g)
    # TODO there is a more efficient method for this
    for e in edges(g)
        s, d = Tuple(e)
        set_edgeval!(gv, s, d, default_edgeval(E_VAL))
    end

    return gv
end

"""
    SimpleValueDiGraph(undef, g::SimpleGraph, E_VAL=$(default_edgeval_type); reverse_edgevals=false)

Construct a `SimpleValueDiGraph` with the same structure as `g` with uninitialized edge values of type `E_VAL`.
If `reverse_edgevals` is true, then edge values are also attached to incoming edges, other only
to outgoing edges.
"""
function SimpleValueDiGraph(::UndefInitializer,
                            g::SimpleDiGraph{V},
                            E_VAL::Type=default_edgeval_type;
                            reverse_edgevals::Bool=false) where {V}
    n = nv(g)
    fadjlist = deepcopy_adjlist(g.fadjlist)
    badjlist = deepcopy_adjlist(g.badjlist)
    edgevals = Vector{Vector{E_VAL}}(undef, n)
    for s in OneTo(n)
        edgevals[s] = Vector{E_VAL}(undef, length(fadjlist[s]))
    end
    if !reverse_edgevals
        return OutValueDiGraph{V, E_VAL, typeof(edgevals)}(ne(g),
                                                           fadjlist,
                                                           badjlist,
                                                           edgevals,
                                                           nothing
                                                          )
    end
    redgevals = Vector{Vector{E_VAL}}(undef, n)
    for d in OneTo(n)
        edgevals[s] = Vector{E_VAL}(undef, length(badjlist[d]))
    end
    return InOutValueDiGraph{V, E_VAL, typeof(edgevals)}(ne(g),
                                                         fadjlist,
                                                         badjlist,
                                                         edgevals,
                                                         redgevals
                                                        )

end

function SimpleValueDiGraph(::UndefInitializer,
                            g::SimpleDiGraph{V}, 
                            E_VAL::Type{<:TupleOrNamedTuple};
                            reverse_edgevals::Bool=false) where {V}
    n = nv(g)
    fadjlist = deepcopy_adjlist(g.fadjlist)
    badjlist = deepcopy_adjlist(g.badjlist)
    E_VAL_C = edgevals_container_type(Val(E_VAL))
    edgevals = E_VAL_C( T(undef, n) for T in E_VAL_C.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VAL.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s]))
        end
    end

    if !reverse_edgevals
        return OutValueDiGraph{V, E_VAL, E_VAL_C}(ne(g),
                                                  fadjlist,
                                                  badjlist,
                                                  edgevals,
                                                  nothing
                                                 )
    end
    redgevals = Vector{Vector{E_VAL}}(undef, n)
    redgevals = E_VAL_C( T(undef, n) for T in E_VAL_C.types )
    for d in OneTo(n)
        for (i, T) in enumerate(E_VAL.types)
            edgevals[i][d] = Vector{T}(undef, length(badjlist[d]))
        end
    end

    return InOutValueDiGraph{V, E_VAL, E_VAL_C}(ne(g),
                                                fadjlist,
                                                badjlist,
                                                edgevals,
                                                redgevals
                                               )
end


# =========================================================
# Interface
# =========================================================


function add_edge!(g::SimpleValueDiGraph{V, E_VAL},
                   s::Integer,
                   d::Integer,
                   value=default_edgeval(E_VAL)) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_value_for_index!(g.edgevals, s, index, value)
        return false
    end

    insert!(list, index, d)
    insert_value_for_index!(g.edgevals, s, index, value)
    g.ne += 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    if g isa InOutValueDiGraph
        set_value_for_index!(g.redgevals, d, index, value)
    end
    return true # edge successfully added
end

add_edge!(g::SimpleValueDiGraph, e::SimpleEdge)      = add_edge!(g, src(e), dst(e))
add_edge!(g::SimpleValueDiGraph, e::SimpleEdge, u)   = add_edge!(g, src(e), dst(e), u)
add_edge!(g::SimpleValueDiGraph, e::SimpleValueEdge) = add_edge!(g, src(e), dst(e), val(e))


function rem_edge!(g::SimpleValueDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_value_for_index!(g.edgevals, s, index)

    g.ne -= 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    if g isa InOutValueDiGraph
        delete_value_for_index!(g.redgevals, d, index)
    end

    return true
end

rem_edge!(g::SimpleValueDiGraph, e::SimpleEdge) = rem_edge!(g, src(e), dst(e))
rem_edge!(g::Union{OutValueDiGraph, InOutValueDiGraph}, e::SimpleValueEdge) = rem_edge!(g, src(e), dst(e))


# TODO rem_vertex!, rem_vertices!


function has_edge(g::SimpleValueDiGraph, s::Integer, d::Integer)
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

function has_edge(g::SimpleValueDiGraph, s::Integer, d::Integer, value)
    verts = vertices(g)
    E_VAL = edgeval_type(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds return (index <= length(list) && list[index] == d && value_for_index(g.edgevals, E_VAL, s, index) == value)
end

has_edge(g::SimpleValueDiGraph, e::SimpleEdge)      = has_edge(g, src(e), dst(e))
has_edge(g::SimpleValueDiGraph, e::SimpleEdge, u)   = has_edge(g, src(e), dst(e), u)
has_edge(g::SimpleValueDiGraph, e::SimpleValueEdge) = has_edge(g, src(e), dst(e), val(e))




# TODO could probably be made faster by checking the shorter list if InOutValueDiGraph
function get_edgeval(g::SimpleValueDiGraph, s::Integer, d::Integer, default=nothing)
    verts = vertices(g)
    E_VAL = edgeval_type(g)
    (s in verts && d in verts) || return default
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return value_for_index(g.edgevals, E_VAL, s, index)
    end
    return default
end

get_edgeval(g::SimpleValueDiGraph, e::SimpleEdge, default=nothing) = get_edgeval(g, src(e), dst(e), default)


# TODO could probably be made faster by checking the shorter list if InOutValueDiGraph
function get_edgeval_for_key(g::SimpleValueDiGraph{V, E_VAL, <: TupleOrNamedTuple},
                             s::Integer,
                             d::Integer,
                             key,
                             default=nothing
                            ) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return default
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return value_for_index(g.edgevals, E_VAL, s, index, key)
    end
    return nothing
end

get_edgeval_for_key(g::SimpleValueDiGraph, e::SimpleEdge, key, default=nothing) = get_edgeval(g, src(e), dst(e), key, default)

function set_edgeval!(g::SimpleValueDiGraph, s::Integer, d::Integer, value)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_value_for_index!(g.edgevals, s, index, value)

    if g isa InOutValueDiGraph
        @inbounds list = g.badjlist[d]
        index = searchsortedfirst(list, s)
        set_value_for_index!(g.redgevals, d, index, value)
    end

    return true
end

set_edgeval!(g::SimpleValueDiGraph, e::SimpleEdge, u) = set_edgeval!(g, src(e), dst(e), u)

function set_edgeval_for_key!(g::SimpleValueDiGraph{V, E_VAL, <: TupleOrNamedTuple}, s::Integer, d::Integer, key, value) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    set_value_for_index!(g.edgevals, s, index, key, value)

    if g isa InOutValueDiGraph
        @inbounds list = g.badjlist[d]
        index = searchsortedfirst(list, s)
        set_value_for_index!(g.redgevals, d, index, key, value)
    end

    return true
end

set_edgeval_for_key!(g::SimpleValueDiGraph, e::SimpleEdge, u) = set_edgeval_for_key!(g, src(e), dst(e), u)


is_directed(::Type{<:SimpleValueDiGraph}) = true
is_directed(g::SimpleValueDiGraph) where {T, U} = true


outneighbors(g::SimpleValueDiGraph, v::Integer) = g.fadjlist[v]
inneighbors(g::SimpleValueDiGraph,  v::Integer) = g.badjlist[v]


# TODO implement these with iterators instead of generators
outedgevals(g::SimpleValueDiGraph{V, E_VAL, <: Adjlist}, v::Integer) where {V, E_VAL} =
    g.edgevals[v]

outedgevals(g::SimpleValueDiGraph{V, E_VAL, E_VAL_C}, v::Integer) where {V, E_VAL, E_VAL_C <: TupleOrNamedTuple} =
    EdgevalsIterator{E_VAL, E_VAL_C}(Int(v), outdegree(g, v), g.edgevals)


inedgevals(g::InOutValueDiGraph{V, E_VAL , <: Adjlist}, v::Integer) where {V, E_VAL} = r.redgevals[v]

inedgevals(g::InOutValueDiGraph{V, E_VAL, E_VAL_C}, v::Integer) where {V, E_VAL, E_VAL_C <: TupleOrNamedTuple} =
    EdgevalsIterator{E_VAL, E_VAL_C}(Int(v), indegree(g, v), g.redgevals)



outedgevals_for_key(g::SimpleValueDiGraph{V, E_VAL, <: TupleOrNamedTuple},
                    v::Integer,
                    key) where {V, E_VAL} = g.edgevals[key][v]

inedgevals_for_key(g::InOutValueDiGraph{V, E_VAL, <: TupleOrNamedTuple},
            v::Integer,
            key) where {V, E_VAL} = g.redgevals[key][v]


function add_vertex!(g::InOutValueDiGraph{V}) where {V}
    _, overflow = Base.Checked.add_with_overflow(nv(g), one(V))
    overflow && return false

    E_VAL_C = edgeval_container_type(g)
    E_VAL = edgeval_type(g)

    push!(g.fadjlist, V[])
    push!(g.badjlist, V[])
    if E_VAL_C <: TupleOrNamedTuple
        for (i, T) in enumerate(E_VAL.types)
            push!(g.edgevals[i], T[])
            push!(g.redgevals[i], T[])
        end
    else
        push!(g.edgevals, E_VAL[])
        push!(g.redgevals, E_VAL[])
    end
    return true
end

function add_vertex!(g::OutValueDiGraph{V}) where {V}
    _, overflow = Base.Checked.add_with_overflow(nv(g), one(V))
    overflow && return false

    E_VAL_C = edgeval_container_type(g)
    E_VAL = edgeval_type(g)

    push!(g.fadjlist, V[])
    push!(g.badjlist, V[])
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


function iterate(iter::SimpleValueEdgeIter{<:SimpleValueDiGraph},
                 state=(one(eltype(iter.g)), 1) )
    g = iter.g
    fadjlist = g.fadjlist
    V = eltype(g)
    E_VAL = edgeval_type(g)
    n::V = nv(g)
    u::V, i = state

    @inbounds while u <= n
        if i > length(fadjlist[u])
            u == n && return nothing

            u += 1
            i = 1
            continue
        end
        e = SimpleValueEdge(u, fadjlist[u][i], value_for_index(g.edgevals, E_VAL, u, i))
        return e, (u, i + 1)
    end

    return nothing
end


