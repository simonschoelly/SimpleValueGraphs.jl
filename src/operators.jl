function blockdiag(::Type{SimpleValueGraph{T, U}}, iter::AbstractGraph{<:Integer}...) where {T<:Integer, U}
    n::T = zero(T)
    for g in iter
        n += nv(g)
        # TODO check for overflow
    end

    resultg = SimpleValueGraph(n, U)

    # TODO this is not very efficient
    Δ::T = zero(T)
    for g in iter
        w = weights(g)
        for u in vertices(g)
            for v in neighbors(g, u)
                add_edge!(resultg, T(u) + Δ, T(v) + Δ, convert(U, w[u, v]))
            end
        end
        Δ += nv(g)
    end

    return resultg
end

blockdiag(g::SimpleValueGraph, iter::AbstractGraph...) = blockdiag(typeof(g), g, iter...)

#=
function complement(g::SimpleValueGraph{T, U})
    n = nv(
end
=#

# TODO reverse

# ==== weight related operators =====

# TODO docstring
# TODO better pass a SimpleValueEdge to f
function map_edge_vals!(f::Function, g::SimpleValueGraph)
    T = eltype(g)
    n = nv(g)
    fadjlist = g.fadjlist
    value_fadjlist = g.value_fadjlist
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index = 1
        while index <= len && list_i[index] <= i
            j = list_i[index]
            new_val = f(T(j), T(i), value_fadjlist[i][index])
            value_fadjlist[i][index] = new_val

            index2 = searchsortedfirst(fadjlist[j], i)
            value_fadjlist[j][index2] = new_val

            index += 1
        end
    end
end

function map_edge_vals!(f::Function, g::SimpleValueDiGraph)
    T = eltype(g)
    n = nv(g)
    fadjlist = g.fadjlist
    value_fadjlist = g.value_fadjlist
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index = 1
        while index <= len
            j = list_i[index]
            new_val = f(T(j), T(i), value_fadjlist[i][index])
            value_fadjlist[i][index] = new_val

            index += 1
        end
    end
end

