
using SimpleValueGraphs.AbstractTuples



# TODO we might want to replace this with a proper wrapper around Adjlist
const Adjlist{T} = Vector{Vector{T}}



# ==========

function Adjlist{T}(n::Integer) where {T}
    result = Adjlist{T}(undef, n)
    @inbounds for i in 1:n
        result[i] = T[]
    end
    return result
end

function deepcopy_adjlist(T::Type, adjlist::Adjlist)
    n = length(adjlist)
    result = Vector{Vector{T}}(undef, n)
    @inbounds for i in OneTo(n)
        list = adjlist[i]
        n_list = length(list)
        result_list = Vector{T}(undef, n_list)
        for j in OneTo(n_list)
            # TODO it seems to be wasteful to always convert & deepcopy
            result_list[j] = deepcopy(convert(T, list[j]))
        end
        result[i] = result_list
    end
    return result
end

# TODO do we have a nicer way to specify the type?
function copy_vertexvals(vertexvals::AbstractTuple)

    return map(copy, vertexvals)
end

# TODO do we have a nicer way to specify the type?
function copy_edgevals(edgevals::AbstractTuple)

    return map(vv -> map(v -> copy(v), vv), edgevals)
end

function reverse_adjlist(adjlist::Adjlist{T}) where {T <: Integer}

    n = length(adjlist)
    result = Vector{Vector{T}}(undef, n)

    # calculate the lengths of the resulting vectors, so that
    # we can allocate the right amount of space from the beginning
    lengths = zeros(T, n)
    @inbounds for i ∈ OneTo(n)
        for v ∈ adjlist[i]
            lengths[v] += one(T)
        end
    end

    @inbounds for i ∈ OneTo(n)
        result[i] = Vector(undef, lengths[i])
    end

    insert_after = fill!(lengths, zero(T)) # reuse space
    @inbounds for i ∈ OneTo(n)
        for v ∈ adjlist[i]
            index = (insert_after[v] += one(T))
            result[v][index] = i
        end
    end

    return result
end


# TODO check if still correct
@generated function edgevals_container_type(::Val{E_VALS}) where {E_VALS <: AbstractTuple}
    R = Tuple{( Adjlist{T} for T in E_VALS.types )...}
    return :($R)
end

@generated function set_values_for_index!(edgevals::AbstractTuple, s::Integer, index::Integer, values::T) where {T <: AbstractTuple}
    len = length(T.types)
    exprs = Expr[]
    for i in OneTo(len)
        e = :(@inbounds edgevals[$i][s][index] = values[$i])
        push!(exprs, e)
    end
    return Expr(:block, exprs...)
end

@generated function insert_values_for_index!(tup_adjlist::AbstractTuple,
                                 s::Integer,
                                 index::Integer,
                                 values::T) where {T <: AbstractTuple}
    len = length(T.types)
    exprs = Expr[]
    for i in OneTo(len)
        e = :(@inbounds insert!(tup_adjlist[$i][s], index, values[$i]))
        push!(exprs, e)
    end
    return Expr(:block, exprs...)
end

function delete_values_for_index!(tup_adjlist::AbstractTuple,
                                 s::Integer,
                                 index::Integer)
    @inbounds for adjlist in tup_adjlist
        deleteat!(adjlist[s], index)
    end
end

# TODO E_VAL could probably be extracted without being explicitly passed to the function
function values_for_index(tup_adjlist::AbstractTuple, E_VAL::Type, s::Integer, index::Integer)
    @inbounds return E_VAL( adjlist[s][index] for adjlist in tup_adjlist )
end



