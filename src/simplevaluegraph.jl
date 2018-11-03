
#  ======================================================
#  Constructors
#  ======================================================

mutable struct SimpleValueGraph{T<:Integer, U} <: AbstractSimpleValueGraph{T, U}
    ne::Int
    fadjlist::Vector{Vector{T}}
    value_fadjlist::Vector{Vector{U}}
end


function SimpleValueGraph(nv::T, ::Type{U}) where {T<:Integer, U} 
    fadjlist = Vector{Vector{T}}(undef, nv)
    value_fadjlist = Vector{Vector{U}}(undef, nv)
    for u in Base.OneTo(nv)
        fadjlist[u] = Vector{T}()
        value_fadjlist[u] = Vector{U}()
    end
    SimpleValueGraph(0, fadjlist, value_fadjlist)
end

SimpleValueGraph(nv::Integer) = SimpleValueGraph(nv::Integer, default_value_type)
SimpleValueGraph{T, U}(n::T) where {T, U} = SimpleValueGraph(n, U)

SimpleValueGraph(g::SimpleGraph) = SimpleValueGraph(g, default_value_type)

function SimpleValueGraph(g::SimpleGraph{T}, ::Type{U}) where {T, U}
    n = nv(g)
    ne_ = ne(g)
    fadjlist = deepcopy(g.fadjlist)
    value_fadjlist = Vector{Vector{U}}(undef, n)
    for u in Base.OneTo(n)
        len = length(fadjlist[u])
        list = Vector{U}(undef, len)
        for i in Base.OneTo(len) 
            list[i] = default_value(U)
        end
        value_fadjlist[u] = list
    end
    SimpleValueGraph(ne_, fadjlist, value_fadjlist)
end

# =========================================================
# Interface
# =========================================================

function add_edge!(g::SimpleValueGraph{T, U}, s::T, d::T, value::U=default_value(U)) where {T, U}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    @inbounds val_list = g.value_fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        val_list[index] = value
        index = searchsortedfirst(g.fadjlist[d], s)
        g.value_fadjlist[d][index] = value
        return false
    end

    insert!(list, index, d)
    insert!(val_list, index, value)
    g.ne += 1

    s == d && return true # selfloop

    @inbounds list = g.fadjlist[d]
    @inbounds val_list = g.value_fadjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    insert!(val_list, index, value)
    return true # edge successfully added
end

add_edge!(g::SimpleValueGraph, e::SimpleEdge) =
                add_edge!(g, src(e), dst(e))
add_edge!(g::SimpleValueGraph, e::SimpleEdge, u) =
                add_edge!(g, src(e), dst(e), u)
add_edge!(g::SimpleValueGraph, e::SimpleValueEdge) =
                add_edge!(g, src(e), dst(e), edgeval(e))

function rem_edge!(g::SimpleValueGraph{T, U}, s::T, d::T) where {T, U}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    deleteat!(g.value_fadjlist[s], index)

    g.ne -= 1
    s == d && return true # self-loop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    deleteat!(g.value_fadjlist[d], index)

    return true
end

rem_edge!(g::SimpleValueGraph, e::SimpleEdge) =
                rem_edge!(g, src(e), dst(e))
rem_edge!(g::SimpleValueGraph, e::SimpleValueEdge) =
                rem_edge!(g, src(e), dst(e))


# TODO rem_vertex!, rem_vertices!


function has_edge(g::SimpleValueGraph{T, U}, s::T, d::T) where {T, U}
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

function has_edge(g::SimpleValueGraph{T, U}, s::T, d::T, value::U) where {T, U}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    @inbounds val_list = g.value_fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds return (index <= length(list_s) && list_s[index] == d && val_list[index] == value)
end

has_edge(g::SimpleValueGraph, e::SimpleEdge) = has_edge(g, src(e), dst(e))
has_edge(g::SimpleValueGraph, e::SimpleEdge, u) = has_edge(g, src(e), dst(e), u)
has_edge(g::SimpleValueGraph, e::SimpleValueEdge) = has_edge(g, src(e), dst(e), edgeval(e))

# TODO rest methods for get_value
function get_value(g::SimpleValueGraph{T, U}, s::T, d::T, default=Base.zero(U)) where {T, U}
     verts = vertices(g)
    (s in verts && d in verts) || return default # TODO may raise bounds error?
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    @inbounds val_list = g.value_fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return val_list[index]
    end
    return default    
end


is_directed(::Type{<:SimpleValueGraph}) = false
is_directed(g::SimpleValueGraph) where {T, U} = false


outneighbors(g::SimpleValueGraph{T, U}, v::T) where {T, U} = g.fadjlist[v]
inneighbors(g::SimpleValueGraph{T, U}, v::T) where {T, U} = outneighbors(g, v) 

outedgevals(g::SimpleValueGraph{T, U}, v::T) where {T, U} =
    g.value_fadjlist[v]
inedgevals(g::SimpleValueGraph{T, U}, v::T) where {T, U} =
    outedgevals(g, v)
# edgevals(g::SimpleValueGraph{T, U}, v::T) where {T, U} =
    #outedgevals(g, v)
all_edgevals(g::SimpleValueGraph{T, U}, v::T) where {T, U} =
    outedgevals(g, v)



function add_vertex!(g::SimpleValueGraph{T, U}) where {T, U}
    (nv(g) + one(T) <= nv(g)) && return false # overflow
    push!(g.fadjlist, T[])
    push!(g.value_fadjlist, U[])
    return true
end

# ====================================================================
# Iterators
# ====================================================================


function iterate(iter::SimpleValueEdgeIter{<:SimpleValueGraph}, state=(one(eltype(iter.g)), 1) )
    g = iter.g
    fadjlist = g.fadjlist
    n = nv(g)
    u, i = state

    @inbounds while u < n
        if i > length(fadjlist[u])
            u += 1
            i = searchsortedfirst(fadjlist[u], u)
            continue
        end
        e = SimpleValueEdge(u, fadjlist[u][i], g.value_fadjlist[u][i])
        return e, (u, i + 1)
    end
    
    (n == 0 || i > length(fadjlist[n])) && return nothing

    e = SimpleValueEdge(n, n, g.value_fadjlist[n][1])
    return e, (u, i + 1)
end


