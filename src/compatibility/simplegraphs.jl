#  ------------------------------------------------------
#  Constructor from other simple graphs
#  ------------------------------------------------------

"""
    EdgeValGraph{V, E_VALS}(undef, g::SimpleGraph)
    EdgeValGraph{V = eltype(g)}(undef, g::SimpleGraph, edgeval_types=$(default_edgeval_types))

Construct a `EdgeValGraph` with the same structure as `g` with uninitialized edge values.
"""
function EdgeValGraph{V, E_VALS}(::UndefInitializer, g::SimpleGraph) where {V, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)

    E_VALS_C = edgevals_container_type(Val(E_VALS)) # TODO ?
    edgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VALS.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s])) 
        end
    end
    return EdgeValGraph{V, E_VALS, E_VALS_C}(ne(g), fadjlist, edgevals)
end

EdgeValGraph{V}(::UndefInitializer, g::SimpleGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
    EdgeValGraph{V, construct_E_VAL(edgeval_types)}(undef, g)

EdgeValGraph(::UndefInitializer, g::SimpleGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValGraph{eltype(g)}(undef, g, edgeval_types)


"""
    EdgeValOutDiGraph{V, E_VALS}(undef, g::SimpleDiGraph)
    EdgeValOutDiGraph{V = eltype(g)}(undef, g::SimpleDiGraph, edgeval_types=$(default_edgeval_types))

Construct a `EdgeValOutDiGraph` with the same structure as `g` with uninitialized edge values.
"""
function EdgeValOutDiGraph{V, E_VALS}(::UndefInitializer, g::SimpleDiGraph) where {V, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V,g.fadjlist)

    E_VALS_C = edgevals_container_type(Val(E_VALS)) # TODO ?
    edgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VALS.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s])) 
        end
    end
    return EdgeValOutDiGraph{V, E_VALS, E_VALS_C}(ne(g), fadjlist, edgevals)
end

