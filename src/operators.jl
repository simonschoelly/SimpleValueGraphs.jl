
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
struct Reverse{V <: Integer, V_VALS, E_VALS, G_VALS, G<:AbstractValGraph{V, V_VALS, E_VALS, G_VALS}} <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}

    graph::G
end


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

wrapped_graph(g::Reverse) = g.graph
wrapped_graph_type(::Type{<:Reverse{V, V_VALS, E_VALS, G_VALS, G}}) where {V, V_VALS, E_VALS, G_VALS, G} = G
@wrap_graph! Reverse include=[ne] exclude=[has_edge, add_edge!, rem_edge!, get_edgeval, set_edgeval!]

has_edge(rg::Reverse, s::Integer, d::Integer) =  has_edge(rg.graph, d, s)
add_edge!(rg::Reverse, s::Integer, d::Integer, values) = add_edge!(rg.graph, d, s, values)
rem_edge!(rg::Reverse, s::Integer, d::Integer) = rem_edge!(rg.graph, d, s)

get_edgeval(rg::Reverse, s::Integer, d::Integer, key::Integer) = get_edgeval(rg.graph, d, s, key)
get_edgeval(rg::Reverse, s::Integer, d::Integer, key::Symbol) = get_edgeval(rg.graph, d, s, key)
get_edgeval(rg::Reverse, s::Integer, d::Integer, ::Colon) = get_edgeval(rg.graph, d, s, :)

set_edgeval!(rg::Reverse, s::Integer, d::Integer, key::Integer, value) = set_edgeval!(rg.graph, d, s, key, value)
set_edgeval!(rg::Reverse, s::Integer, d::Integer, key::Symbol, value) = set_edgeval!(rg.graph, d, s, key, value)
set_edgeval!(rg::Reverse, s::Integer, d::Integer, ::Colon, values) = set_edgeval!(rg.graph, d, s, :, values)

