
"""
    SimpleValue{V, E_VAL} <: AbstractEdge{V}
A datastructure representing an edge with a value in a `SimpleValueGraph` or `SimpleValueDiGraph`.
"""
struct SimpleValueEdge{V<:Integer, E_VAL} <: AbstractEdge{V}
    src::V
    dst::V
    value::E_VAL
end

"""
    SimpleValueEdge(s, d, v)
Create a `SimpleValueEdge` with source `s`, destination `d` and value `v`.
# Examples
```
julia> e = SimplevalueEdge(4, 2, 'A')
Edge 4 => 2 with value 'A'
```
"""
function SimpleValueEdge end

"""
    SimpleValueEdge((s, d, v))
Create a `SimpleValueEdge` from a Tuple with source `s`, destination `d` and value `v`.
# Examples
```
julia> e = SimplevalueEdge((3, 3, "xyz))
Edge 3 => 3 with value "xyz"
```
"""
SimpleValueEdge((s, d, v)) = SimpleValueEdge(s, d, v)


src(e::SimpleValueEdge) = e.src
dst(e::SimpleValueEdge) = e.dst


"""
    val(e::SimpleValueEdge)
Returns the value attached to the edge `e`.
# Examples
```
julia> g = SimpleValueGraph(3, String)

julia> add_edge!(g, 2, 3, "xyz")

julia> first(edges(g)) |> val
"xyz"
```
"""
val(e::SimpleValueEdge) = e.value

"""
    Tuple(e::SimpleValueEdge)
Create a Tuple `(src(e), dst(e), val(e))`
"""
Tuple(e::SimpleValueEdge) = (src(e), dst(e), val(e))

reverse(e::SimpleValueEdge) = SimpleValueEdge(dst(e), src(e), val(e))

show(io::IO, e::SimpleValueEdge) = print(io, "Edge $(src(e)) => $(dst(e)) with value $(repr(val(e)))")


