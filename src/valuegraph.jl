
#  ======================================================
#  Structures
#  ======================================================

"""
    EdgeValGraph{V <: Integer, E_VALS <: AbstractTuple, E_VALS_C}

A type representing an undirected simple graph with edge values.

The element type `V` specifies the type of the vertex indices and `E_VAL`
specifies the type of the edge values. User should usually not specify `E_VAL_C`
by themself but rather let a constructor do that.
"""
mutable struct EdgeValGraph{  V <: Integer,
                            E_VALS <: AbstractTuple,
                            E_VALS_C
                         } <: AbstractEdgeValGraph{V, E_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    edgevals::E_VALS_C
end

"""
    EdgeValOutDiGraph{V <: Integer, E_VAL <: AbstractTuple, E_VAL_C}

A type representing a directed simple graph with edge values.

The element type `V` specifies the type of the vertex indices and `E_VAL`
specifies the type of the edge values. User should usually not specify `E_VAL_C`
by themself but rather let a constructor do that.
"""
mutable struct EdgeValOutDiGraph{ V <: Integer,
                                E_VALS <: AbstractTuple,
                                E_VALS_C
                              } <: AbstractEdgeValGraph{V, E_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    edgevals::E_VALS_C
end


"""
    EdgeValDiGraph{V <: Integer, E_VAL <: AbstractTuple, E_VAL_C}

A type representing a directed simple graph with edge values.

The element type `V` specifies the type of the vertex indices and `E_VAL`
specifies the type of the edge values. User should usually not specify `E_VAL_C`
but rather let a constructor do that.
"""
mutable struct EdgeValDiGraph{    V <: Integer,
                                E_VALS <: AbstractTuple,
                                E_VALS_C
                           } <: AbstractEdgeValGraph{V, E_VALS}

    ne::Int
    fadjlist::Adjlist{V}
    badjlist::Adjlist{V}
    edgevals::E_VALS_C
    redgevals::E_VALS_C
end

#  ======================================================
#  Constructors
#  ======================================================

# TODO this helpers maybe belong somewhere else and need a better name
construct_E_VAL(edgeval_types::Tuple) = Tuple{ (T for T in edgeval_types)... }
construct_E_VAL(edgeval_types::NamedTuple) =
    NamedTuple{ Tuple(typeof(edgeval_types).names), Tuple{ (T for T in edgeval_types)... }}

const default_edgeval_types = (weight=Float64,)

function create_edgevals(n, E_VAL::Type{<:Tuple}) 
    return Tuple( Adjlist{T}(n) for T in E_VAL.types )
end

function create_edgevals(n, E_VAL::Type{<:NamedTuple}) 
    return NamedTuple{Tuple(E_VAL.names)}(Tuple( Adjlist{T}(n) for T in E_VAL.types ))
end


#  ------------------------------------------------------
#  Constructors for empty graphs
#  ------------------------------------------------------

"""
    EdgeValGraph{V = $default_eltype}(n, edgeval_types=$(default_edgeval_types))
    EdgeValGraph{V, E_VAL}(n)

Construct a `EdgeValGraph` with `n` vertices and 0 edges with of types
`edgeval_types`.

If omitted, the element type `V` is $(default_eltype).
"""
function EdgeValGraph{V, E_VAL}(n::Integer) where {V <: Integer, E_VAL <: AbstractTuple}

    fadjlist = Adjlist{V}(n)
    edgevals = create_edgevals(n, E_VAL)
    E_VAL_C = typeof(edgevals)

    return EdgeValGraph{V, E_VAL, E_VAL_C}(0, fadjlist, edgevals)
end

"""
    EdgeValOutDiGraph{V = $default_eltype}(n, edgeval_types=$(default_edgeval_types))
    EdgeValOutDiGraph{V, E_VALS}(n)

Construct a `EdgeValOutDiGraph` with `n` vertices and 0 edges of types
`edgeval_types`.
If omitted, the element type `V` is $(default_eltype).

"""
function EdgeValOutDiGraph{V, E_VAL}(n::Integer) where {V<:Integer, E_VAL}

    fadjlist = Adjlist{V}(n)
    edgevals = create_edgevals(n, E_VAL)
    E_VAL_C = typeof(edgevals)

    return EdgeValOutDiGraph{V, E_VAL, E_VAL_C}(0, fadjlist, edgevals)
end


"""
    EdgeValDiGraph{V = $default_eltype}(n, edgeval_types=$(default_edgeval_types))
    EdgeValDiGraph{V, E_VALS}(n)

Construct a `EdgeValDiGraph` with `n` vertices and 0 edges with value-types
`edgeval_types`.

If omitted, the element type `V` is $(default_eltype).
"""
function EdgeValDiGraph{V, E_VAL}(n::Integer) where {V<:Integer, E_VAL}
    fadjlist = Adjlist{V}(n)
    badjlist = Adjlist{V}(n)
    edgevals = create_edgevals(n, E_VAL)
    redgevals = create_edgevals(n, E_VAL)
    E_VAL_C = typeof(edgevals)

    return EdgeValDiGraph{V, E_VAL, E_VAL_C}(
                0, fadjlist, badjlist, edgevals, redgevals)
end


for G in (:EdgeValGraph, :EdgeValOutDiGraph, :EdgeValDiGraph)
    @eval function $G(n, edgeval_types::AbstractTupleOfTypes=default_edgeval_types)
        E_VAL = construct_E_VAL(edgeval_types)
        return $G{default_eltype, E_VAL}(n)
    end

    @eval function $G{V}(n, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) where {V <: Integer}
        E_VAL = construct_E_VAL(edgeval_types)
        return $G{V, E_VAL}(V(n))
    end
end





#  ------------------------------------------------------
#  Constructor from other graphs
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
    EdgeValGraph{V, construct_E_VAL(edgeval_types)}(undef, g)

EdgeValOutDiGraph(::UndefInitializer, g::SimpleDiGraph, edgeval_types::AbstractTupleOfTypes=default_edgeval_types) =
    EdgeValGraph{eltype(g)}(undef, g, edgeval_types)



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
        set_edgevals!(gv, s, d, allkeys, edgeval_initializer(s, d))
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
        set_edgevals!(gv, s, d, allkeys, edgeval_initializer(s, d))
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
        set_edgevals!(gv, s, d, allkeys, edgeval_initializer(s, d))
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



#  ------------------------------------------------------
#  show
#  ------------------------------------------------------

has_named_edgevals(g::AbstractEdgeValGraph{ <: Any, <: NamedTuple}) = true
has_named_edgevals(g::AbstractEdgeValGraph{ <: Any, <: Tuple}) = false

# TODO this looks kind of ugly
function Base.show(io::IO, g::AbstractEdgeValGraph{V, E_VALS}) where {V, E_VALS}
    nvg = Int(nv(g))
    neg = ne(g)
    dir = is_directed(g) ? "directed" : "undirected"
    name = string(nameof(typeof(g)))

    types = tuple_of_types(E_VALS)

    edgevalues_string = if g isa ZeroEdgeValGraph
        "with no edge values"
    elseif g isa OneEdgeValGraph
        if has_named_edgevals(g)
            "with named edge values of type $types"
        else
            "with edge values of type $types"
        end
    else
        if has_named_edgevals(g)
            "with multiple named edge values of types $types"
        else
            "with multiple edge values of types $types"
        end

    end

    println(io, "{$nvg, $neg} $dir $name{$V} graph $edgevalues_string.")
end

# =========================================================
# Interface
# =========================================================

#  ------------------------------------------------------
#  add_edge!
#  ------------------------------------------------------

"""
    add_edge!(g::AbstractEdgeValGraph{V, E_VALS}, s, d, value=default_edgeval(E_VALS))

Add an edge `e = (s, d, [value])` to a graph `g` and set the edge value.

Return `true` if the edge was added successfully, otherwise return `false`.
If the edge already exists, return `false` but still change the edge value.
"""
function add_edge! end

function LG.add_edge!(g::EdgeValGraph{V, E_VALS},
                   s::Integer,
                   d::Integer,
                   values::E_VALS=default_edgeval(E_VALS)) where {V, E_VALS}

    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds

    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_values_for_index!(edgevals, s, index, values)
        s == d && return false # selfloop
        index = searchsortedfirst(g.fadjlist[d], s)
        set_values_for_index!(edgevals, d, index, values)
        return false
    end

    insert!(list, index, d)
    insert_values_for_index!(edgevals, s, index, values)
    g.ne += 1

    s == d && return true # selfloop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    insert_values_for_index!(edgevals, d, index, values)
    return true # edge successfully added
end

function LG.add_edge!(g::EdgeValOutDiGraph{V, E_VALS},
                   s::Integer,
                   d::Integer,
                   value::E_VALS=default_edgeval(E_VALS)) where {V, E_VALS}

    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_values_for_index!(edgevals, s, index, value)
        return false
    end

    insert!(list, index, d)
    insert_values_for_index!(edgevals, s, index, value)
    g.ne += 1
    return true # edge successfully added
end

function LG.add_edge!(g::EdgeValDiGraph{V, E_VALS},
                   s::Integer,
                   d::Integer,
                   value::E_VALS=default_edgeval(E_VALS)) where {V, E_VALS}
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        # edge already there, replace value, but return false
        set_values_for_index!(g.edgevals, s, index, value)
        return false
    end

    insert!(list, index, d)
    insert_values_for_index!(g.edgevals, s, index, value)
    g.ne += 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    set_values_for_index!(g.redgevals, d, index, value)

    return true # edge successfully added
end

#  ------------------------------------------------------
#  rem_edge!
#  ------------------------------------------------------

function LG.rem_edge!(g::EdgeValGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_values_for_index!(edgevals, s, index)

    g.ne -= 1
    s == d && return true # self-loop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    delete_values_for_index!(edgevals, d, index)

    return true
end

function LG.rem_edge!(g::EdgeValOutDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    edgevals = g.edgevals
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_values_for_index!(edgevals, s, index)

    g.ne -= 1
    return true
end


function LG.rem_edge!(g::EdgeValDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false
    deleteat!(list, index)
    delete_values_for_index!(g.edgevals, s, index)

    g.ne -= 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    delete_values_for_index!(g.redgevals, d, index)

    return true
end

#  ------------------------------------------------------
#  has_edge
#  ------------------------------------------------------

"""
    has_edge!(g::AbstractEdgeValGraph, s, d)

Return `true` if `g` has an edge from node `s` to `d`.
"""
function has_edge end

function LG.has_edge(g::EdgeValGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        d = s
        list_s = list_d
    end
    return LightGraphs.insorted(d, list_s)
end

function LG.has_edge(g::EdgeValOutDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_s = g.fadjlist[s]

    return LightGraphs.insorted(d, list_s)
end

function LG.has_edge(g::EdgeValDiGraph, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false # edge out of bounds
    @inbounds list_fadj = g.fadjlist[s]
    @inbounds list_badj = g.badjlist[d]
    if length(list_fadj) > length(list_badj)
        d = s
        list_fadj = list_badj
    end
    return LightGraphs.insorted(d, list_fadj)
end


#  ------------------------------------------------------
#  get_edgevals
#  ------------------------------------------------------

get_edgevals(g::OneEdgeValGraph, s::Integer, d::Integer) =
    get_edgevals(g, s, d, 1)

function get_edgevals(
            g::AbstractEdgeValGraph{V, E_VALS},
            s::Integer,
            d::Integer,
            key::Symbol) where {V, E_VALS}

    return get_edgevals(g, s, d, Base.fieldindex(E_VALS, key))
end
    

# TODO more specific error

function get_edgevals(g::EdgeValGraph, s::Integer, d::Integer, key::Integer)

    validkey_or_throw(g, key) # TODO might be sufficient to just check index

    verts = vertices(g)
    
    (s in verts && d in verts) || error("No such edge")
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end

    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    error("No such edge")
end

function get_edgevals(g::EdgeValOutDiGraph, s::Integer, d::Integer, key::Integer)

   validkey_or_throw(g, key)

    verts = vertices(g)
    (s in verts && d in verts) || error("No such edge")
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    error("No such edge")
end

function get_edgevals(g::EdgeValDiGraph, s::Integer, d::Integer, key::Integer)

    validkey_or_throw(g, key)

    verts = vertices(g)
    (s in verts && d in verts) || error("No such edge")
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    error("No such edge")
end

get_edgevals_or(g::OneEdgeValGraph, s::Integer, d::Integer, alternative) =
    get_edgevals_or(g, s, d, 1, alternative)

function get_edgevals_or(
            g::AbstractEdgeValGraph{V, E_VALS},
            s::Integer,
            d::Integer,
            key::Symbol,
            alternative) where {V, E_VALS}

    return get_edgevals_or(g, s, d, Base.fieldindex(E_VALS, key), alternative)
end


function get_edgevals_or(g::EdgeValGraph, s::Integer, d::Integer, key::Integer, alternative)

    validkey_or_throw(g, key)

    verts = vertices(g)
    
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end

    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    return alternative
end

function get_edgevals_or(g::EdgeValOutDiGraph, s::Integer, d::Integer, key::Integer, alternative)

    validkey_or_throw(g, key)

    verts = vertices(g)
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    return alternative
end

function get_edgevals_or(g::EdgeValDiGraph, s::Integer, d::Integer, key::Integer, alternative)

    validkey_or_throw(g, key)

    verts = vertices(g)
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return g.edgevals[key][s][index]
    end
    return alternative
end





"""
    get_edgevals(g::AbstractEdgeValGraph, s, d, allkeys)

"""
function get_edgevals(g::EdgeValGraph{V, E_VAL}, s::Integer, d::Integer, ::AllKeys) where {V, E_VAL}

    verts = vertices(g)
    (s in verts && d in verts) || error("Values not found")
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return values_for_index(g.edgevals, E_VAL, s, index)
    end
    (s in verts && d in verts) || error("Values not found")
end

function get_edgevals(g::EdgeValOutDiGraph{V, E_VAL}, s::Integer, d::Integer, ::AllKeys) where {V, E_VAL}

    verts = vertices(g)
    (s in verts && d in verts) ||  error("Values not found")

    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return values_for_index(g.edgevals, E_VAL, s, index)
    end
    error("Values not found")
end

# TODO could probably be made faster by checking the shorter list
function get_edgevals(g::EdgeValDiGraph{V, E_VAL}, s::Integer, d::Integer, ::AllKeys) where
{V, E_VAL}

    verts = vertices(g)
    (s in verts && d in verts) || error("Values not found")

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return values_for_index(g.edgevals, E_VAL, s, index)
    end
    error("Values not found")
end

function get_edgevals_or(g::EdgeValGraph{V, E_VAL}, s::Integer, d::Integer, ::AllKeys, alternative) where {V, E_VAL}

    verts = vertices(g)
    (s in verts && d in verts) || return alternative
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        s, d = d, s
        list_s = list_d
    end
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return values_for_index(g.edgevals, E_VAL, s, index)
    end
    return alternative
end

function get_edgevals_or(g::EdgeValOutDiGraph{V, E_VAL}, s::Integer, d::Integer, ::AllKeys, alternative) where {V, E_VAL}

    verts = vertices(g)
    (s in verts && d in verts) ||  return alternative

    @inbounds list_s = g.fadjlist[s]
    index = searchsortedfirst(list_s, d)
    @inbounds if index <= length(list_s) && list_s[index] == d
        return values_for_index(g.edgevals, E_VAL, s, index)
    end
    return alternative
end

# TODO could probably be made faster by checking the shorter list
function get_edgevals_or(g::EdgeValDiGraph{V, E_VAL}, s::Integer, d::Integer, ::AllKeys, alternative) where
{V, E_VAL}

    verts = vertices(g)
    (s in verts && d in verts) || return alternative

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds if index <= length(list) && list[index] == d
        return values_for_index(g.edgevals, E_VAL, s, index)
    end
    return alternative
end


#  ------------------------------------------------------
#  set_edgevals!
#  ------------------------------------------------------

set_edgevals!(g::OneEdgeValGraph, s::Integer, d::Integer, value) =
    set_edgevals!(g, s, d, 1, value)

set_edgevals!(g::AbstractEdgeValGraph{V, E_VALS}, s::Integer, d::Integer, key::Symbol, value) where {V, E_VALS} =
    set_edgevals!(g, s, d, Base.fieldindex(E_VALS, key), value)


function set_edgevals!(g::EdgeValGraph, s::Integer, d::Integer, key::Integer, value)

    validkey_or_throw(g, key)

    verts = vertices(g)
    edgevals = g.edgevals[key]

    (s in verts && d in verts) || return false

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds edgevals[s][index] = value

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    @inbounds edgevals[d][index] = value

    return true
end

function set_edgevals!(g::EdgeValOutDiGraph, s::Integer, d::Integer, key::Integer, value)

    validkey_or_throw(g, key)

    verts = vertices(g)
    edgevals = g.edgevals[key]

    (s in verts && d in verts) || return false

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds edgevals[s][index] = value

    return true

end

function set_edgevals!(g::EdgeValDiGraph, s::Integer, d::Integer, key::Integer, value)

    validkey_or_throw(g, key)

    verts = vertices(g)
    edgevals = g.edgevals[key]

    (s in verts && d in verts) || return false

    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    @inbounds edgevals[s][index] = value

    redgevals = g.redgevals[key]

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    @inbounds redgevals[d][index] = value

    return true
end


"""
    set_edgevals!(g::AbstractEdgeValGraph, s, d, allkeys, values)
    set_edgevals!(g::AbstractEdgeValGraph, e, allkeys, values)
Set the values of the edge `e: s -> d` to `values`. Return `true` if such an edge exists and
`false` otherwise.
"""
function set_edgevals!(g::EdgeValGraph, s::Integer, d::Integer, ::AllKeys, values)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_values_for_index!(edgevals, s, index, values)

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    set_values_for_index!(edgevals, d, index, values)

    return true
end

function set_edgevals!(g::EdgeValOutDiGraph, s::Integer, d::Integer, ::AllKeys, values)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_values_for_index!(edgevals, s, index, values)

    return true
end

function set_edgevals!(g::EdgeValDiGraph, s::Integer, d::Integer, ::AllKeys, values)
    verts = vertices(g)
    (s in verts && d in verts) || return false
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds index <= length(list) && list[index] == d || return false
    edgevals = g.edgevals
    set_values_for_index!(g.edgevals, s, index, values)

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    set_values_for_index!(g.redgevals, d, index, values)

    return true
end

#=
set_edgevals!(g::AbstractEdgeValGraph, e::SimpleEdge, u) = set_edgevals!(g, src(e), dst(e), u)
=#

#  ------------------------------------------------------
#  is_directed
#  ------------------------------------------------------

LG.is_directed(::Type{<:EdgeValGraph}) = false
LG.is_directed(::Type{<:EdgeValOutDiGraph}) = true
LG.is_directed(::Type{<:EdgeValDiGraph}) = true

#  ------------------------------------------------------
#  outneighbors
#  ------------------------------------------------------

LG.outneighbors(g::AbstractEdgeValGraph, v::Integer) = g.fadjlist[v]

#  ------------------------------------------------------
#  inneighbors
#  ------------------------------------------------------

LG.inneighbors(g::EdgeValGraph, v::Integer) = outneighbors(g, v)
LG.inneighbors(g::EdgeValDiGraph, v::Integer) = g.badjlist[v]

#  ------------------------------------------------------
#  outedgevals
#  ------------------------------------------------------

"""
    outedgevals(g::AbstractEdgeValGraph, v [, key])

Return an iterator of edge values of outgoing edges from `v` to its neighbors.

If `g` has multiple edge values, the key cannot be omitted.
The order of the neighbors is the same as for `outneighbors(g, v)`.
"""
outedgevals(g::OneEdgeValGraph, v::Integer) = outedgevals(g, v, 1)

outedgevals(g::EdgeValGraph, v::Integer, key) = g.fadjlist[key]


#  ------------------------------------------------------
#  inedgevals
#  ------------------------------------------------------

"""
    inedgevals(g::EdgeValGraph, v [, key])

Return an iterator of edge values of incoming edges the neighbors of `v`.

If `g` has multiple edge values, the key cannot be omitted.
The order of the neighbors is the same as for `inneighbors(g, v)`.

This function does not work for graphs of the type `EdgeValOutDiGraph`.
"""
inedgevals(g::OneEdgeValGraph, v::Integer) = inedgevals(g, v, 1)

inedgevals(g::EdgeValGraph, v::Integer, key) = outedgevals(g, v, key)

inedgevals(g::EdgeValDiGraph, v::Integer, key) = g.redgevals[key]


# ====================================================================
# Iterators
# ====================================================================


@inline function Base.iterate(eit::ValEdgeIter{<:EdgeValGraph{V, E_VAL}}, state=(one(V), 1) ) where {V, E_VAL}
    g = eit.g
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    n = V(nv(g))
    u, i = state

    @inbounds while u < n
        list_u = fadjlist[u]
        if i > length(list_u)
            u += one(u)
            i = searchsortedfirst(fadjlist[u], u)
            continue
        end
        e = ValEdge(u, list_u[i], values_for_index(edgevals, E_VAL, u, i))
        state = (u, i + 1)
        return e, state
    end

    # i > length(fadjlist[end]) || fadlist[end][i] == n

    @inbounds (n == 0 || i > length(fadjlist[n])) && return nothing

    e = ValEdge(n, n, values_for_index(edgevals, E_VAL, u, i))
    state = (u, i + 1)
    return e, state
end

function Base.iterate(
            iter::ValEdgeIter{<:Union{EdgeValOutDiGraph{V, E_VAL}, EdgeValDiGraph{V, E_VAL}}},
            state=(one(V), 1)
    ) where {V, E_VAL}

    g = iter.g
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    n = V(nv(g))
    u, i = state

    @inbounds while u <= n
        if i > length(fadjlist[u])
            u == n && return nothing

            u += one(u)
            i = 1
            continue
        end
        e = ValDiEdge(u, fadjlist[u][i], values_for_index(edgevals, E_VAL, u, i))
        return e, (u, i + 1)
    end

    return nothing
end


