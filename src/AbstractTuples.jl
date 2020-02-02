
module AbstractTuples

export AbstractTuple, NamedNTuple, AbstractNTuple

const AbstractTuple{T <: Tuple} = Union{<: T, NamedTuple{S, <:T} where S}

const NamedNTuple{N, T} = NamedTuple{S, NTuple{N, T}} where S
const AbstractNTuple{N, T} = Union{NTuple{N, T}, NamedNTuple{N, T}}


end
