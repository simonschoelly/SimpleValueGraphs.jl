
"""
    AbstractTuples

Module that provides additional functionally for `Tuple` and `NamedTuple`

### See also
[`AbstractTuple`](@ref), [`AbstractNTuple`](@ref), [`NamedNTuple`](@ref), [`tuple_of_types`](@ref)
"""
module AbstractTuples

export AbstractTuple, NamedNTuple, AbstractNTuple, tuple_of_types


"""
    AbstractTuple{<: Tuple}

A type `Union` of a `Tuple` and a `NamedTuple`.

Useful for methods that take either a `Tuple` or a `NamedTuple` of some specific types as some parameter.

### See also
[`AbstractNTuple`](@ref), [`Tuple`](@ref), [`NTuple`](@ref)

### Examples

```jldoctest
julia> (1, "xyz") isa AbstractTuple{Tuple{Int, String}}
true

julia> (a=1, b="xyz") isa AbstractTuple{Tuple{Int, String}}
true

julia> (a=1, b="xyz") isa AbstractTuple
true
```
"""
const AbstractTuple{T <: Tuple} = Union{<: T, NamedTuple{S, <:T} where S}


"""
    NamedNTuple{N, T}

A `NamedTuple` with `N` arguments of the same type.

Analogue to `NTuple` for `Tuple`.

### See also
[`AbstractNTuple`](@ref), [`NTuple`](@ref), [`NamedTuple`](@ref)

### Examples

```jldoctest
julia> (a = 1, b = 2) isa NTuple{2, Int}
true

julia> (a = 1, b = 2) isa NTuple{2}
true

julia> (a = 1, b = "xyz") isa NTuple{2, Int}
false
```
"""
const NamedNTuple{N, T} = NamedTuple{S, NTuple{N, T}} where S


"""
AbstractNTuple{N, T}

A Union of an `NTuple` and a `NamedNTuple`.
### See also
[`NTuple`](@ref), [`NamedNTuple`](@ref)

### Examples

```jldoctest
julia> (1, 2, 3) isa AbstractNTuple{3, Int}
true

julia> (a=1, b=2, c=3) isa AbstractNTuple{3, Int}
true

julia> (1, 2) isa AbstractNTuple{3, Int}
false

julia> (a=1, b=2, c="xyz") isa AbstractNTuple{3, Int}
false
```
"""
const AbstractNTuple{N, T} = Union{NTuple{N, T}, NamedNTuple{N, T}}


"""
    tuple_of_types(::Type{<:Tuple})
    tuple_of_types(::Type{<:NamedTuple})

Convert a Tuple or NamedTuple type to a Tuple or NamedTuple containing the tuples types.

### Examples

```jldoctest
julia> tuple_of_types(Tuple{Int64, String})
(Int64, String)

julia> tuple_of_types(typeof(a = "first", b = 2.0))
(a = String, b = Float64)
```
"""
function tuple_of_types end

function tuple_of_types(TT::Type{<:Tuple})
    return Tuple(TT.types)
end

function tuple_of_types(TT::Type{<:NamedTuple})
    return NamedTuple{Tuple(TT.names)}(TT.types)
end


end # Module
