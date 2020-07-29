

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
    vals(e::AbstractValEdge)
Return the values attached to the edg;e `e`.

# Examples

```jldoctest
julia> e = ValEdge(1, 2, ("xyz", 123));
julia> vals(e)
("xyz", 123)

julia> e = ValDiEdge(1, 2, (weight=2.5,));
julia> vals(e)
(weight = 2.5,)
```
"""
vals(e::AbstractValEdge) = e.vals

"""
    val(e::AbstractValEdge[, key])

Return the value attached to the edge `e` for the key `key`.

If `e` has a single value `key` can be omitted

# Examples
```jldoctest
julia> e = ValEdge(1, 2, (a=11.0, ));

julia> val(e, 1) # use integer key
11.0

julia> val(e, :a) # use symbolic key
11.0

julia> val(e) # e has a single value so the key can be omitted
11.0
```
"""
function val end

val(e::AbstractValEdge{<: Any, E_VALS}) where {E_VALS <: AbstractNTuple{1}} = val(e, 1)

val(e::AbstractValEdge, key) = e.vals[key]


LG.reverse(e::ValEdge) = e
LG.reverse(e::ValDiEdge) = ValDiEdge(dst(e), src(e), vals(e))


LG.is_directed(::Type{<:ValEdge}) = false
LG.is_directed(::Type{<:ValDiEdge}) = true
LG.is_directed(e::AbstractValEdge) = is_directed(typeof(e))

function Base.show(io::IO, e::AbstractValEdge)
    isdir = is_directed(e) 
    e_keys = keys(vals(e))
    has_symbol_keys = eltype(e_keys) === Symbol

    print(io, isdir ? "ValDiEdge" : "ValEdge")
    arrow = isdir ? "->" : "--"
    print(io, " $(src(e)) $arrow $(dst(e))")

    if length(e_keys) == 1
        print(io, " with value " * (has_symbol_keys ? "$(e_keys[1]) = $(val(e))" :
                                                      "$(val(e))"))
    elseif length(e_keys) > 1
        print(io, " with values $(vals(e))")
    end

    println(io)
end


