
#  This file contains value graph constructors from LightGraphs simple graphs.

"""
    ValGraph{V, V_VALS, E_VALS}(
        g::SimpleGraph;
        vertexval_init,
        edgeval_init,
        graphvals=()
    )
    ValGraph{V = eltype(g)}(
        g::SimpleGraph;
        vertexval_types=(),
        edgeval_types=(),
        vertexval_init,
        edgeval_init,
        graphvals=()
    )

Construct a `ValGraph` with the same structure as `g`.

# Arguments
- `g`: A `LightGraphs.SimpleGraph`

# Keywords
- `vertexval_init`: How the vertex values of this graph should be initialized.
    Can be either a function `v -> (values...)` or `undef`. Can be omitted if this
    graph has no vertex values.
- `edgeval_init`: How the edge values of this graph should be initialized.
    Can be either a function `(s,d) -> (values...)` or `undef`. Can be omitted if this
    graph has no edge values.
- `vertexval_types`: A `Tuple` or `NamedTuple` of types.
- `edgeval_types`: A `Tuple` or `NamedTuple` of types.
- `grapvals`: A `Tuple` or `NamedTuple` of graph values.

# Parameters
- `V` the eltype of this graphs vertices. `eltype(g) if omitted.
- `V_VALS` The type (either a `Tuple` or a `NamedTuple` type) of vertex values. Can
    alternatively be specified with the `vertexval_init` keyword argument.
- `E_VALS` The type (either a `Tuple` or a `NamedTuple` type) of edge values. Can
    alternatively be specified with the `edgeval_init` keyword argument.
"""
function ValGraph{V, V_VALS, E_VALS}(
            g::SimpleGraph;
            vertexval_init=nothing,
            edgeval_init=nothing,
            graphvals=()) where {V, V_VALS, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)

    vertexvals = create_vertexvals(n, V_VALS, vertexval_init)
    V_VALS_C = typeof(vertexvals)

    E_VALS_C = edgevals_container_type(Val(E_VALS)) # TODO ?
    edgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VALS.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s]))
        end
    end

    G_VALS = typeof(graphvals)

    gv = ValGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(
        ne(g),
        fadjlist,
        vertexvals,
        edgevals,
        graphvals
    )

    if edgeval_init != undef && length(edgevals) > 0
        # TODO there is a more efficient method for this
        for e in edges(g)
            s, d = Tuple(e)
            set_edgeval!(gv, s, d, :, edgeval_init(s, d))
        end
    end

    return gv
end

function ValGraph{V}(g::SimpleGraph; vertexval_types=(), edgeval_types=(), kwargs...) where {V}

    V_VALS = typetuple_to_type(vertexval_types)
    E_VALS = typetuple_to_type(edgeval_types)

    return ValGraph{V, V_VALS, E_VALS}(g; kwargs...)
end

ValGraph(g::SimpleGraph; kwargs...) = ValGraph{eltype(g)}(g; kwargs...)


"""
    ValOutDiGraph{V, V_VALS, E_VALS}(
        g::SimpleDiGraph;
        vertexval_init,
        edgeval_init,
        graphvals=()
    )
    ValOutDiGraph{V = eltype(g)}(
        g::SimpleDiGraph;
        vertexval_types=(),
        edgeval_types=(),
        vertexval_init,
        edgeval_init,
        graphvals=()
    )

Construct a `ValOutDiGraph` with the same structure as `g`.

# Arguments
- `g`: A `LightGraphs.SimpleDiGraph`

# Keywords
- `vertexval_init`: How the vertex values of this graph should be initialized.
    Can be either a function `v -> (values...)` or `undef`. Can be omitted if this
    graph has no vertex values.
- `edgeval_init`: How the edge values of this graph should be initialized.
    Can be either a function `(s,d) -> (values...)` or `undef`. Can be omitted if this
    graph has no edge values.
- `vertexval_types`: A `Tuple` or `NamedTuple` of types.
- `edgeval_types`: A `Tuple` or `NamedTuple` of types.
- `grapvals`: A `Tuple` or `NamedTuple` of graph values.

# Parameters
- `V` the eltype of this graphs vertices. `eltype(g) if omitted.
- `V_VALS` The type (either a `Tuple` or a `NamedTuple` type) of vertex values. Can
    alternatively be specified with the `vertexval_init` keyword argument.
- `E_VALS` The type (either a `Tuple` or a `NamedTuple` type) of edge values. Can
    alternatively be specified with the `edgeval_init` keyword argument.
"""
function ValOutDiGraph{V, V_VALS, E_VALS}(
            g::SimpleDiGraph;
            vertexval_init=nothing,
            edgeval_init=nothing,
            graphvals=()) where {V, V_VALS, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V,g.fadjlist)

    vertexvals = create_vertexvals(n, V_VALS, vertexval_init)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = edgevals_container_type(Val(E_VALS)) # TODO ?
    edgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VALS.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s]))
        end
    end

    G_VALS = typeof(graphvals)

    gv = ValOutDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(ne(g), fadjlist, vertexvals, edgevals, graphvals)

    if edgeval_init != undef && length(edgevals) > 0
        # TODO there is a more efficient method for this
        for e in edges(g)
            s, d = Tuple(e)
            set_edgeval!(gv, s, d, :, edgeval_init(s, d))
        end
    end

    return gv
