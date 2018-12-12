#  ======================================================
#  Constructors
#  ======================================================

#=
mutable struct SimpleValueDiGraph{V <: Integer, E_VAL, E_VAL_C <: Union{Nothing, EdgeValContainer{E_VAL}}, RE_VAL_C <: Union{Nothing, EdgeValContainer{E_VAL}} } <: AbstractSimpleValueGraph{V, E_VAL}
    ne::Int
    fadjlist::Adjlist{V}
    badjlist::Adjlist{V}
    edgevals::E_VAL_C
    redgevals::RE_VAL_C
end
=#

mutable struct SimpleValueDiGraph{V,
                                  E_VAL,
                                  E_VAL_C <: Union{Nothing, EdgeValContainer{E_VAL}},
                                  RE_VAL_C <: Union{Nothing, EdgeValContainer{E_VAL}},
                                 } <: AbstractSimpleValueGraph{V, E_VAL}
    ne::Int
    fadjlist::Adjlist{V}
    badjlist::Adjlist{V}
    edgevals::E_VAL_C
    redgevals::RE_VAL_C
end

const ConstValueDiGraph{V, E_VAL} = SimpleValueDiGraph{V, E_VAL, Nothing, Nothing}
const OutValueDiGraph{V, E_VAL} = SimpleValueDiGraph{V, E_VAL, <: EdgeValContainer{E_VAL}, Nothing}
const InOutValueDiGraph{V, E_VAL} = SimpleValueDiGraph{V, E_VAL, <: EdgeValContainer{E_VAL}, <: EdgeValContainer{E_VAL}}

function SimpleValueDiGraph(nv::V,
                            E_VAL::Type=default_edgeval_type;
                            const_edgevals::Bool=false,
                            reverse_edgevals::Bool=false
                           ) where {V <: Integer}
    fadjlist = Adjlist{V}(nv)
    badjlist = Adjlist{V}(nv)
    if const_edgevals
        return ConstValueDiGraph(0, fadjlist, badjlist, nothing, nothing)
    end
    edgevals = create_edgeval_list(nv, E_VAL)
    if !reverse_edgevals
        return OutValueDiGraph{V, E_VAL, typeof(edgevals)}(0,
                                                          fadjlist, badjlist,
                                                          edgevals, nothing)
    end
    redgevals = create_edgeval_list(nv, E_VAL)
    return InOutValueDiGraph{V, E_VAL, typeof(edgevals), typeof(redgevals)}(0,
                                                                            fadjlist,
                                                                            badjlist,
                                                                            edgevals,
                                                                            redgevals)
end

SimpleValueDiGraph{V}(nv::Integer, E_VAL::Type=default_edgeval_type; args...) where {V} = SimpleValueDiGraph(V(nv), E_VAL, args...)
SimpleValueDiGraph{V, E_VAL}(nv::Integer, args...) where {V, E_VAL} = SimpleValueDiGraph(V(nv), E_VAL, args...)


# TODO rewrite for tuples and named tuples
# TODO const edgevals & reverse edgevals
function SimpleValueDiGraph(g::SimpleDiGraph{V},
                          E_VAL::Type=default_edgeval_type;
                          const_edgevals::Bool=false,
                          reverse_edgevals::Bool=false,
                          edgeval_initializer = (s, d) -> default_edgeval(E_VAL)) where {V}
    n = nv(g)
    fadjlist = deepcopy_adjlist(g.fadjlist)
    badjlist = deepcopy_adjlist(g.badjlist)
    if const_edgevals
        return ConstValueDiGraph{V, E_VAL}(ne(g), fadjlist, nothing)
    end
    edgevals = Vector{Vector{E_VAL}}(undef, n)
    E_VAL_C = typeof(edgevals)
    for s in Base.OneTo(n)
        edgevals[s] = [edgeval_initializer(V(s), d) for d in fadjlist[s]]
    end
    if !reverse_edgevals
        return OutValueDiGraph{V, E_VAL, E_VAL_C}(ne(g),
                                                  fadjlist,
                                                  badjlist,
                                                  edgevals,
                                                  nothing)
    end

    redgevals = E_VAL_C( T(undef, n) for T in E_VAL_C.types )
    # TODO initialize redgevals

    InOutValueDiGraph{V, E_VAL, E_VAL_C,E_VAL_C}(ne(g),
                                                 fadjlist,
                                                 badjlist,
                                                 edgevals,
                                                 redgevals)
end

