#abstract type AbstractSimpleValueEdge{T, U} <: AbstractEdge{T} end

struct SimpleValueEdge{T, U} <: AbstractEdge{T}
    src::T
    dst::T
    value::U
end

src(e::SimpleValueEdge) = e.src
dst(e::SimpleValueEdge) = e.dst
edgeval(e::SimpleValueEdge) = e.value 

reverse(e::SimpleValueEdge) = SimpleValueEdge(e.dst, e.src, e.value)

show(io::IO, e::SimpleValueEdge) = print(io, "Edge $(e.src) => $(e.dst) with value $(e.value)")

