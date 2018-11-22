
#  ======================================================
#  Constructors
#  ======================================================


const EdgeValContainer{T} = Union{Nothing,
                                  Adjlist{T},
                                  Tuple{Vararg{Adjlist}},
                                  NamedTuple{S, <: Tuple{Vararg{Adjlist}}} where S
                                 }

# const EdgeValContainer{T} = Union{Nothing, Adjlist{T}, Tuple, NamedTuple}

mutable struct SimpleValueGraph{V<:Integer, E_VAL, E_VAL_C <: EdgeValContainer} <: AbstractSimpleValueGraph{V, E_VAL}
    ne::Int
    fadjlist::Adjlist{V}
    edge_vals::E_VAL_C
end

create_edge_val_list(nv, E_VAL::Type) = Adjlist{E_VAL}(nv)
create_edge_val_list(nv, E_VAL::Type{<:Tuple}) = Tuple(Adjlist{T}(nv) for T in E_VAL.parameters)
create_edge_val_list(nv, E_VAL::Type{<:NamedTuple}) = NamedTuple{Tuple(E_VAL.names)}(Adjlist{T}(nv) for T in E_VAL.types)

function SimpleValueGraph(nv::V, E_VAL::Type=default_edge_val_type) where {V<:Integer}
    fadjlist = Adjlist{V}(nv)
    edge_vals = create_edge_val_list(nv, E_VAL)
    return SimpleValueGraph{V, E_VAL, typeof(edge_vals)}(0, fadjlist, edge_vals)
end

SimpleValueGraph{V, E_VAL}(n::Integer) where {V, E_VAL} = SimpleValueGraph(V(n), E_VAL)


# TODO rewrite for tuples and named tuples
function SimpleValueGraph(g::SimpleGraph{V}, E_VAL::Type=default_edge_val_type) where {V}
    n = nv(g)
    fadjlist = deepcopy(g.fadjlist)
    edge_vals = Vector{Vector{E_VAL}}(undef, n)
    for u in Base.OneTo(n)
        len = length(fadjlist[u])
        edge_vals[u] = [default_edge_val(E_VAL) for _ in OneTo(len)]
    end
    SimpleValueGraph{V, E_VAL, typeof(edge_vals)}(ne(g), fadjlist, edge_vals)
end

edge_vals_container_type(::Val{E_VAL}) where {E_VAL <: Type} = Adjlist{E_VAL}

@generated function edge_vals_container_type(::Val{E_VAL}) where {E_VAL <:Tuple}
    R = Tuple{( Adjlist{T} for T in E_VAL.types )...}
    return :($R)
end

@generated function edge_vals_container_type(::Val{E_VAL}) where {E_VAL <:NamedTuple}
    R = NamedTuple{ Tuple(E_VAL.names), Tuple{( Adjlist{T} for T in E_VAL.types )...}}
    return :($R)
end

# TODO this function has some issues with typesafety
function SimpleValueGraph(g::SimpleGraph, E_VAL::Type{<:TupleOrNamedTuple})
    n = nv(g)
    V = eltype(g)
    fadjlist = deepcopy(g.fadjlist) # TODO deepcopy seems not be typesave
    E_VAL_C = edge_vals_container_type(Val(E_VAL))
    edge_vals = E_VAL_C( T(undef, n) for T in E_VAL_C.types )
    for (i, T) in enumerate(E_VAL.types)
        for u in Base.OneTo(n)
            edge_vals[i][u] = fill(default_edge_val(E_VAL.types[i]), length(fadjlist[u]))
        end
    end
    SimpleValueGraph{V, E_VAL, E_VAL_C}(ne(g), fadjlist, edge_vals)
end


# =========================================================
# Interface
# =========================================================

# TODO maybe move somewhere else
function set_value_for_index!(g::SimpleValueGraph{V, E_VAL, <: Adjlist},
                              s::Integer,
                              index::Integer,
                              value) where {V, E_VAL}
    @inbounds g.edge_vals[s][index] = value
    return nothing
