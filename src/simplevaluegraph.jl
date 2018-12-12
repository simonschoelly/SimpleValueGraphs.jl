
#  ======================================================
#  Constructors
#  ======================================================

mutable struct SimpleValueGraph{V <: Integer,
                                E_VAL,
                                E_VAL_C <: Union{Nothing, EdgeValContainer{E_VAL}}
                               } <: AbstractSimpleValueGraph{V, E_VAL}
    ne::Int
    fadjlist::Adjlist{V}
    edgevals::E_VAL_C
end

const ConstValueGraph{V, E_VAL} = SimpleValueGraph{V, E_VAL, Nothing}
const InOutValueGraph{V, E_VAL} = SimpleValueGraph{V, E_VAL, <: EdgeValContainer{E_VAL}}


function SimpleValueGraph(nv::V,
                          E_VAL::Type=default_edgeval_type;
                          const_edgevals::Bool = false
                         ) where {V<:Integer}
    fadjlist = Adjlist{V}(nv)
    if const_edgevals
        return ConstValueGraph{V, E_VAL, Nothing}(nv, fadjlist, nothing)
    end
    edgevals = create_edgeval_list(nv, E_VAL)
    return InOutValueGraph{V, E_VAL, typeof(edgevals)}(V(0), fadjlist, edgevals)
end

SimpleValueGraph{V}(nv::Integer, E_VAL::Type=default_edgeval_type; args...) where {V} = SimpleValueGraph(V(nv), E_VAL, args...)
SimpleValueGraph{V, E_VAL}(nv::Integer, args...) where {V, E_VAL} = SimpleValueGraph(V(nv), E_VAL, args...)



# TODO weights are not symmetric
function SimpleValueGraph(g::SimpleGraph{V},
                          E_VAL::Type=default_edgeval_type;
                          const_edgevals::Bool=false,
                          edgeval_initializer = (s, d) -> default_edgeval(E_VAL)) where {V}
    n = nv(g)
    fadjlist = deepcopy_adjlist(g.fadjlist)
    if const_edgevals
        return ConstValueGraph{V, E_VAL}(nv, fadjlist, nothing)
    end
    edgevals = Vector{Vector{E_VAL}}(undef, n)
    for s in Base.OneTo(n)
        edgevals[s] = [edgeval_initializer(V(s), d) for d in fadjlist[s]]
    end
    InOutValueGraph{V, E_VAL, typeof(edgevals)}(ne(g), fadjlist, edgevals)
end



# TODO this function has some issues with typesafety
# TODO weights are not symmetric
# TODO const edgevals
function SimpleValueGraph(g::SimpleGraph{V},
                          E_VAL::Type{<:TupleOrNamedTuple};
                          const_edgevals::Bool=false,
                          edgeval_initializer = (s, d) -> default_edgeval(E_VAL)) where {V}
    n = nv(g)
    fadjlist = deepcopy_adjlist(g.fadjlist)
    if const_edgevals
        return ConstValueGraph{V, E_VAL}(nv, fadjlist, nothing)
    end

    E_VAL_C = edgevals_container_type(Val(E_VAL))
    edgevals = E_VAL_C( T(undef, n) for T in E_VAL_C.types )
    for s in Base.OneTo(n)
        for (i, T) in enumerate(E_VAL.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s])) 
        end
    end
    for s in Base.OneTo(n)
        for (j, d) in enumerate(fadjlist[s])
            w = edgeval_initializer(V(s), d)
            for (i, T) in enumerate(E_VAL.types)
                edgevals[i][s][j] = w[i]
            end
        end
    end
    InOutValueGraph{V, E_VAL, E_VAL_C}(ne(g), fadjlist, edgevals)
end



# =========================================================
# Interface
# =========================================================



