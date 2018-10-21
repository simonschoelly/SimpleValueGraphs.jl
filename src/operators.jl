
function blockdiag(::Type{SimpleValueGraph{T, U}}, iter::AbstractGraph{<:Integer}...)
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
                add_edge!(resultg, T(u) + Δ, T(v) + Δ, convert(U, weights[u, v]))
            end
        end
        Δ += nv(g)
    end

    return resultg
end


blockdiag(g::SimpleValueGraph{T, U}, iter::AbstractGraph...) = blockdiag(typeof(g), g, iter...)