end

function set_value_for_index!(g::SimpleValueGraph{V, E_VAL}, s::Integer, index::Integer, value::E_VAL) where {V, E_VAL <: TupleOrNamedTuple}
    @inbounds for i in eachindex(value)
        g.edge_vals[i][s][index] = value[i]
    end
    return nothing
end

function set_value_for_index!(g::SimpleValueGraph{V, <:TupleOrNamedTuple}, s::Integer, index::Integer, key, value) where {V}
    g.edge_vals[key][s][index] = value
    return nothing
end


# TODO maybe move somewhere else
function insert_value_for_index!(g::SimpleValueGraph{V, E_VAL, <: Adjlist},
                                 s::Integer,
                                 index::Integer,
                                 value) where {V, E_VAL}
    @inbounds insert!(g.edge_vals[s], index, value)
    return nothing
end

function insert_value_for_index!(g::SimpleValueGraph{V, E_VAL, <: TupleOrNamedTuple},
                                 s::Integer,
                                 index::Integer,
                                 value::E_VAL) where {V, E_VAL <: TupleOrNamedTuple}
    @inbounds for i in eachindex(value)
        insert!(g.edge_vals[i][s], index, value[i])
    end
    return nothing
end


function add_edge!(g::SimpleValueGraph{V, E_VAL},
                   s::Integer,
                   d::Integer,
                   value=default_edge_val(E_VAL)) where {V, E_VAL}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_value_for_index!(g, s, index, value)
        # TODO maybe shortcircuit if it is a self-loop
        index = searchsortedfirst(g.fadjlist[d], s)
        set_value_for_index!(g, d, index, value)
        return false
    end

    insert!(list, index, d)
    insert_value_for_index!(g, s, index, value)
    g.ne += 1

    s == d && return true # selfloop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    insert_value_for_index!(g, d, index, value)
    return true # edge successfully added
end

add_edge!(g::SimpleValueGraph, e::SimpleEdge)      = add_edge!(g, src(e), dst(e))
add_edge!(g::SimpleValueGraph, e::SimpleEdge, u)   = add_edge!(g, src(e), dst(e), u)
add_edge!(g::SimpleValueGraph, e::SimpleValueEdge) = add_edge!(g, src(e), dst(e), edge_val(e))

# TODO maybe move somewhere else
function delete_value_for_index!(g::SimpleValueGraph{V, E_VAL, <: Adjlist},
                                 s::Integer,
                                 index::Integer) where {V, E_VAL}
    @inbounds deleteat!(g.edge_vals[s], index)
    return nothing
end

function delete_value_for_index!(g::SimpleValueGraph{V, E_VAL},
                                 s::Integer,
                                 index::Integer) where {V, E_VAL <: TupleOrNamedTuple}
    @inbounds for list in g.edge_vals
        deleteat!(list[s], index)
    end
    return nothing
end


