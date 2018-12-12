
const Adjlist{T} = Vector{Vector{T}}

function Adjlist{T}(n::Integer) where {T}
    result = Adjlist{T}(undef, n)
    @inbounds for i in 1:n
        result[i] = T[]
    end
    return result
end

function deepcopy_adjlist(adjlist::Adjlist{T}) where {T}
    n = length(adjlist)
    result = Vector{Vector{T}}(undef, n)
    @inbounds for i in OneTo(n)
        list = adjlist[i]
        n_list = length(list)
        result_list = Vector{T}(undef, n_list)
        for j in OneTo(n_list)
            result_list[j] = deepcopy(list[j])
        end
        result[i] = result_list
    end
    return result
end


const EdgeValContainer{T} = Union{Adjlist{T},
                                  Tuple{Vararg{Adjlist}},
                                  NamedTuple{S, <: Tuple{Vararg{Adjlist}}} where S
                                 }


create_edgeval_list(nv, E_VAL::Type{Nothing}) = nothing
create_edgeval_list(nv, E_VAL::Type) = Adjlist{E_VAL}(nv)
create_edgeval_list(nv, E_VAL::Type{<:Tuple}) = Tuple(Adjlist{T}(nv) for T in E_VAL.parameters)
create_edgeval_list(nv, E_VAL::Type{<:NamedTuple}) = NamedTuple{Tuple(E_VAL.names)}(Adjlist{T}(nv) for T in E_VAL.types)

edgevals_container_type(::Val{Nothing}) where {E_VAL <: Type} = Adjlist{Nothing}
edgevals_container_type(::Val{E_VAL}) where {E_VAL <: Type} = Adjlist{E_VAL}

@generated function edgevals_container_type(::Val{E_VAL}) where {E_VAL <:Tuple}
    R = Tuple{( Adjlist{T} for T in E_VAL.types )...}
    return :($R)
end

@generated function edgevals_container_type(::Val{E_VAL}) where {E_VAL <:NamedTuple}
    R = NamedTuple{ Tuple(E_VAL.names), Tuple{( Adjlist{T} for T in E_VAL.types )...}}
    return :($R)
end

# TODO maybe move somewhere else
function set_value_for_index!(adjlist::Adjlist,
                              s::Integer,
                              index::Integer,
                              value)
    @inbounds adjlist[s][index] = value
    return nothing
end


@generated function set_value_for_index!(tup_adjlist::TupleOrNamedTuple, s::Integer, index::Integer, value::T) where {T <: TupleOrNamedTuple}
    len = length(T.types)
    exprs = Expr[]
    for i in OneTo(len)
        e = :(@inbounds tup_adjlist[$i][s][index] = value[$i])
        push!(exprs, e)
    end
    return Expr(:block, exprs...)
end

#= TODO remove
function set_value_for_index!(tup_adjlist::TupleOrNamedTuple, s::Integer, index::Integer, value::TupleOrNamedTuple)
    @inbounds for i in eachindex(value)
        tup_adjlist[i][s][index] = value[i]
    end
    return nothing
end
=#

function set_value_for_index!(tup_adjlist::TupleOrNamedTuple, s::Integer, index::Integer, key, value)
    @inbounds tup_adjlist[key][s][index] = value
    return nothing
end


function insert_value_for_index!(adjlist::Adjlist,
                                 s::Integer,
                                 index::Integer,
                                 value)
    @inbounds insert!(adjlist[s], index, value)
    return nothing
end

@generated function insert_value_for_index!(tup_adjlist::TupleOrNamedTuple,
                                 s::Integer,
                                 index::Integer,
                                 value::T) where {T <: TupleOrNamedTuple}
    len = length(T.types)
    exprs = Expr[]
    for i in OneTo(len)
        e = :(@inbounds insert!(tup_adjlist[$i][s], index, value[$i]))
        push!(exprs, e)
    end
    return Expr(:block, exprs...)
end

#= TODO remove
function insert_value_for_index!(tup_adjlist::TupleOrNamedTuple,
                                 s::Integer,
                                 index::Integer,
                                 value)
    @inbounds for i in eachindex(value)
        insert!(tup_adjlist[i][s], index, value[i])
    end
    return nothing
end
=#

function delete_value_for_index!(adjlist::Adjlist,
                                 s::Integer,
                                 index::Integer)
    @inbounds deleteat!(adjlist[s], index)
    return nothing
end

function delete_value_for_index!(tup_adjlist::TupleOrNamedTuple,
                                 s::Integer,
                                 index::Integer)
    @inbounds for adjlist in tup_adjlist
        deleteat!(adjlist[s], index)
    end
    return nothing
end

function value_for_index(adjlist::Adjlist, E_VAL, s::Integer, index::Integer)
    @inbounds return adjlist[s][index]
end

# TODO E_VAL could probably be extracted without being explicitly passed to the function
function value_for_index(tup_adjlist::TupleOrNamedTuple, E_VAL::Type, s::Integer, index::Integer)
    @inbounds return E_VAL( adjlist[s][index] for adjlist in tup_adjlist )
end


function value_for_index(tup_adjlist::TupleOrNamedTuple, E_VAL, s::Integer, index::Integer, key)
    adjlist = tup_adjlist[key]
    @inbounds return adjlist[s][index]
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
