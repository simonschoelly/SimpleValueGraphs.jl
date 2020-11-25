
"""
    AbstractTuples

Module that provides additional functionally for `Tuple` and `NamedTuple`

### See also
[`AbstractTuple`](@ref), [`AbstractNTuple`](@ref), [`NamedNTuple`](@ref)
"""
module AbstractTuples

export AbstractTuple, NamedNTuple, AbstractNTuple, typetuple_to_type, typetuple


"""
    AbstractTuple{<: Tuple}

A type `Union` of a `Tuple` and a `NamedTuple`.

Useful for methods that take either a `Tuple` or a `NamedTuple` of some specific
types for parameters.

Note that like `NamedTuple` but unlike `Tuple`, ÀbstractTuple is not covariant.
I.e. it does not hold that `AbstractTuple{Tuple{Int}} <: AbstractTuple{Tuple{Integer}}`

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
const AbstractTuple{T <: Tuple} = Union{T, NamedTuple{S, T} where S}


"""
    NamedNTuple{N, T}

A `NamedTuple` with `N` arguments of the same type.

Analogue to `NTuple` for `Tuple` but as `NamedTuple` is not covariant so is
also `NamedNTuple` not covariant.

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


# TODO maybe restrict to types
"""
    typetuple_to_type(t::Tuple)
    typetuple_to_type(t::NamedTuple)

Convert a Tuple or Named tuple containing types to a Tuple or NamedTuple with
these types.

### Examples

```jldoctest
julia> typetuple_to_type((Int64, String))
Tuple{Int64,String}

julia> typetuple_to_type((a = String, b = Float64))
NamedTuple{(:a, :b),Tuple{String,Float64}}
```
"""
function typetuple_to_type end

typetuple_to_type(tup::Tuple) = Tuple{ (T for T in tup)... }
typetuple_to_type(tup::NamedTuple) =
    NamedTuple{ Tuple(typeof(tup).names), Tuple{ (T for T in tup)... }}

"""
    typetuple(::Type{<:Tuple})
    typetuple(::Type{<:NamedTuple})

Convert a Tuple or NamedTuple type to a Tuple or NamedTuple
containing the types of the tuple.

### Examples

```jldoctest
julia> typetuple(Tuple{Int64, String})
(Int64, String)

julia> typetuple(typeof(a = "first", b = 2.0))
(a = String, b = Float64)
```
"""
function typetuple end

function typetuple(TT::Type{<:Tuple})

    return Tuple(TT.types)
end

function typetuple(TT::Type{<:NamedTuple})

    return NamedTuple{Tuple(TT.names)}(TT.types)
end


end # Module
