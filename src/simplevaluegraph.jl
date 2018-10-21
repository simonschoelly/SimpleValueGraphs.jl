
#  ======================================================
#  Constructors
#  ======================================================

mutable struct SimpleValueGraph{T<:Integer, U} <: AbstractSimpleValueGraph{T, U}
    ne::Integer
    fadjlist::Vector{Vector{T}}
    value_fadjlist::Vector{Vector{U}}
end

SimpleValueGraph(nv::Integer) = SimpleValueGraph(nv::Integer, default_value_type)

function SimpleValueGraph(nv::T, ::Type{U}) where {T<:Integer, U} 
    fadjlist = Vector{Vector{T}}(undef, nv)
    value_fadjlist = Vector{Vector{U}}(undef, nv)
    for u in Base.OneTo(nv)
        fadjlist[u] = Vector{T}()
        value_fadjlist[u] = Vector{U}()
    end
    SimpleValueGraph(0, fadjlist, value_fadjlist)
end

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
            list[i] = default_value(SimpleValueGraph{T, U})
        end
        value_fadjlist[u] = list
    end
    SimpleValueGraph(ne_, fadjlist, value_fadjlist)
end

# =========================================================
# Interface
# =========================================================

function add_edge!(g::SimpleValueGraph{T, U}, s::T, d::T, value::U) where {T, U}
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
                add_edge!(g, src(e), dst(e), default_value(g))
add_edge!(g::SimpleValueGraph, e::SimpleEdge, u) =
                add_edge!(g, src(e), dst(e), u)
add_edge!(g::SimpleValueGraph, e::SimpleValueEdge) =
                add_edge!(g, src(e), dst(e), edgeval(e))

function rem_edge!(g::SimpleValueGraph{T, U}, s::T, d::T) where {T, U}
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

rem_edge!(g::SimpleValueGraph, e::SimpleEdge) =
                rem_edge!(g, src(e), dst(e))
rem_edge!(g::SimpleValueGraph, e::SimpleValueEdge) =
                rem_edge!(g, src(e), dst(e))


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

eltype(::SimpleValueGraph{T, U}) where {T, U} = T
edgetype(::SimpleValueGraph{T, U}) where {T, U} = SimpleValueEdge{T, U}

is_directed(::Type{<:SimpleValueGraph}) = false
is_directed(g::SimpleValueGraph) where {T, U} = false

vertices(g::SimpleValueGraph) = Base.OneTo(nv(g))
has_vertex(g::SimpleValueGraph, v) = v ∈ vertices(g) 

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


edges(g::SimpleValueGraph) = SimpleValueEdgeIter(g)

nv(g::SimpleValueGraph) = length(g.fadjlist)
ne(g::SimpleValueGraph) = g.ne

zero(G::SimpleValueGraph{T}) where {T} = SimpleValueGraph(zero(T)) 

# ====================================================================
# Iterators
# ====================================================================

struct SimpleValueEdgeIter{G} <: AbstractEdgeIter 
    g::G
end

#=
function iterate(iter::SimpleValueEdgeIter)
    T = eltype(iter.g)
    return iterate(iter, (one(T), )
end
=#

length(iter::SimpleValueEdgeIter) = ne(iter.g)
eltype(::Type{SimpleValueEdgeIter{SimpleValueGraph{T, U}}}) where {T, U} = 
        SimpleValueEdge{T, U}

function iterate(iter::SimpleValueEdgeIter, state=(one(eltype(iter.g)), 1) )
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

# =============
# weight matrix
# =====================

struct SimpleValueMatrix{T, U} <: AbstractMatrix{U}
    g::SimpleValueGraph{T, U}
end

weights(g::SimpleValueGraph) = SimpleValueMatrix(g)

function getindex(A::SimpleValueMatrix{T, U}, s::T, d::T) where {T, U}
    return get_value(A.g, s, d)
end

function size(A::SimpleValueMatrix) 
    n = nv(A.g)
    return (n, n)
end

function replace_in_print_matrix(A::SimpleValueMatrix{T, U}, s::T, d::T, str::AbstractString) where {T<:Integer, U}
    has_edge(A.g, s, d) ? str : Base.replace_with_centered_mark(str)
end
