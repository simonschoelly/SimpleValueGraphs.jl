#  ------------------------------------------------------
#  Constructor from other simple graphs
#  ------------------------------------------------------

"""
    ValGraph{V, V_VALS, E_VALS}(g::SimpleGraph; vertexval_initializer, edgeval_initializer)
    ValGraph{V = eltype(g)}(g::SimpleGraph; vertexval_types=(), edgeval_types=(), vertexval_initializer, edgeval_initializer)

Construct a `ValGraph` with the same structure as `g`.
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

    gv = ValGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C}(ne(g), fadjlist, vertexvals, edgevals)

    if edgeval_initializer != undef && length(edgevals) > 0
        # TODO there is a more efficient method for this
        for e in edges(g)
            s, d = Tuple(e)
            set_edgeval!(gv, s, d, :, edgeval_initializer(s, d))
        end
    end

    return gv
end

ValGraph{V}(g::SimpleGraph; vertexval_types=(), edgeval_types=(), kwargs...) where {V} =
    ValGraph{V, construct_E_VAL(vertexval_types), construct_E_VAL(edgeval_types)}(g; kwargs...)

ValGraph(g::SimpleGraph; kwargs...) = ValGraph{eltype(g)}(g; kwargs...)


"""
    ValOutDiGraph{V, V_VALS, E_VALS}(g::SimpleDiGraph; vertexval_initializer, edgeval_initializer)
    ValOutDiGraph{V = eltype(g)}(g::SimpleDiGraph;vertexval_types=(), edgeval_types=(), vertexval_initializer, edgeval_initializer)

Construct a `ValOutDiGraph` with the same structure as `g`.
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

ValOutDiGraph{V}(g::SimpleDiGraph; vertexval_types=(), edgeval_types=(), kwargs...) where {V} =
    ValOutDiGraph{V, construct_E_VAL(vertexval_types), construct_E_VAL(edgeval_types)}(g; kwargs...)

ValOutDiGraph(g::SimpleDiGraph; kwargs...) = ValOutDiGraph{eltype(g)}(g; kwargs...)


"""
    ValDiGraph{V, V_VALS, E_VALS}(g::SimpleDiGraph; vertexval_initializer, edgeval_initializer)
    ValDiGraph{V = eltype(g)}(g::SimpleDiGraph;vertexval_types=(), edgeval_types=(), vertexval_initializer, edgeval_initializer)

Construct a `ValDiGraph` with the same structure as `g`.
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

ValDiGraph{V}(g::SimpleDiGraph; vertexval_types=(), edgeval_types=(), kwargs...) where {V} =
    ValDiGraph{V, construct_E_VAL(vertexval_types), construct_E_VAL(edgeval_types)}(g; kwargs...)

ValDiGraph(g::SimpleDiGraph; kwargs...) = ValDiGraph{eltype(g)}(g; kwargs...)

