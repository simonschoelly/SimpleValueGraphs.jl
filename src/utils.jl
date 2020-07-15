
using SimpleValueGraphs.AbstractTuples

const TupleOfTypes = Tuple{Vararg{Type}}
const NamedTupleOfTypes = NamedTuple{S, <:Tuple{Vararg{Type}}} where {S}
const AbstractTupleOfTypes = Union{TupleOfTypes, NamedTupleOfTypes}



# TODO we might want to replace this with a proper wrapper around Adjlist
const Adjlist{T} = Vector{Vector{T}}

# TODO better name, do we still need these?
function E_VAL_for_key(E_VALS::Type{<:Tuple}, key)
    return E_VALS.types[key]
end

function E_VAL_for_key(E_VALS::Type{<:NamedTuple}, key)
    return NamedTuple{Tuple(E_VALS.names)}(E_VALS.types)[key]
end




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


# TODO check if still correct
edgevaluetype_from_edgevaluecontainertype(::Type{<:Adjlist{T}}) where {T} = T
edgevaluetype_from_edgevaluecontainertype(T::Type{<:Tuple})  = 
    Tuple{ (edgevaluetype_from_edgevaluecontainertype(TT) for TT in T.types)...  } 
edgevaluetype_from_edgevaluecontainertype(T::Type{<:NamedTuple})  = 
    NamedTuple{ Tuple(T.names), Tuple{ (edgevaluetype_from_edgevaluecontainertype(TT) for TT in T.types)... } } 

# TODO check if still correct
@generated function edgevals_container_type(::Val{E_VAL}) where {E_VAL <:Tuple}
    R = Tuple{( Adjlist{T} for T in E_VAL.types )...}
    return :($R)
end

# TODO check if still correct
@generated function edgevals_container_type(::Val{E_VAL}) where {E_VAL <:NamedTuple}
    R = NamedTuple{ Tuple(E_VAL.names), Tuple{( Adjlist{T} for T in E_VAL.types )...}}
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


function value_for_index(adjlist::Adjlist, s::Integer, index::Integer)
    @inbounds return adjlist[s][index]
end


# TODO E_VAL could probably be extracted without being explicitly passed to the function
function values_for_index(tup_adjlist::AbstractTuple, E_VAL::Type, s::Integer, index::Integer)
    @inbounds return E_VAL( adjlist[s][index] for adjlist in tup_adjlist )
end


function values_for_index(tup_adjlist::AbstractTuple, E_VAL, s::Integer, index::Integer, key)
    adjlist = tup_adjlist[key]
    @inbounds return adjlist[s][index]
end


# TODO maybe better in another file
struct AllKeys end
const allkeys = AllKeys()