function rem_edge!(g::SimpleValueGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_value_for_index!(g, s, index)

    g.ne -= 1
    s == d && return true # self-loop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    delete_value_for_index!(g, d, index)

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

# TODO maybe move this function somewhere else
function value_for_index(g::SimpleValueGraph{V, E_VAL}, s::Integer, index::Integer) where {V, E_VAL}
    @inbounds return g.edge_vals[s][index]
end

function value_for_index(g::SimpleValueGraph{V, E_VAL}, s::Integer, index::Integer) where {V, E_VAL <: TupleOrNamedTuple}
    @inbounds return E_VAL( adjlist[s][index] for adjlist in g.edge_vals )
end

function value_for_index(g::SimpleValueGraph{V, E_VAL}, s::V, index::Integer, key) where {V, E_VAL <: TupleOrNamedTuple}
    adjlist = g.edge_vals[key]
    @inbounds return adjlist[s][index]
end

function has_edge(g::SimpleValueGraph, s::Integer, d::Integer, value)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds return (index <= length(list_s) && list_s[index] == d && value_for_index(g, s, index) == value)
end


has_edge(g::SimpleValueGraph, e::SimpleEdge)      = has_edge(g, src(e), dst(e))
has_edge(g::SimpleValueGraph, e::SimpleEdge, u)   = has_edge(g, src(e), dst(e), u)
has_edge(g::SimpleValueGraph, e::SimpleValueEdge) = has_edge(g, src(e), dst(e), edge_val(e))

# TODO rest methods for get_value
# TODO lots of duplicated code
function get_edgeval(g::SimpleValueGraph{V}, s::Integer, d::Integer) where {V <: Integer}
    verts = vertices(g)
    (s in verts && d in verts) || return default # TODO may raise bounds error?
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return value_for_index(g, s, index)
    end
    return nothing
end

function get_edgeval(g::SimpleValueGraph{V, <:TupleOrNamedTuple}, s::Integer, d::Integer, key) where {V <: Integer}
    verts = vertices(g)
    (s in verts && d in verts) || return default # TODO may raise bounds error?
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return value_for_index(g, s, index, key)
    end
    return nothing
end

function set_edgeval!(g::SimpleValueGraph, s::Integer, d::Integer, value)
     verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    set_value_for_index!(g, s, index, value)

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    set_value_for_index!(g, d, index, value)

    return true
end

# TODO create generatd methods for NamedTuple (and also Tuple?)
function set_edgeval!(g::SimpleValueGraph{V, <: TupleOrNamedTuple}, s::Integer, d::Integer, key, value) where {V}
     verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    set_value_for_index!(g, s, index, key, value)

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    set_value_for_index!(g, d, index, key, value)

    return true
end


# TODO maybe move this function somewhere else
set_value!(g::SimpleValueGraph, e::SimpleEdge, u)   = set_value!(g, src(e), dst(e), u)
set_value!(g::SimpleValueGraph, e::SimpleValueEdge) = set_value!(g, src(e), dst(e), edge_val(e))


is_directed(::Type{<:SimpleValueGraph})       = false
is_directed(g::SimpleValueGraph) where {T, U} = false


outneighbors(g::SimpleValueGraph{T, U}, v::T) where {T, U} = g.fadjlist[v]
inneighbors(g::SimpleValueGraph{T, U}, v::T) where {T, U} = outneighbors(g, v) 

outedgevals(g::SimpleValueGraph{T, U}, v::T) where {T, U} =
    g.edge_vals[v]
inedgevals(g::SimpleValueGraph{T, U}, v::T) where {T, U} =
    outedgevals(g, v)
# edgevals(g::SimpleValueGraph{T, U}, v::T) where {T, U} =
    #outedgevals(g, v)
all_edgevals(g::SimpleValueGraph{T, U}, v::T) where {T, U} =
    outedgevals(g, v)



function add_vertex!(g::SimpleValueGraph{V, E_VAL}) where {V, E_VAL}
    # TODO There are overflow checks in Julia Base, use these
    (nv(g) + one(V) <= nv(g)) && return false # overflow
    push!(g.fadjlist, V[])
    if E_VAL <: TupleOrNamedTuple
        for (i, T) in enumerate(E_VAL.types)
            push!(g.edge_vals[i], T[])
        end
    else
        push!(g.edge_vals, E_VAL[])
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
    n::V = nv(g)
    u::V, i = state

    @inbounds while u < n
        if i > length(fadjlist[u])
            u += V(1)
            i = searchsortedfirst(fadjlist[u], u)
            continue
        end
        e = SimpleValueEdge(u, fadjlist[u][i], value_for_index(g, u, i))
        return e, (u, i + 1)
    end
    
    (n == 0 || i > length(fadjlist[n])) && return nothing

    e = SimpleValueEdge(n, n, value_for_index(g, n, 1))
    return e, (u, i + 1)
end