function add_edge!(g::InOutValueGraph{V, E_VAL},
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
        # TODO maybe shortcircuit if it is a self-loop
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


function add_edge!(g::ConstValueGraph,
                   s::Integer,
                   d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, return false
        return false
    end

    insert!(list, index, d)
    g.ne += 1

    s == d && return true # selfloop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    return true # edge successfully added
end


add_edge!(g::SimpleValueGraph, e::SimpleEdge)      = add_edge!(g, src(e), dst(e))
add_edge!(g::InOutValueGraph, e::SimpleEdge, u)   = add_edge!(g, src(e), dst(e), u)
add_edge!(g::InOutValueGraph, e::SimpleValueEdge) = add_edge!(g, src(e), dst(e), val(e))



function rem_edge!(g::InOutValueGraph, s::Integer, d::Integer)
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

function rem_edge!(g::ConstValueGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)

    g.ne -= 1
    s == d && return true # self-loop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)

    return true
end

rem_edge!(g::SimpleValueGraph, e::SimpleEdge) = rem_edge!(g, src(e), dst(e))
rem_edge!(g::InOutValueGraph, e::SimpleValueEdge) = rem_edge!(g, src(e), dst(e))


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

# TODO rest methods for get_value
# TODO lots of duplicated code
function get_edgeval(g::InOutValueGraph{V, E_VAL}, s::Integer, d::Integer) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return nothing # TODO may raise bounds error?
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
    return nothing
end

function get_edgeval(g::InOutValueGraph{V, E_VAL}, s::Integer, d::Integer, key) where {V <: Integer, E_VAL <: TupleOrNamedTuple}
    verts = vertices(g)
    (s in verts && d in verts) || return nothing # TODO may raise bounds error?
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
    return nothing
end

function get_edgeval(g::ConstValueGraph{V, E_VAL}, s::Integer, d::Integer) where {V, E_VAL}
    if has_edge(g, s, d)
        return default_edgeval(E_VAL)
    end
    return nothing
end

function get_edgeval(g::ConstValueGraph{V, E_VAL}, s::Integer, d::Integer, key) where {V, E_VAL}
    if has_edge(g, s, d)
        return default_edgeval(E_VAL)[key]
    end
    return nothing
end

get_edgeval!(g::SimpleValueGraph, e::SimpleEdge)   = get_edgeval(g, src(e), dst(e))
get_edgeval!(g::SimpleValueGraph, e::SimpleEdge, key)   = get_edgeval(g, src(e), dst(e), key)

function set_edgeval!(g::InOutValueGraph, s::Integer, d::Integer, value)
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

# TODO create generated methods for NamedTuple (and also Tuple?)
function set_edgeval!(g::InOutValueGraph{V, <: TupleOrNamedTuple}, s::Integer, d::Integer, key, value) where {V}
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

set_edgeval!(g::InOutValueGraph, e::SimpleEdge, u)   = set_value!(g, src(e), dst(e), u)
set_edgeval!(g::InOutValueGraph, e::SimpleValueEdge) = set_value!(g, src(e), dst(e), edgeval(e))


is_directed(::Type{<:SimpleValueGraph}) = false
is_directed(g::SimpleValueGraph)        = false


outneighbors(g::SimpleValueGraph, v::Integer) = g.fadjlist[v]
inneighbors(g::SimpleValueGraph,  v::Integer) = outneighbors(g, v)

outedgevals(g::InOutValueGraph{V, E_VAL, <: Adjlist}, v::Integer) where {V, E_VAL} =
    g.edgevals[v]
outedegevals(g::ConstValueGraph{V, E_VAL}, v::Integer) where {V, E_VAL} = Base.Iterators.repeated(default_edgeval(E_VAL), length(g.fadjlist[v]))

inedgevals(g::SimpleValueGraph, v::Integer) = outedgevals(g, v)
all_edgevals(g::SimpleValueGraph, v::Integer) = outedgevals(g, v)


# TODO implement these with iterators instead of generators
outedgevals(g::InOutValueGraph{V, E_VAL, <: Tuple}, v::Integer) where {V, E_VAL} =
    ( Tuple( adjlist[v][i] for adjlist in g.edgevals ) for i in OneTo(length(g.fadjlist[v])) )
outedgevals(g::InOutValueGraph{V, E_VAL, T}, v::Integer) where {V, E_VAL, T <: NamedTuple} =
    ( NamedTuple{Tuple(T.names)}( adjlist[v][i] for adjlist in g.edgevals ) for i in OneTo(length(g.fadjlist[v])) )


outedgevals(g::InOutValueGraph{V, E_VAL, <: TupleOrNamedTuple}, v::Integer, key) where {V, E_VAL} =
    g.edgevals[key][v]
outedegevals(g::ConstValueGraph{V, E_VAL}, v::Integer, key) where {V, E_VAL} = Base.Iterators.repeated(default_edgeval(E_VAL)[key], length(g.fadjlist[v]))

inedgevals(g::SimpleValueGraph{V, E_VAL}, v::Integer, key) where {V, E_VAL} =
    outedgevals(g, v, key)
all_edgevals(g::SimpleValueGraph{V, E_VAL}, v::Integer, key) where {V, E_VAL} =
    outedgevals(g, v, key)


# TODO maybe add a sizehint kwarg
function add_vertex!(g::InOutValueGraph{V, E_VAL, E_VAL_C}) where {V, E_VAL, E_VAL_C}
    # TODO There are overflow checks in Julia Base, use these
    (nv(g) + one(V) <= nv(g)) && return false # overflow
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

function add_vertex!(g::ConstValueGraph{V}) where {V}
    # TODO There are overflow checks in Julia Base, use these
    (nv(g) + one(V) <= nv(g)) && return false # overflow
    push!(g.fadjlist, V[])
    return true
end


# ====================================================================
# Iterators
# ====================================================================

function iterate(iter::SimpleValueEdgeIter{<:InOutValueGraph}, state=(one(eltype(iter.g)), 1) )
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

function iterate(iter::SimpleValueEdgeIter{<:ConstValueGraph}, state=(one(eltype(iter.g)), 1) )
    g = iter.g
    fadjlist = g.fadjlist
    V = eltype(g)
    n::V = nv(g)
    u::V, i = state

    @inbounds while u < n
        if i > length(fadjlist[u])
            u += V(1)
            i = searchsortedfirst(fadjlist[u], u)
            continue
        end
        e = SimpleEdge(u, fadjlist[u][i])
        return e, (u, i + 1)
    end

    (n == 0 || i > length(fadjlist[n])) && return nothing

    e = SimpleEdge(n, n, default_edgeval(E_VAL))
    return e, (u, i + 1)
end
