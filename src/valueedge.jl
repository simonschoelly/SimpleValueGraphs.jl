

abstract type AbstractValueEdge{V <: Integer, E_VALS} <: AbstractEdge{V} end

"""
    ValueEdge{V, E_VALS} <: AbstractValueEdge{V}

A datastructure representing an undirected edge with multiple values.
"""
struct ValueEdge{V<:Integer, E_VALS} <: AbstractValueEdge{V, E_VALS}
    src::V
    dst::V
    vals::E_VALS

    function ValueEdge(src::V, dst::V, vals::E_VALS) where {V, E_VALS}
        src, dst = minmax(src, dst) # TODO maybe use a branchless operator
        return new{V, E_VALS}(src, dst, vals)
    end
end

# TODO update docstring and ValueDiEdge
"""
    ValueEdge(s, d, v)
Create a `ValueEdge` with source `s`, destination `d` and value `v`.
# Examples
```
julia> e = SimplevalueEdge(4, 2, 'A')
Edge 4 => 2 with value 'A'
```
"""
function ValueEdge end

"""
    ValueDiEdge{V, E_VALS} <: AbstractValueEdge{V}

A datastructure representing a directed edge with values.
"""
struct ValueDiEdge{V<:Integer, E_VALS} <: AbstractValueEdge{V, E_VALS}
    src::V
    dst::V
    vals::E_VALS

    function ValueDiEdge(src::V, dst::V, vals::E_VALS) where {V, E_VALS}
        return new{V, E_VALS}(src, dst, vals)
    end
end

src(e::AbstractValueEdge) = e.src
dst(e::AbstractValueEdge) = e.dst

"""
    vals(e::ValueEdge)
Returns the value attached to the edge `e`.
# Examples
```
julia> g = ValueGraph(3, String)

julia> add_edge!(g, 2, 3, ("xyz",))

julia> first(edges(g)) |> vals
"xyz"
```
"""
vals(e::AbstractValueEdge) = e.vals



const SingleValueTuple{T} = Union{Tuple{T}, NamedTuple{S, Tuple{T}} where {S}}

val(e::AbstractValueEdge; key::Union{Integer, Symbol, NoKey}=nokey) =
    _val(e, key)

_val(e::AbstractValueEdge{V, E_VAL}, ::NoKey) where {V, E_VAL <: SingleValueTuple} =
    e.vals[1]

_val(e::AbstractValueEdge, key::Union{Integer, Symbol}) = e.vals[key]

reverse(e::ValueEdge) = e
reverse(e::ValueDiEdge) = ValueDiEdge(dst(e), src(e), vals(e))


is_directed(::Type{<:ValueEdge}) = false
is_directed(::Type{<:ValueDiEdge}) = true
is_directed(e::AbstractValueEdge) = is_directed(typeof(e))

function show(io::IO, e::AbstractValueEdge)
    isdir = is_directed(e) 
    e_keys = keys(vals(e))
    has_symbol_keys = eltype(e_keys) === Symbol

    print(io, isdir ? "ValueDiEdge" : "ValueEdge")
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


