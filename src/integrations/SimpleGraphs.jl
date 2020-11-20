
#  This file contains value graph constructors from LightGraphs simple graphs.

"""
    ValGraph{V, V_VALS, E_VALS}(
        g::SimpleGraph;
        vertexval_initializer,
        edgeval_initializer
    )
    ValGraph{V = eltype(g)}(
        g::SimpleGraph;
        vertexval_types=(),
        edgeval_types=(),
        vertexval_initializer,
        edgeval_initializer
    )

Construct a `ValGraph` with the same structure as `g`.

# Arguments
- `g`: A `LightGraphs.SimpleGraph`

# Keywords
- `vertexval_initializer`: How the vertex values of this graph should be initialized.
    Can be either a function `v -> (values...)` or `undef`. Can be omitted if this
    graph has no vertex values.
- `edgeval_initializer`: How the edge values of this graph should be initialized.
    Can be either a function `(s,d) -> (values...)` or `undef`. Can be omitted if this
    graph has no edge values.
- `vertexval_types`: A `Tuple` or `NamedTuple` of types.
- `edgeval_types`: A `Tuple` or `NamedTuple` of types.

# Parameters
- `V` the eltype of this graphs vertices. `eltype(g) if omitted.
- `V_VALS` The type (either a `Tuple` or a `NamedTuple` type) of vertex values. Can
    alternatively be specified with the `vertexval_initializer` keyword argument.
- `E_VALS` The type (either a `Tuple` or a `NamedTuple` type) of edge values. Can
    alternatively be specified with the `edgeval_initializer` keyword argument.
"""
function ValGraph{V, V_VALS, E_VALS}(
            g::SimpleGraph;
            vertexval_initializer=nothing,
            edgeval_initializer=nothing) where {V, V_VALS, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)

    vertexvals = create_vertexvals(n, V_VALS, vertexval_initializer)
    V_VALS_C = typeof(vertexvals)

    E_VALS_C = edgevals_container_type(Val(E_VALS)) # TODO ?
    edgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VALS.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s]))
        end
    end

    gv = ValGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C}(
        ne(g),
        fadjlist,
        vertexvals,
        edgevals
    )

    if edgeval_initializer != undef && length(edgevals) > 0
        # TODO there is a more efficient method for this
        for e in edges(g)
            s, d = Tuple(e)
            set_edgeval!(gv, s, d, :, edgeval_initializer(s, d))
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
        vertexval_initializer,
        edgeval_initializer
    )
    ValOutDiGraph{V = eltype(g)}(
        g::SimpleDiGraph;
        vertexval_types=(),
        edgeval_types=(),
        vertexval_initializer,
        edgeval_initializer
    )

Construct a `ValOutDiGraph` with the same structure as `g`.

# Arguments
- `g`: A `LightGraphs.SimpleDiGraph`

# Keywords
- `vertexval_initializer`: How the vertex values of this graph should be initialized.
    Can be either a function `v -> (values...)` or `undef`. Can be omitted if this
    graph has no vertex values.
- `edgeval_initializer`: How the edge values of this graph should be initialized.
    Can be either a function `(s,d) -> (values...)` or `undef`. Can be omitted if this
    graph has no edge values.
- `vertexval_types`: A `Tuple` or `NamedTuple` of types.
- `edgeval_types`: A `Tuple` or `NamedTuple` of types.

# Parameters
- `V` the eltype of this graphs vertices. `eltype(g) if omitted.
- `V_VALS` The type (either a `Tuple` or a `NamedTuple` type) of vertex values. Can
    alternatively be specified with the `vertexval_initializer` keyword argument.
- `E_VALS` The type (either a `Tuple` or a `NamedTuple` type) of edge values. Can
    alternatively be specified with the `edgeval_initializer` keyword argument.
"""
function ValOutDiGraph{V, V_VALS, E_VALS}(
            g::SimpleDiGraph;
            vertexval_initializer=nothing,
            edgeval_initializer=nothing) where {V, V_VALS, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V,g.fadjlist)

    vertexvals = create_vertexvals(n, V_VALS, vertexval_initializer)
    V_VALS_C = typeof(vertexvals)
    E_VALS_C = edgevals_container_type(Val(E_VALS)) # TODO ?
    edgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VALS.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s]))
        end
    end

    gv = ValOutDiGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C}(ne(g), fadjlist, vertexvals, edgevals)

    if edgeval_initializer != undef && length(edgevals) > 0
        # TODO there is a more efficient method for this
        for e in edges(g)
            s, d = Tuple(e)
            set_edgeval!(gv, s, d, :, edgeval_initializer(s, d))
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
        vertexval_initializer,
        edgeval_initializer
    )
    ValDiGraph{V = eltype(g)}(
        g::SimpleDiGraph;
        vertexval_types=(),
        edgeval_types=(),
        vertexval_initializer,
        edgeval_initializer
    )

Construct a `ValDiGraph` with the same structure as `g`.

# Arguments
- `g`: A `LightGraphs.SimpleDiGraph`

# Keywords
- `vertexval_initializer`: How the vertex values of this graph should be initialized.
    Can be either a function `v -> (values...)` or `undef`. Can be omitted if this
    graph has no vertex values.
- `edgeval_initializer`: How the edge values of this graph should be initialized.
    Can be either a function `(s,d) -> (values...)` or `undef`. Can be omitted if this
    graph has no edge values.
- `vertexval_types`: A `Tuple` or `NamedTuple` of types.
- `edgeval_types`: A `Tuple` or `NamedTuple` of types.

# Parameters
- `V` the eltype of this graphs vertices. `eltype(g) if omitted.
- `V_VALS` The type (either a `Tuple` or a `NamedTuple` type) of vertex values. Can
    alternatively be specified with the `vertexval_initializer` keyword argument.
- `E_VALS` The type (either a `Tuple` or a `NamedTuple` type) of edge values. Can
    alternatively be specified with the `edgeval_initializer` keyword argument.

"""
function ValDiGraph{V, V_VALS, E_VALS}(
            g::SimpleDiGraph;
            vertexval_initializer=nothing,
            edgeval_initializer=nothing) where {V, V_VALS, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    badjlist = deepcopy_adjlist(V, g.badjlist)

    vertexvals = create_vertexvals(n, V_VALS, vertexval_initializer)
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

    gv = ValDiGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C}(ne(g), fadjlist, badjlist, vertexvals, edgevals, redgevals)

    if edgeval_initializer != undef && length(edgevals) > 0
        # TODO there is a more efficient method for this
        for e in edges(g)
            s, d = Tuple(e)
            set_edgeval!(gv, s, d, :, edgeval_initializer(s, d))
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

