
# ==================================
# squash
# ==================================

const CANDIDATE_SQUASH_TYPES = [Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64]

"""
    squash(g::ValGraph)
    squash(g::ValDiGraph)
    squash(g::ValOutDiGraph)

Return a copy of `g` with an `eltype` as small as possible.

This can help with performance. Only the `eltype` is changed, all other
types stay the same.
"""
function squash(g::Union{ValGraph, ValDiGraph, ValOutDiGraph})

    nvg = nv(g)
    # TODO find a more future proof way to extract the unparametrized type
    G = typeof(g).name.wrapper
    for V ∈ CANDIDATE_SQUASH_TYPES

        nvg < typemax(V) && return G{V}(g)
    end
end

# TODO implement destructive squash!

# ==================================
#    reverse
# ==================================

"""
    Reverse

Lazy wrapper for value graphs that reverses the directions of the graphs edges.
If this object is mutated, the wrapped graph is mutated as well.
"""
struct Reverse{V, V_VALS, E_VALS, G_VALS, G<:AbstractValGraph{V, V_VALS, E_VALS, G_VALS}} <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}

    graph::G
end

_graphtype(::Type{<:Reverse{V, V_VALS, E_VALS, G_VALS, G}}) where {V, V_VALS, E_VALS, G_VALS, G} = G

"""
    reverse(g::AbstractValGraph)

Reverse the direction of the edges of `g`. Can also return `Reverse(g)` - a lazy
wrapper around `g`.
"""
reverse(g::AbstractValGraph) = is_directed(g) ? Reverse(g) : g

reverse(rg::Reverse) = rg.graph

## ---------------------------------
##   Reverse
## ---------------------------------

nv(rg::Reverse) = nv(rg.graph)

has_edge(rg::Reverse, s::Integer, d::Integer) =  has_edge(rg.graph, d, s)

LG.is_directed(RG::Type{<:Reverse}) = is_directed(_graphtype(RG))

zero(RG::Type{<:Reverse}) = Reverse{_graphtype(RG)}(zero(RG))

get_vertexval(rg::Reverse, v::Integer, key::Integer) = get_vertexval(rg.graph, v, key)
get_vertexval(rg::Reverse, v::Integer, key::Symbol) = get_vertexval(rg.graph, v, key)
get_vertexval(rg::Reverse, v::Integer, ::Colon) = get_vertexval(rg.graph, v, :)

set_vertexval!(rg::Reverse, v::Integer, key::Integer, value) = set_vertexval!(rg.graph, v, key, value)
set_vertexval!(rg::Reverse, v::Integer, key::Symbol, value) = set_vertexval!(rg.graph, v, key, value)
set_vertexval!(rg::Reverse, v::Integer, ::Colon, values) = set_vertexval!(rg.graph, v, :, values)

get_edgeval(rg::Reverse, s::Integer, d::Integer, key::Integer) = get_edgeval(rg.graph, d, s, key)
get_edgeval(rg::Reverse, s::Integer, d::Integer, key::Symbol) = get_edgeval(rg.graph, d, s, key)
get_edgeval(rg::Reverse, s::Integer, d::Integer, ::Colon) = get_edgeval(rg.graph, d, s, :)

set_edgeval!(rg::Reverse, s::Integer, d::Integer, key::Integer, value) = set_edgeval!(rg.graph, d, s, key, value)
set_edgeval!(rg::Reverse, s::Integer, d::Integer, key::Symbol, value) = set_edgeval!(rg.graph, d, s, key, value)
set_edgeval!(rg::Reverse, s::Integer, d::Integer, ::Colon, values) = set_edgeval!(rg.graph, d, s, :, values)

get_graphval(rg::Reverse, key::Integer) = get_graphval(rg.graph, key)
get_graphval(rg::Reverse, key::Symbol) = get_graphval(rg.graph, key)
get_graphval(rg::Reverse, ::Colon) = get_graphval(rg.graph, :)

set_graphval!(rg::Reverse, key::Integer, value) = set_graphval!(rg.graph, key, value)
set_graphval!(rg::Reverse, key::Symbol, value) = set_graphval!(rg.graph, key, value)
set_graphval!(rg::Reverse, ::Colon, values) = set_graphval!(rg.graph, :, values)

add_vertex!(rg::Reverse, values) = add_vertex!(rg.graph, values)

add_edge!(rg::Reverse, s::Integer, d::Integer, values) = add_edge!(rg.graph, d, s, values)

ne(rg::Reverse) = ne(rg.graph)