EdgeValOutDiGraph{V}(::UndefInitializer, g::SimpleDiGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
    EdgeValOutDiGraph{V, construct_E_VAL(edgeval_types)}(undef, g)

EdgeValOutDiGraph(::UndefInitializer, g::SimpleDiGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValOutDiGraph{eltype(g)}(undef, g, edgeval_types)



"""
    EdgeValDiGraph{V, E_VALS}(undef, g::SimpleDiGraph)
    EdgeValDiGraph{V = eltype(g)}(undef, g::SimpleDiGraph, edgeval_types=$(default_edgeval_types))

Construct a `EdgeValDiGraph` with the same structure as `g` with uninitialized edge values of types `edgeval_types`.
"""
function EdgeValDiGraph{V, E_VALS}(::UndefInitializer, g::SimpleDiGraph) where {V, E_VALS}

    n = nv(g)
    fadjlist = deepcopy_adjlist(V, g.fadjlist)
    badjlist = deepcopy_adjlist(V, g.badjlist)

    E_VALS_C = edgevals_container_type(Val(E_VALS)) # TODO ?
    edgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    redgevals = E_VALS_C( Adjlist{T}(undef, n) for T in E_VALS.types )
    for s in OneTo(n)
        for (i, T) in enumerate(E_VALS.types)
            edgevals[i][s] = Vector{T}(undef, length(fadjlist[s])) 
            redgevals[i][s] = Vector{T}(undef, length(badjlist[s])) 
        end
    end
    return EdgeValDiGraph{V, E_VALS, E_VALS_C}(ne(g), fadjlist, badjlist, edgevals, redgevals)
end

EdgeValDiGraph{V}(::UndefInitializer, g::SimpleDiGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
    EdgeValDiGraph{V, construct_E_VAL(edgeval_types)}(undef, g)

EdgeValDiGraph(::UndefInitializer, g::SimpleDiGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValDiGraph{eltype(g)}(undef, g, edgeval_types)

"""
    EdgeValGraph{V, E_VALS}([edgeval_initializer,] g::SimpleGraph)
    EdgeValGraph{V = eltype(g)}([edgeval_initializer,], g::SimpleGraph, edgeval_types=$(default_edgeval_types))

Construct a `EdgeValGraph` with the same structure as `g`.
The optional argument `edgeval_initializer` takes a
function that assigns to each edge (s, d) an edge value. If it is not given,
then each edge gets the value `default_edgeval(edgeval_types)`.
"""
function EdgeValGraph{V, E_VALS}(edgeval_initializer::Base.Callable, g::SimpleGraph) where {V, E_VALS}

    gv = EdgeValGraph{V, E_VALS}(undef, g)

    # TODO there is a more efficient method for this
    for e in edges(g)
        s, d = Tuple(e)
        set_val!(gv, s, d, :, edgeval_initializer(s, d))
    end

    return gv
end



"""
    EdgeValOutDiGraph{V, E_VALS}([edgeval_initializer,] g::SimpleGraph)
    EdgeValOutDiGraph{V = eltype(g)}([edgeval_initializer,], g::SimpleGraph, edgeval_types=$(default_edgeval_types))

Construct a `EdgeValOutDiGraph` with the same structure as `g`.
The optional argument `edgeval_initializer` takes a
function that assigns to each edge (s, d) an edge value. If it is not given,
then each edge gets the value `default_edgeval(edgeval_types)`.
"""
function EdgeValOutDiGraph{V, E_VALS}(edgeval_initializer::Base.Callable, g::SimpleDiGraph) where {V, E_VALS}

    gv = EdgeValOutDiGraph{V, E_VALS}(undef, g)

    # TODO there is a more efficient method for this
    for e in edges(g)
        s, d = Tuple(e)
        set_val!(gv, s, d, :, edgeval_initializer(s, d))
    end

    return gv
end

"""
    EdgeValDiGraph{V, E_VALS}([edgeval_initializer,] g::SimpleGraph)
    EdgeValDiGraph{V = eltype(g)}([edgeval_initializer,], g::SimpleGraph, edgeval_types=$(default_edgeval_types))

Construct a `EdgeValDiGraph` with the same structure as `g`.
The optional argument `edgeval_initializer` takes a
function that assigns to each edge (s, d) an edge value. If it is not given,
then each edge gets the value `default_edgeval(edgeval_types)`.
"""
function EdgeValDiGraph{V, E_VALS}(edgeval_initializer::Base.Callable, g::SimpleDiGraph) where {V, E_VALS}

    gv = EdgeValDiGraph{V, E_VALS}(undef, g)

    # TODO there is a more efficient method for this
    for e in edges(g)
        s, d = Tuple(e)
        set_val!(gv, s, d, :, edgeval_initializer(s, d))
    end

    return gv
end

# TODO something wrong with this macro here, so we create the constructors manually
#=
for G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValGraph)
    @eval begin
        $G{V}(edgeval_initializer::Base.Callable, g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
        $G{V, construct_E_VAL(edgeval_types)}(edgeval_initializer, g)

        $G{}(edgeval_initializer::Base.Callable, g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
            $G{eltype(g)}(edgeval_initializer, g, edgeval_types)

        $G{V, E_VALS}(g::AbstractGraph) where {V, E_VALS} =
            $G{V, E_VALS}((s, d) -> default_edgeval(tuple_of_types(E_VAL)), g)

        $G{V}(g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
            $G{V, construct_E_VAL(edgeval_types)}(g)

        $G{}(g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
            $G{eltype(g)}(g)
    end
end
=#
EdgeValGraph{V}(edgeval_initializer::Base.Callable, g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
        EdgeValGraph{V, construct_E_VAL(edgeval_types)}(edgeval_initializer, g)

EdgeValGraph{}(edgeval_initializer::Base.Callable, g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValGraph{eltype(g)}(edgeval_initializer, g, edgeval_types)

EdgeValGraph{V, E_VALS}(g::AbstractGraph) where {V, E_VALS} =
    EdgeValGraph{V, E_VALS}((s, d) -> default_edgeval(tuple_of_types(E_VAL)), g)

EdgeValGraph{V}(g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
    EdgeValGraph{V, construct_E_VAL(edgeval_types)}(g)

EdgeValGraph{}(g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValGraph{eltype(g)}(g)

EdgeValOutDiGraph{V}(edgeval_initializer::Base.Callable, g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
        EdgeValOutDiGraph{V, construct_E_VAL(edgeval_types)}(edgeval_initializer, g)

EdgeValOutDiGraph{}(edgeval_initializer::Base.Callable, g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValOutDiGraph{eltype(g)}(edgeval_initializer, g, edgeval_types)

EdgeValOutDiGraph{V, E_VALS}(g::AbstractGraph) where {V, E_VALS} =
    EdgeValOutDiGraph{V, E_VALS}((s, d) -> default_edgeval(tuple_of_types(E_VAL)), g)

EdgeValOutDiGraph{V}(g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
    EdgeValOutDiGraph{V, construct_E_VAL(edgeval_types)}(g)

EdgeValOutDiGraph{}(g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValOutDiGraph{eltype(g)}(g)

EdgeValDiGraph{V}(edgeval_initializer::Base.Callable, g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
        EdgeValDiGraph{V, construct_E_VAL(edgeval_types)}(edgeval_initializer, g)

EdgeValDiGraph{}(edgeval_initializer::Base.Callable, g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValDiGraph{eltype(g)}(edgeval_initializer, g, edgeval_types)

EdgeValDiGraph{V, E_VALS}(g::AbstractGraph) where {V, E_VALS} =
    EdgeValDiGraph{V, E_VALS}((s, d) -> default_edgeval(tuple_of_types(E_VAL)), g)

EdgeValDiGraph{V}(g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V} =
    EdgeValDiGraph{V, construct_E_VAL(edgeval_types)}(g)

EdgeValDiGraph{}(g::AbstractGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValDiGraph{eltype(g)}(g)

