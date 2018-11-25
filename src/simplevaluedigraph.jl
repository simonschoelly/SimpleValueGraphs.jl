#  ======================================================
#  Constructors
#  ======================================================


mutable struct SimpleValueDiGraph{V<:Integer, E_VAL, E_VAL_C <: EdgeValContainer, RE_VAL_C <: EdgeValContainer} <: AbstractSimpleValueGraph{V, E_VAL}
    ne::Int
    fadjlist::Adjlist{V}
    badjlist::Adjlist{V}
    edgevals::E_VAL_C
    redgevals::RE_VAL_C
end

function SimpleValueDiGraph(nv::V, E_VAL::Type=default_edgeval_type; reverse_edgevals::Bool=false) where {V <: Integer}
    fadjlist = Adjlist{V}(nv)
    badjlist = Adjlist{V}(nv)
    edgevals = create_edgeval_list(nv, E_VAL)
    redgevals = reverse_edgevals ? create_edgeval_list(nv, E_VAL) : nothing
    return SimpleValueDiGraph{V, E_VAL, typeof(edgevals), typeof(redgevals)}(0, fadjlist, badjlist, edgevals, redgevals)
end

SimpleValueDiGraph{V}(nv::Integer, E_VAL::Type=default_edgeval_type; args...) where {V} = SimpleValueDiGraph(V(nv), E_VAL, args...)
SimpleValueDiGraph{V, E_VAL}(nv::Integer, args...) where {V, E_VAL} = SimpleValueDiGraph(V(nv), E_VAL, args...)



# TODO rewrite for tuples and named tuples
function SimpleValueDiGraph(g::SimpleDiGraph{V},
                          E_VAL::Type=default_edgeval_type,
                          edgeval_initializer = () -> default_edgeval(E_VAL)) where {V}
    n = nv(g)
    fadjlist = deepcopy(g.fadjlist)
    badjlist = deepcopy(g.badjlist)
    edgevals = Vector{Vector{E_VAL}}(undef, n)
    redgevals = nothing # TODO implementation for reverse edge values
    for u in Base.OneTo(n)
        len = length(fadjlist[u])
        edgevals[u] = [edgeval_initializer() for _ in OneTo(len)]
    end
    SimpleValueDiGraph{V, E_VAL, typeof(edgevals), typeof(redgevals)}(ne(g),
                                                                    fadjlist,
                                                                    badjlist,
                                                                    edgevals,
                                                                    redgevals)
end

# TODO this function has some issues with typesafety
# TODO weights are not symmetric
function SimpleValueDiGraph(g::SimpleDiGraph{V},
                          E_VAL::Type{<:TupleOrNamedTuple},
                          edgeval_initializer = () -> default_edgeval(E_VAL)) where {V}
    n = nv(g)
    fadjlist = deepcopy(g.fadjlist) # TODO deepcopy seems not be typesave
    badjlist = deepcopy(g.fadjlist)
    E_VAL_C = edgevals_container_type(Val(E_VAL))
    edgevals = E_VAL_C( T(undef, n) for T in E_VAL_C.types )
    redgevals = nothing # TODO implementation for reverse edge values
    for u in Base.OneTo(n)
        w = edgeval_initializer()
        for (i, T) in enumerate(E_VAL.types)
            len = length(fadjlist[u])
            edgevals[i][u] = [w[i] for _ in OneTo(len)]
        end
    end
    SimpleValueDiGraph{V, E_VAL, typeof(edgevals), typeof(redgevals)}(ne(g),
                                                                      fadjlist,
                                                                      badjlist,
                                                                      edgevals,
                                                                      redgevals)
end


# =========================================================
# Interface
# =========================================================

function add_edge!(g::SimpleValueDiGraph{V, E_VAL},
                   s::Integer,
                   d::Integer,
                   value=default_value(E_VAL)) where {V, E_VAL}
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

    return true
end

rem_edge!(g::SimpleValueDiGraph, e::SimpleEdge) = rem_edge!(g, src(e), dst(e))
rem_edge!(g::SimpleValueDiGraph, e::SimpleValueEdge) = rem_edge!(g, src(e), dst(e))


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

# TODO rest methods for get_value
# TODO lots of duplicated code
function get_edgeval(g::SimpleValueDiGraph, s::Integer, d::Integer)
     verts = vertices(g)
     E_VAL = edgeval_type(g)
    (s in verts && d in verts) || return default # TODO may raise bounds error?
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return value_for_index(g.edgevals, E_VAL, s, index)
    end
    return nothing
end

function get_edgeval(g::SimpleValueDiGraph{V, <: TupleOrNamedTuple}, s::Integer, d::Integer, key) where {V <: Integer}
    verts = vertices(g)
    E_VAL = edgeval_type(g)
    (s in verts && d in verts) || return default # TODO may raise bounds error?
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return value_for_index(g.edgevals, E_VAL, s, index, key)
    end
    return nothing
end

# TODO rest methods for set_value!
function set_edgeval!(g::SimpleValueDiGraph, s::Integer, d::Integer, value)
    verts = vertices(g)
    E_VAL = edgeval_type(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    set_value_for_index!(g.edgevals, s, index, value)

    return true
end

# TODO rest methods for set_value!
function set_edgeval!(g::SimpleValueDiGraph{V, <: TupleOrNamedTuple}, s::Integer, d::Integer, key, value) where {V}
     verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    set_value_for_index!(g.edgevals, s, index, key, value)

    return true
end


is_directed(::Type{<:SimpleValueDiGraph}) = true
is_directed(g::SimpleValueDiGraph) where {T, U} = true

outneighbors(g::SimpleValueDiGraph, v::Integer) = g.fadjlist[v]
inneighbors(g::SimpleValueDiGraph,  v::Integer) = g.badjlist[v]
# TODO neightbors, all_neighbors

# TODO implement these with iterators instead of generators
outedgevals(g::SimpleValueDiGraph{V, E_VAL, <: Adjlist}, v::Integer) where {V, E_VAL} =
    g.edgevals[v]
outedgevals(g::SimpleValueDiGraph{V, E_VAL, <: Tuple}, v::Integer) where {V, E_VAL} =
    ( Tuple( adjlist[v][i] for adjlist in g.edgevals ) for i in OneTo(length(g.fadjlist[v])) )
outedgevals(g::SimpleValueDiGraph{V, E_VAL, T}, v::Integer) where {V, E_VAL, T <: NamedTuple} =
    ( NamedTuple{Tuple(T.names)}( adjlist[v][i] for adjlist in g.edgevals ) for i in OneTo(length(g.fadjlist[v])) )

# TODO inedgevals, all_edgevals



# TODO maybe add a sizehint kwarg
function add_vertex!(g::SimpleValueDiGraph{V, E_VAL}) where {V, E_VAL}
    # TODO There are overflow checks in Julia Base, use these
    (nv(g) + one(V) <= nv(g)) && return false # overflow
    push!(g.fadjlist, V[])
    if E_VAL <: TupleOrNamedTuple
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


function iterate(iter::SimpleValueEdgeIter{<:SimpleValueDiGraph}, state=(one(eltype(iter.g)), 1) )
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
