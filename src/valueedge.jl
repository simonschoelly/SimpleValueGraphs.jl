

abstract type AbstractValEdge{V <: Integer, E_VALS} <: AbstractEdge{V} end

"""
    ValEdge{V, E_VALS} <: AbstractValEdge{V}

A data structure representing an undirected edge with multiple values.

----

    ValEdge(s, d, vals)

Create a `ValEdge` with source `s`, destination `d` and values `vals`.

# Examples
```jldoctest
julia> e = ValEdge(1, 2, ('A',))
ValEdge 1 -- 2 with value A

julia> e = ValEdge(1, 2, ())
ValEdge 1 -- 2

julia> e = ValEdge(1,2, (first = 1, second = "2"))
ValEdge 1 -- 2 with values (first = 1, second = "2")
```
"""
struct ValEdge{V<:Integer, E_VALS} <: AbstractValEdge{V, E_VALS}
    src::V
    dst::V
    vals::E_VALS

    function ValEdge(src::V, dst::V, vals::E_VALS) where {V, E_VALS}
        src, dst = minmax(src, dst) # TODO maybe use a branchless operator
        return new{V, E_VALS}(src, dst, vals)
    end
end



"""
    ValDiEdge{V, E_VALS} <: AbstractValEdge{V}

A data structure representing a directed edge with multiple values.

----

    ValDiEdge(s, d, vals)

Create a `ValEdge` with source `s`, destination `d` and values `vals`.

# Examples
```jldoctest
julia> e = ValDiEdge(1, 2, ('A',))
ValDiEdge 1 -> 2 with value A

julia> e = ValDiEdge(1, 2, ())
ValDiEdge 1 -> 2

julia> e = ValDiEdge(1,2, (first = 1, second = "2"))
ValDiEdge 1 -> 2 with values (first = 1, second = "2")
```
"""
struct ValDiEdge{V<:Integer, E_VALS} <: AbstractValEdge{V, E_VALS}
    src::V
    dst::V
    vals::E_VALS

    function ValDiEdge(src::V, dst::V, vals::E_VALS) where {V, E_VALS}
        return new{V, E_VALS}(src, dst, vals)
    end
end

LG.src(e::AbstractValEdge) = e.src
LG.dst(e::AbstractValEdge) = e.dst

"""
    get_val(e::AbstractValEdge, :)
Return the values attached to the edg;e `e`.

# Examples

```jldoctest
julia> e = ValEdge(1, 2, ("xyz", 123));
julia> get_val(e, :)
("xyz", 123)

julia> e = ValDiEdge(1, 2, (weight=2.5,));
julia> get_val(e, :)
(weight = 2.5,)
```
"""
get_val(e::AbstractValEdge, ::Colon) = e.vals

"""
    get_val(e::AbstractValEdge, key)

Return the value attached to the edge `e` for the key `key`.

# Examples
```jldoctest
julia> e = ValEdge(1, 2, (a=11.0, ));

julia> get_val(e, 1) # use integer key
11.0

julia> get_val(e, :a) # use symbolic key
11.0

```
"""
get_val(e::AbstractValEdge, key) = e.vals[key]


LG.reverse(e::ValEdge) = e
LG.reverse(e::ValDiEdge) = ValDiEdge(dst(e), src(e), get_val(e, :))


LG.is_directed(::Type{<:ValEdge}) = false
LG.is_directed(::Type{<:ValDiEdge}) = true
LG.is_directed(e::AbstractValEdge) = is_directed(typeof(e))

function Base.show(io::IO, e::AbstractValEdge)
    isdir = is_directed(e) 
    e_keys = keys(get_val(e, :))
    has_symbol_keys = eltype(e_keys) === Symbol

    print(io, isdir ? "ValDiEdge" : "ValEdge")
    arrow = isdir ? "->" : "--"
    print(io, " $(src(e)) $arrow $(dst(e))")

    if length(e_keys) == 1
        print(io, " with value " * (has_symbol_keys ? "$(e_keys[1]) = $(get_val(e, 1))" :
                                                      "$(get_val(e, 1))"))
    elseif length(e_keys) > 1
        print(io, " with values $(get_val(e, :))")
    end

    println(io)
end


