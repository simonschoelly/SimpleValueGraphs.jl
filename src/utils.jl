
const Adjlist{T} = Vector{Vector{T}}

function Adjlist{T}(n::Integer) where {T}
    result = Adjlist{T}(undef, n)
    for i in 1:n
        result[i] = Vector{T}()
    end
    return result
end



#=
# TODO binary search with hint
function searchsortedfirst_hint(v::AbstractVector, x, hint::Int)
    lo = 0
    hi = length(v) + 1
    m = hint
    @inbounds while lo < hi -1
        #=
        if v[m] < x
            lo = m
        else
            hi = m
        end
        =#
        is_less = v[m] < x
        lo = ifelse(is_less, m, lo)
        hi = ifelse(is_less, hi, m)
        m = (lo+hi)>>>1
    end
    return hi
end
=#