# TODO this function has some issues with typesafety
# TODO weights are not symmetric
# TODO const edgevals & reverse edgevals
function SimpleValueDiGraph(g::SimpleDiGraph{V},
                          E_VAL::Type{<:TupleOrNamedTuple};
                          const_edgevals::Bool=false,
                          reverse_edgevals::Bool=false,
                          edgeval_initializer = (s, d) -> default_edgeval(E_VAL)) where {V}
    n = nv(g)
    fadjlist = deepcopy_adjlist(g.fadjlist) # TODO deepcopy seems not be typesave
    badjlist = deepcopy_adjlist(g.fadjlist)
    if const_edgevals
        return ConstValueDiGraph{V, E_VAL}(ne(g), fadjlist, nothing)
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
    if !reverse_edgevals
        return OutValueDiGraph{V, E_VAL, E_VAL_C}(ne(g),
                                                  fadjlist,
                                                  badjlist,
                                                  edgevals,
                                                  nothing)
    end

    redgevals = E_VAL_C( T(undef, n) for T in E_VAL_C.types )
    # TODO initialize redgevals

    return InOutValueDiGraph{V, E_VAL, E_VAL_C, E_VAL_C}(ne(g),
                                                        fadjlist,
                                                        badjlist,
                                                        edgevals,
                                                        redgevals)
end


# =========================================================
# Interface
# =========================================================


