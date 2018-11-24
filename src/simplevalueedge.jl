#abstract type AbstractSimpleValueEdge{T, U} <: AbstractEdge{T} end

struct SimpleValueEdge{V<:Integer, E_VAL} <: AbstractEdge{V}
    src::V
    dst::V
    value::E_VAL
end

SimpleValueEdge(src, dst) = SimpleValueEdge(src, dst, nothing)

src(e::SimpleValueEdge) = e.src
dst(e::SimpleValueEdge) = e.dst
val(e::SimpleValueEdge) = e.value

reverse(e::SimpleValueEdge) = SimpleValueEdge(dst(e), src(e), val(e))

show(io::IO, e::SimpleValueEdge) = print(io, "Edge $(src(e)) => $(dst(e)) with value $(repr(val(e)))")

Tuple(e::SimpleValueEdge) = (src(e), dst(e), val(e))

