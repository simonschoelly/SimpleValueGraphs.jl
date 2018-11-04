#  ======================================================
#  Constructors
#  ======================================================


mutable struct SimpleValueDiGraph{T<:Integer, U} <: AbstractSimpleValueGraph{T, U}
    ne::Integer
    fadjlist::Vector{Vector{T}}
    badjlist::Vector{Vector{T}}
    value_fadjlist::Vector{Vector{U}}
end

SimpleValueDiGraph(nv::Integer) = SimpleValueDiGraph(nv::Integer, default_value_type)

function SimpleValueDiGraph(nv::T, ::Type{U}) where {T<:Integer, U} 
    fadjlist = Vector{Vector{T}}(undef, nv)
    badjlist = Vector{Vector{T}}(undef, nv)
    value_fadjlist = Vector{Vector{U}}(undef, nv)
    for u in Base.OneTo(nv)
        fadjlist[u] = Vector{T}()
        badjlist[u] = Vector{T}()
        value_fadjlist[u] = Vector{U}()
    end
    SimpleValueDiGraph(0, fadjlist, badjlist, value_fadjlist)
end

SimpleValueDiGraph(g::SimpleDiGraph) = SimpleValueDiGraph(g, default_value_type)

function SimpleValueDiGraph(g::SimpleDiGraph{T}, ::Type{U}) where {T, U}
    n = nv(g)
    ne_ = ne(g)
    fadjlist = deepcopy(g.fadjlist)
    badjlist = deepcopy(g.fadjlist)
    value_fadjlist = Vector{Vector{U}}(undef, n)
    for u in Base.OneTo(n)
        len = length(fadjlist[u])
        list = Vector{U}(undef, len)
        for i in Base.OneTo(len) 
            list[i] = default_value(U)
        end
        value_fadjlist[u] = list
    end
    SimpleValueDiGraph(ne_, fadjlist, badjlist, value_fadjlist)
end


# =========================================================
# Interface
# =========================================================

function add_edge!(g::SimpleValueDiGraph{T, U}, s::T, d::T, value::U=default_value(U)) where {T, U}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    @inbounds val_list = g.value_fadjlist[s]
    index = searchsortedfirst(list, d)

    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        val_list[index] = value
        return false
    end

    insert!(list, index, d)
    insert!(val_list, index, value)
    g.ne += 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    return true # edge successfully added
end

add_edge!(g::SimpleValueDiGraph, e::SimpleEdge) =
                add_edge!(g, src(e), dst(e))
add_edge!(g::SimpleValueDiGraph, e::SimpleEdge, u) =
                add_edge!(g, src(e), dst(e), u)
add_edge!(g::SimpleValueDiGraph, e::SimpleValueEdge) =
                add_edge!(g, src(e), dst(e), edgeval(e))

function rem_edge!(g::SimpleValueDiGraph{T, U}, s::T, d::T) where {T, U}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    deleteat!(g.value_fadjlist[s], index)

    g.ne -= 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)

    return true
end


rem_edge!(g::SimpleValueDiGraph, e::SimpleEdge) =
                rem_edge!(g, src(e), dst(e))
rem_edge!(g::SimpleValueDiGraph, e::SimpleValueEdge) =
                rem_edge!(g, src(e), dst(e))


# TODO rem_vertex!, rem_vertices!


function has_edge(g::SimpleValueDiGraph{T, U}, s::T, d::T) where {T, U}
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

function has_edge(g::SimpleValueDiGraph{T, U}, s::T, d::T, value::U) where {T, U}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    @inbounds val_list = g.value_fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds return (index <= length(list) && list[index] == d && val_list[index] == value)
end

has_edge(g::SimpleValueDiGraph, e::SimpleEdge) = has_edge(g, src(e), dst(e))
has_edge(g::SimpleValueDiGraph, e::SimpleEdge, u) = has_edge(g, src(e), dst(e), u)
has_edge(g::SimpleValueDiGraph, e::SimpleValueEdge) = has_edge(g, src(e), dst(e), edgeval(e))

# TODO rest methods for get_value
function get_value(g::SimpleValueDiGraph{T, U}, s::T, d::T, default=Base.zero(U)) where {T, U}
     verts = vertices(g)
    (s in verts && d in verts) || return default # TODO may raise bounds error?
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return g.value_fadjlist[s][index]
    end
    return default
end

# TODO rest methods for set_value!
function set_value!(g::SimpleValueDiGraph{T, U}, s::T, d::T, value::U) where {T, U}
     verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds g.value_fadjlist[s][index] = value

    return true
end


is_directed(::Type{<:SimpleValueDiGraph}) = true
is_directed(g::SimpleValueDiGraph) where {T, U} = true

outneighbors(g::SimpleValueDiGraph{T, U}, v::T) where {T, U} = g.fadjlist[v]
inneighbors(g::SimpleValueDiGraph{T, U}, v::T) where {T, U} = g.badjlist[v]

outedgevals(g::SimpleValueDiGraph{T, U}, v::T) where {T, U} =
    g.value_fadjlist[v]

#= TODO do we want these=
inedgevals(g::SimpleValueDiGraph{T, U}, v::T) where {T, U} =
    outedgevals(g, v)
all_edgevals(g::SimpleValueDiGraph{T, U}, v::T) where {T, U} =
    outedgevals(g, v)
=#



function add_vertex!(g::SimpleValueDiGraph{T, U}) where {T, U}
    (nv(g) + one(T) <= nv(g)) && return false # overflow
    push!(g.fadjlist, T[])
    push!(g.badjlist, T[])
    push!(g.value_fadjlist, U[])
    return true
end

# ====================================================================
# Iterators
# ====================================================================


function iterate(iter::SimpleValueEdgeIter{<:SimpleValueDiGraph}, state=(one(eltype(iter.g)), 1) )
    g = iter.g
    fadjlist = g.fadjlist
    n = nv(g)
    u, i = state

    @inbounds while u <= n
        if i > length(fadjlist[u])
            u == n && return nothing

            u += 1
            i = 1
            continue
        end
        e = SimpleValueEdge(u, fadjlist[u][i], g.value_fadjlist[u][i])
        return e, (u, i + 1)
    end

    return nothing
end

