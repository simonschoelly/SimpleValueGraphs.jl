
# TODO currently does not work

abstract type KeyView{V, E_VAL, G <: AbstractValueGraph{V}} <: AbstractValueGraph{V, E_VAL} end 

# TODO maybe also add adjlist to struct
struct ValueGraphKeyView{V, E_VAL, G <: ValueGraph{V}} <: KeyView{V, E_VAL, G}
    edgevals::Adjlist{E_VAL}
    parent::G # mainly used as reference for ne(g)
end

struct ValueOutDiGraphKeyView{V, E_VAL, G <: ValueOutDiGraph{V}} <: KeyView{V, E_VAL, G}
    edgevals::Adjlist{E_VAL}
    parent::G # mainly used as reference for ne(g)
end

struct ValueDiGraphKeyView{V, E_VAL, G <: ValueDiGraph{V}} <: KeyView{V, E_VAL, G}
    edgevals::Adjlist{E_VAL}
    redgevals::Adjlist{E_VAL}
    parent::G # mainly used as reference for ne(g)
end


function keyview(g::ValueGraph{V}, key) where {V}
    edgevals = g.edgevals[key]
    E_VAL = eltype(eltype(edgevals))
    return ValueGraphKeyView{V, E_VAL, typeof(g)}(edgevals, g)
end


function keyview(g::ValueOutDiGraph{V}, key) where {V}
    edgevals = g.edgevals[key]
    E_VAL = eltype(eltype(edgevals))
    return ValueOutDiGraphKeyView{V, E_VAL, typeof(g)}(edgevals, g)
end

function keyview(g::ValueDiGraph{V}, key) where {V}
    edgevals = g.edgevals[key]
    redgevals = g.redgevals[key]
    E_VAL = eltype(eltype(edgevals))
    return ValueOutDiGraphKeyView{V, E_VAL, typeof(g)}(edgevals, redgevals, g)
end

#=
    LightGraphs.edges
    LightGraphs.has_edge
=#


for f in (:ne, :nv, :is_directed, :degree, :vertices) 
    @eval $f(kview::KeyView) = $f(kview.parent)
end

for f in (:degree, :inneighbors, :outneighbors, :neighbors)
    @eval $f(kview::KeyView, arg1::Integer) = $f(kview.parent, arg1)
end

is_directed(::Type{<:ValueGraphKeyView}) = false
is_directed(::Type{<:ValueOutDiGraphKeyView}) = true
is_directed(::Type{<:ValueDiGraphKeyView}) = true

eltype(kview::KeyView{V}) where {V} = V

#  ------------------------------------------------------
#  get_edgeval
#  ------------------------------------------------------

function get_edgeval(kview::ValueGraphKeyView, s::Integer, d::Integer, default=nothing)
    verts = vertices(kview)
    (s in verts && d in verts) || return default
    fadjlist = kview.parent.fadjlist
    @inbounds list_s = fadjlist[s]
    @inbounds list_d = fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return kview.edgevals[s][index]
    end
    return default
end

function get_edgeval(kview::ValueOutDiGraphKeyView, s::Integer, d::Integer, default=nothing)
    verts = vertices(kview)
    (s in verts && d in verts) || return default
    @inbounds list_s = kview.parent.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return kview.edgevals[s][index]
    end
    return default
end

# TODO could probably be made faster by checking the shorter list
function get_edgeval(kview::ValueDiGraphKeyView, s::Integer, d::Integer, default=nothing)
    verts = vertices(kview)
    (s in verts && d in verts) || return default
    @inbounds list = kview.parent.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return kview.edgevals[s][index]
    end
    return default
end

get_edgeval(kview::KeyView, e::SimpleEdge, default=nothing) = get_edgeval(kview, src(e), dst(e), default)

#  ------------------------------------------------------
#  set_edgeval!
#  ------------------------------------------------------

function set_edgeval!(kview::ValueGraphKeyView, s::Integer, d::Integer, value)
    verts = vertices(kview)
    (s in verts && d in verts) || return false
    fadjlist = kview.parent.fadjlist
    @inbounds list = fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = kview.edgevals
    @inbounds edgevals[s][index] = value

    @inbounds list = fadjlist[d]
    index = searchsortedfirst(list, s)
    @inbounds edgevals[d][index] = value

    return true
end

function set_edgeval!(kview::ValueOutDiGraphKeyView, s::Integer, d::Integer, value)
    verts = vertices(kview)
    (s in verts && d in verts) || return false
    @inbounds list = kview.parent.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds g.edgevals[s][index] = value

    return true
end

function set_edgeval!(kview::ValueDiGraphKeyView, s::Integer, d::Integer, value)
    verts = vertices(kview)
    (s in verts && d in verts) || return false
    @inbounds list = kview.parent.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds kview.edgevals[s][index] = value

    @inbounds list = kview.parent.badjlist[d]
    index = searchsortedfirst(list, s)
    @inbounds kview.redgevals[s][index] = value

    return true
end

set_edgeval!(kview::KeyView, e::SimpleEdge, u) = set_edgeval!(kview, src(e), dst(e), u)

#  ------------------------------------------------------
#  iterators
#  ------------------------------------------------------

@inline function iterate(eit::ValueEdgeIter{<:ValueGraphKeyView{V}}, state=(one(V), 1) ) where {V}
    kview = eit.g
    fadjlist = kview.parent.fadjlist
    edgevals = kview.edgevals
    n = V(nv(kview))
    u, i = state

    @inbounds while u < n
        list_u = fadjlist[u]
        if i > length(list_u)
            u += one(u)
            i = searchsortedfirst(fadjlist[u], u)
            continue
        end
        e = ValueEdge(u, list_u[i], edgevals[u][i])
        state = (u, i + 1)
        return e, state
    end

    # i > length(fadjlist[end]) || fadlist[end][i] == n

    @inbounds (n == 0 || i > length(fadjlist[n])) && return nothing

    @inbounds e = SimpleEdge(n, n, edgevals[n][end])
    state = (u, i + 1)
    return e, state
end

function iterate(
            eit::ValueEdgeIter{<:Union{ValueOutDiGraphKeyView{V}, ValueDiGraphKeyView{V}} },
            state=(one(V), 1)
    ) where {V}

    kview = eit.g
    fadjlist = kview.parent.fadjlist
    edgevals = kview.edgevals
    n = V(nv(g))
    u, i = state

    @inbounds while u <= n
        if i > length(fadjlist[u])
            u == n && return nothing

            u += one(u)
            i = 1
            continue
        end
        e = ValueEdge(u, fadjlist[u][i], edgevals[u][i])
        return e, (u, i + 1)
    end

    return nothing
end


#TODO
# - has_edge
