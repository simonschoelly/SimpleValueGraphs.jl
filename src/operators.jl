function blockdiag(::Type{<:SimpleValueGraph{V, E_VAL}}, iter::AbstractGraph{<:Integer}...) where {V, E_VAL}
    n::V = V(0)
    for g in iter
        n += nv(g)
        # TODO check for overflow
    end

    resultg = SimpleValueGraph(n, E_VAL)

    # TODO this is not very efficient
    Δ::V = zero(V)
    for g in iter
        w = weights(g)
        for u in vertices(g)
            for v in neighbors(g, u)
                add_edge!(resultg, V(u) + Δ, V(v) + Δ, convert(E_VAL, w[u, v]))
            end
        end
        Δ += nv(g)
    end

    return resultg
end

function blockdiag(::Type{<:SimpleValueDiGraph{V, E_VAL}}, iter::AbstractGraph{<:Integer}...) where {V, E_VAL}
    n::V = V(0)
    for g in iter
        n += nv(g)
        # TODO check for overflow
    end

    resultg = SimpleValueDiGraph(n, E_VAL)

    # TODO this is not very efficient
    Δ::V = zero(V)
    for g in iter
        w = weights(g)
        for u in vertices(g)
            for v in outneighbors(g, u)
                add_edge!(resultg, V(u) + Δ, V(v) + Δ, convert(E_VAL, w[u, v]))
            end
        end
        Δ += nv(g)
    end

    return resultg
end

blockdiag(g::AbstractSimpleValueGraph, iter::AbstractGraph...) = blockdiag(typeof(g), g, iter...)

#=
function complement(g::SimpleValueGraph{T, U})
    n = nv(
end
=#

# TODO reverse

# ==== weight related operators =====

# TODO docstring
# TODO maybe better pass a SimpleValueEdge to f
function map_edgevals!(f::Function, g::SimpleValueGraph)
    V = eltype(g)
    E_VAL = edgeval_type(g)
    n = nv(g)
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index::Int = 1
        while index <= len && list_i[index] <= i
            j = list_i[index]
            new_val = f(V(i), V(j), value_for_index(edgevals, E_VAL, i, index))
            set_value_for_index!(edgevals, V(i), index, new_val)

            index2 = searchsortedfirst(fadjlist[j], i)
            set_value_for_index!(edgevals, V(j), index2, new_val)

            index += 1
        end
    end
end


function map_edgevals!(f::Function, g::SimpleValueGraph{V, E_VAL, <: TupleOrNamedTuple}, key) where {V, E_VAL}
    n = nv(g)
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index::Int = 1
        while index <= len && list_i[index] <= i
            j = list_i[index]
            new_val = f(V(i), V(j), value_for_index(edgevals, E_VAL, i, index, key))
            set_value_for_index!(edgevals, i, index, key, new_val)

            index2 = searchsortedfirst(fadjlist[j], i)
            set_value_for_index!(edgevals, j, index2, key, new_val)

            index += 1
        end
    end
end

function map_edgevals!(f::Function, g::SimpleValueDiGraph)
    V = eltype(g)
    E_VAL = edgeval_type(g)
    n = nv(g)
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index::Int = 1
        while index <= len
            j = list_i[index]
            new_val = f(V(i), V(j), value_for_index(edgevals, E_VAL, i, index))
            set_value_for_index!(edgevals, V(i), index, new_val)

            index += 1
        end
    end
end

function map_edgevals!(f::Function, g::SimpleValueDiGraph{V, E_VAL, <: TupleOrNamedTuple}, key) where {V, E_VAL}
    n = nv(g)
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index::Int = 1
        while index <= len
            j = list_i[index]
            new_val = f(V(i), V(j), value_for_index(edgevals, E_VAL, i, index, key))
            set_value_for_index!(edgevals, i, index, key, new_val)

            index += 1
        end
    end
end
