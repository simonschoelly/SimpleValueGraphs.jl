
module AbstractTuples

export AbstractTuple, NamedNTuple, AbstractNTuple, tuple_of_types

const AbstractTuple{T <: Tuple} = Union{<: T, NamedTuple{S, <:T} where S}

const NamedNTuple{N, T} = NamedTuple{S, NTuple{N, T}} where S
const AbstractNTuple{N, T} = Union{NTuple{N, T}, NamedNTuple{N, T}}


"""
    tuple_of_types(::Type{<:Tuple})
    tuple_of_types(::Type{<:NamedTuple})

Convert a Tuple or NamedTuple type to a Tuple or NamedTuple containing the tuples types.

# Example

```jldoctest
julia> tuple_of_types(Tuple{Int64, String})
(Int64, String)

julia> tuple_of_types(typeof(a = "first", b = 2.0))
(a = String, b = Float64)
```
"""
function tuple_of_types(T::AbstractTuple) end

function tuple_of_types(TT::Type{<:Tuple})
    return Tuple(TT.types)
end

function tuple_of_types(TT::Type{<:NamedTuple})
    return NamedTuple{Tuple(TT.names)}(TT.types)
end


end