function add_edge!(g::InOutValueDiGraph{V, E_VAL},
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
    set_value_for_index!(g.redgevals, d, index, value)
    return true # edge successfully added
end

function add_edge!(g::OutValueDiGraph{V, E_VAL},
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
    return true # edge successfully added
end

function add_edge!(g::ConstValueDiGraph,
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
    insert_value_for_index!(g.edgevals, s, index, value)
    g.ne += 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    return true # edge successfully added
end


add_edge!(g::SimpleValueDiGraph, e::SimpleEdge)      = add_edge!(g, src(e), dst(e))
add_edge!(g::Union{OutValueDiGraph, InOutValueDiGraph}, e::SimpleEdge, u)   = add_edge!(g, src(e), dst(e), u)
add_edge!(g::Union{OutValueDiGraph, InOutValueDiGraph}, e::SimpleValueEdge) = add_edge!(g, src(e), dst(e), val(e))



function rem_edge!(g::InOutValueDiGraph, s::Integer, d::Integer)
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
    delete_value_for_index!(g.redgevals, d, index)

    return true
end

function rem_edge!(g::OutValueDiGraph, s::Integer, d::Integer)
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

function rem_edge!(g::ConstValueDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)

    g.ne -= 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)

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




# TODO could probably be made faster by checking the shorter list
function get_edgeval(g::InOutValueDiGraph, s::Integer, d::Integer)
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

# TODO rest methods for get_value
# TODO lots of duplicated code
function get_edgeval(g::OutValueDiGraph, s::Integer, d::Integer)
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

# TODO could probably be made faster by checking the shorter list
function get_edgeval(g::InOutValueDiGraph{V, <: TupleOrNamedTuple}, s::Integer, d::Integer, key) where {V <: Integer}
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

function get_edgeval(g::OutValueDiGraph{V, <: TupleOrNamedTuple}, s::Integer, d::Integer, key) where {V <: Integer}
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

function get_edgeval(g::ConstValueDiGraph{V, E_VAL}, s::Integer, d::Integer) where {V, E_VAL}
    if has_edge(g, s, d)
        return default_edgeval(E_VAL)
    end
    return nothing
end

function get_edgeval(g::ConstValueDiGraph{V, E_VAL}, s::Integer, d::Integer, key) where {V, E_VAL}
    if has_edge(g, s, d)
        return default_edgeval(E_VAL)[key]
    end
    return nothing
end


get_edgeval!(g::SimpleValueDiGraph, e::SimpleEdge)   = get_edgeval(g, src(e), dst(e))
get_edgeval!(g::SimpleValueDiGraph, e::SimpleEdge, key)   = get_edgeval(g, src(e), dst(e), key)

function set_edgeval!(g::OutValueDiGraph, s::Integer, d::Integer, value)
    verts = vertices(g)
    E_VAL = edgeval_type(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    set_value_for_index!(g.edgevals, s, index, value)

    return true
end

function set_edgeval!(g::OutValueDiGraph{V, <: TupleOrNamedTuple}, s::Integer, d::Integer, key, value) where {V}
     verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    set_value_for_index!(g.edgevals, s, index, key, value)

    return true
end

function set_edgeval!(g::InOutValueDiGraph, s::Integer, d::Integer, value)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_value_for_index!(g.edgevals, s, index, value)

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    set_value_for_index!(g.redgevals, d, index, value)

    return true
end

# TODO create generated methods for NamedTuple (and also Tuple?)
function set_edgeval!(g::InOutValueDiGraph{V, <: TupleOrNamedTuple}, s::Integer, d::Integer, key, value) where {V}
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    set_value_for_index!(g.edgevals, s, index, key, value)

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    set_value_for_index!(g.redgevals, d, index, key, value)

    return true
end

set_edgeval!(g::Union{InOutValueDiGraph, OutValueDiGraph}, e::SimpleEdge, u)   = set_value!(g, src(e), dst(e), u)
set_edgeval!(g::Union{InOutValueDiGraph, OutValueDiGraph}, e::SimpleValueEdge) = set_value!(g, src(e), dst(e), edgeval(e))



is_directed(::Type{<:SimpleValueDiGraph}) = true
is_directed(g::SimpleValueDiGraph) where {T, U} = true

outneighbors(g::SimpleValueDiGraph, v::Integer) = g.fadjlist[v]
inneighbors(g::SimpleValueDiGraph,  v::Integer) = g.badjlist[v]
# TODO neightbors, all_neighbors

# TODO implement these with iterators instead of generators
outedgevals(g::Union{InOutValueDiGraph{V, E_VAL, <: Adjlist},
                     OutValueDiGraph{V, E_VAL, <: Adjlist}}, v::Integer) where {V, E_VAL} =
    g.edgevals[v]
outedegevals(g::ConstValueDiGraph{V, E_VAL}, v::Integer) where {V, E_VAL} = Base.Iterators.repeated(default_edgeval(E_VAL), length(g.fadjlist[v]))


inedgevals(g::InOutValueDiGraph{V, E_VAL , <: Adjlist}, v::Integer) where {V, E_VAL} = r.redgevals[v]
inedegevals(g::ConstValueDiGraph{V, E_VAL}, v::Integer) where {V, E_VAL} = Base.Iterators.repeated(default_edgeval(E_VAL), length(g.fadjlist[v]))
#TODO all_edgevals

# TODO implement these with iterators instead of generators
outedgevals(g::Union{InOutValueDiGraph{V, E_VAL, <: Tuple},
                     OutValueDiGraph{V, E_VAL, <: Tuple}}, v::Integer) where {V, E_VAL} =
    ( Tuple( adjlist[v][i] for adjlist in g.edgevals ) for i in OneTo(length(g.fadjlist[v])) )
outedgevals(g::Union{InOutValueDiGraph{V, E_VAL, T},
                     OutValueDiGraph{V, E_VAL, T}}, v::Integer) where {V, E_VAL, T <: NamedTuple} =
    ( NamedTuple{Tuple(T.names)}( adjlist[v][i] for adjlist in g.edgevals ) for i in OneTo(length(g.fadjlist[v])) )

inedgevals(g::InOutValueDiGraph{V, E_VAL, <: Tuple}, v::Integer) where {V, E_VAL} =
    ( Tuple( adjlist[v][i] for adjlist in g.redgevals ) for i in OneTo(length(g.badjlist[v])) )
inedgevals(g::InOutValueDiGraph{V, E_VAL, T}, v::Integer) where {V, E_VAL, T <: NamedTuple} =
    ( NamedTuple{Tuple(T.names)}( adjlist[v][i] for adjlist in g.redgevals ) for i in OneTo(length(g.badjlist[v])) )


outedgevals(g::Union{InOutValueDiGraph{V, E_VAL, <: TupleOrNamedTuple},
                    OutValueDiGraph{V, E_VAL, <: TupleOrNamedTuple}},
           v::Integer, key) where {V, E_VAL} = g.edgevals[key][v]
outedegevals(g::ConstValueDiGraph{V, E_VAL}, v::Integer, key) where {V, E_VAL} = Base.Iterators.repeated(default_edgeval(E_VAL)[key], length(g.fadjlist[v]))

inedgevals(g::InOutValueDiGraph{V, E_VAL, <: TupleOrNamedTuple},
            v::Integer,
            key) where {V, E_VAL} = g.redgevals[key][v]
inedegevals(g::ConstValueDiGraph{V, E_VAL}, v::Integer, key) where {V, E_VAL} = Base.Iterators.repeated(default_edgeval(E_VAL)[key], length(g.badjlist[v]))

# TODO maybe add a sizehint kwarg
function add_vertex!(g::InOutValueDiGraph{V, E_VAL_C, E_VAL_C}) where {V, E_VAL, E_VAL_C}
    # TODO There are overflow checks in Julia Base, use these
    (nv(g) + one(V) <= nv(g)) && return false # overflow
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

# TODO maybe add a sizehint kwarg
function add_vertex!(g::OutValueDiGraph{V, E_VAL, E_VAL_C}) where {V, E_VAL, E_VAL_C}
    # TODO There are overflow checks in Julia Base, use these
    (nv(g) + one(V) <= nv(g)) && return false # overflow
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

# TODO maybe add a sizehint kwarg
function add_vertex!(g::ConstValueDiGraph{V}) where {V}
    # TODO There are overflow checks in Julia Base, use these
    (nv(g) + one(V) <= nv(g)) && return false # overflow
    push!(g.fadjlist, V[])
    push!(g.badjlist, V[])
    return true
end


# ====================================================================
# Iterators
# ====================================================================


function iterate(iter::SimpleValueEdgeIter{<:Union{InOutValueDiGraph, OutValueDiGraph}},
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

function iterate(iter::SimpleValueEdgeIter{<:ConstValueDiGraph},
                 state=(one(eltype(iter.g)), 1) )
    g = iter.g
    fadjlist = g.fadjlist
    V = eltype(g)
    n::V = nv(g)
    u::V, i = state

    @inbounds while u <= n
        if i > length(fadjlist[u])
            u == n && return nothing

            u += 1
            i = 1
            continue
        end
        e = SimpleValueEdge(u, fadjlist[u][i])
        return e, (u, i + 1)
    end

    return nothing
end