end

function ValOutDiGraph{V}(g::SimpleDiGraph; vertexval_types=(), edgeval_types=(), kwargs...) where {V}

    V_VALS = typetuple_to_type(vertexval_types)
    E_VALS = typetuple_to_type(edgeval_types)

    return ValOutDiGraph{V, V_VALS, E_VALS}(g; kwargs...)
end

ValOutDiGraph(g::SimpleDiGraph; kwargs...) = ValOutDiGraph{eltype(g)}(g; kwargs...)


"""
    ValDiGraph{V, V_VALS, E_VALS}(
        g::SimpleDiGraph;
        vertexval_init,
        edgeval_init,
        graphvals=()
    )
    ValDiGraph{V = eltype(g)}(
        g::SimpleDiGraph;
        vertexval_types=(),
        edgeval_types=(),
        vertexval_init,
        edgeval_init,
        graphvals=()
    )

Construct a `ValDiGraph` with the same structure as `g`.

# Arguments
- `g`: A `LightGraphs.SimpleDiGraph`

# Keywords
- `vertexval_init`: How the vertex values of this graph should be initialized.
    Can be either a function `v -> (values...)` or `undef`. Can be omitted if this
    graph has no vertex values.
- `edgeval_init`: How the edge values of this graph should be initialized.
    Can be either a function `(s,d) -> (values...)` or `undef`. Can be omitted if this
    graph has no edge values.
- `vertexval_types`: A `Tuple` or `NamedTuple` of types.
- `edgeval_types`: A `Tuple` or `NamedTuple` of types.
- `grapvals`: A `Tuple` or `NamedTuple` of graph values.

# Parameters
- `V` the eltype of this graphs vertices. `eltype(g) if omitted.
- `V_VALS` The type (either a `Tuple` or a `NamedTuple` type) of vertex values. Can
    alternatively be specified with the `vertexval_init` keyword argument.
- `E_VALS` The type (either a `Tuple` or a `NamedTuple` type) of edge values. Can
    alternatively be specified with the `edgeval_init` keyword argument.

"""
function ValDiGraph{V, V_VALS, E_VALS}(
            g::SimpleDiGraph;
            vertexval_init=nothing,
            edgeval_init=nothing,
            graphvals=()) where {V, V_VALS, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    badjlist = deepcopy_adjlist(V, g.badjlist)

    vertexvals = create_vertexvals(n, V_VALS, vertexval_init)
    V_VALS_C = typeof(vertexvals)

    E_VALS_C = edgevals_container_type(Val(E_VALS)) # TODO ?
    edgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    redgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VALS.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s]))
            redgevals[i][s] = Vector{T}(undef, length(badjlist[s]))
        end
    end

    G_VALS = typeof(graphvals)

    gv = ValDiGraph{V, V_VALS, E_VALS, G_VALS, V_VALS_C, E_VALS_C}(ne(g), fadjlist, badjlist, vertexvals, edgevals, redgevals, graphvals)

    if edgeval_init != undef && length(edgevals) > 0
        # TODO there is a more efficient method for this
        for e in edges(g)
            s, d = Tuple(e)
            set_edgeval!(gv, s, d, :, edgeval_init(s, d))
        end
    end

    return gv
end

function ValDiGraph{V}(g::SimpleDiGraph; vertexval_types=(), edgeval_types=(), kwargs...) where {V}

    V_VALS = typetuple_to_type(vertexval_types)
    E_VALS = typetuple_to_type(edgeval_types)

    return ValDiGraph{V, V_VALS, E_VALS}(g; kwargs...)
end

ValDiGraph(g::SimpleDiGraph; kwargs...) = ValDiGraph{eltype(g)}(g; kwargs...)


# ======================================================
# Simple[Di]Graph from value graph constructor
# ======================================================

function SimpleGraph{V}(g::ValGraph) where {V}

    return SimpleGraph{V}(ne(g), deepcopy_adjlist(V, g.fadjlist))
end

SimpleGraph(g::ValGraph) = SimpleGraph{eltype(g)}(g)


function SimpleDiGraph{V}(g::ValDiGraph) where {V}

    return SimpleDiGraph{V}(
                ne(g),
                deepcopy_adjlist(V, g.fadjlist),
                deepcopy_adjlist(V, g.badjlist))
end

SimpleDiGraph(g::ValDiGraph) = SimpleDiGraph{eltype(g)}(g)

function SimpleDiGraph{V}(g::ValOutDiGraph) where {V}

    fadjlist = deepcopy_adjlist(V, g.fadjlist)

    return SimpleDiGraph{V}(ne(g), fadjlist, reverse_adjlist(fadjlist))
end

SimpleDiGraph(g::ValOutDiGraph) = SimpleDiGraph{eltype(g)}(g)


function SimpleDiGraph{V}(g::ValGraph) where {V}

    neg = ne(g) - num_self_loops(g) + ne(g)
    fadjlist =  deepcopy_adjlist(V, g.fadjlist)
    badjlist =  deepcopy_adjlist(V, fadjlist)

    return SimpleDiGraph{V}(neg, fadjlist, badjlist)
end

SimpleDiGraph(g::ValGraph) = SimpleDiGraph{eltype(g)}(g)
