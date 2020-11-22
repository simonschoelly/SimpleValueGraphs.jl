
# ======================================================
# Type definitions
# ======================================================

abstract type AbstractValEdge{V <: Integer, E_VALS <: AbstractTuple} <: AbstractEdge{V} end


"""
    ValEdge{V, E_VALS} <: AbstractValEdge{V}

A data structure representing an undirected edge with multiple values.
"""
struct ValEdge{V<:Integer, E_VALS <: AbstractTuple} <: AbstractValEdge{V, E_VALS}
    src::V
    dst::V
    values::E_VALS


    function ValEdge{V, E_VALS}(src, dst, values) where {V, E_VALS}

        src, dst = minmax(src, dst) # TODO maybe use a branchless operator
        return new{V, E_VALS}(src, dst, values)
    end
end


"""
    ValDiEdge{V, E_VALS} <: AbstractValEdge{V}

A data structure representing a directed edge with multiple values.
"""
struct ValDiEdge{V<:Integer, E_VALS <: AbstractTuple} <: AbstractValEdge{V, E_VALS}
    src::V
    dst::V
    values::E_VALS


    function ValDiEdge{V, E_VALS}(src, dst, values) where {V, E_VALS}

        return new{V, E_VALS}(src, dst, values)
    end
end


# =========================================================
# Constructors
# =========================================================

"""
    ValEdge(s, d[, values])
    ValEdge{V}(s, d[, values])
    ValEdge{V, E_VALS}(s, d, values)

Create a `ValEdge` with source `s`, destination `d` and values `values`.

# Examples
```jldoctest
julia> e = ValEdge(1, 2, ('A',))
ValEdge 1 -- 2 with value A

julia> e = ValEdge(1, 2, ())
ValEdge 1 -- 2

julia> e = ValEdge(1,2, (first = 1, second = "2"))
ValEdge 1 -- 2 with values (first = 1, second = "2")
```
"""
function ValEdge(src::Integer, dst::Integer, values::E_VALS=()) where {E_VALS}

    src, dst = promote(src, dst)
    return ValEdge{typeof(src), E_VALS}(src, dst, values)
end

ValEdge{V}(s, d, values=()) where {V} = ValEdge{V, typeof(values)}(s, d, values)


"""
    ValDiEdge(s, d[, values])
    ValDiEdge{V}(s, d[, values])
    ValDiEdge{V, E_VALS}(s, d, values)

Create a `ValDiEdge` with source `s`, destination `d` and values `values`.

# Examples
```jldoctest
julia> e = ValDiEdge(1, 2, ('A',))
ValDiEdge 1 -> 2 with value A

julia> e = ValDiEdge(1, 2, ())
ValDiEdge 1 -> 2

julia> e = ValDiEdge(1,2, (first = 1, second = "2"))
ValDiEdge 1 -> 2 with values (first = 1, second = "2")
```
"""
function ValDiEdge(src::Integer, dst::Integer, values::E_VALS=()) where {E_VALS}

    src, dst = promote(src, dst)
    return ValDiEdge{typeof(src), E_VALS}(src, dst, values)
end

ValDiEdge{V}(s, d, values=()) where {V} = ValDiEdge{V, typeof(values)}(s, d, values)

# =========================================================
# Interface
# =========================================================

#  ------------------------------------------------------
#  src & dst
#  ------------------------------------------------------

LG.src(e::AbstractValEdge) = e.src
LG.dst(e::AbstractValEdge) = e.dst


#  ------------------------------------------------------
#  get_edgeval
#  ------------------------------------------------------

"""
    get_edgeval(e::AbstractValEdge, :)

Return the values attached to the edge `e`.

# Examples

```jldoctest
julia> e = ValEdge(1, 2, ("xyz", 123));
julia> get_edgeval(e, :)
("xyz", 123)

julia> e = ValDiEdge(1, 2, (weight=2.5,));
julia> get_edgeval(e, :)
(weight = 2.5,)
```
"""
get_edgeval(e::AbstractValEdge, ::Colon) = e.values

"""
    get_edgeval(e::AbstractValEdge, key)

Return the value attached to the edge `e` for the key `key`.

# Examples
```jldoctest
julia> e = ValEdge(1, 2, (a=11.0, ));

julia> get_edgeval(e, 1) # use integer key
11.0

julia> get_edgeval(e, :a) # use symbolic key
11.0

```
"""
get_edgeval(e::AbstractValEdge, key) = e.values[key]


#  ------------------------------------------------------
#  reverse
#  ------------------------------------------------------

LG.reverse(e::ValEdge) = e
LG.reverse(e::ValDiEdge) = ValDiEdge(dst(e), src(e), get_edgeval(e, :))


#  ------------------------------------------------------
#  is_directed
#  ------------------------------------------------------

LG.is_directed(::Type{<:ValEdge}) = false
LG.is_directed(::Type{<:ValDiEdge}) = true
LG.is_directed(e::AbstractValEdge) = is_directed(typeof(e))

#  ------------------------------------------------------
#  ==
#  ------------------------------------------------------

==(lhs::ValEdge, rhs::ValEdge) =
    lhs.src == rhs.src && lhs.dst == lhs.dst && lhs.values == rhs.values

==(lhs::ValDiEdge, rhs::ValDiEdge) =
    lhs.src == rhs.src && lhs.dst == lhs.dst && lhs.values == rhs.values


# ======================================================
# show
# ======================================================

function Base.show(io::IO, e::AbstractValEdge)
    isdir = is_directed(e)
    e_keys = keys(get_edgeval(e, :))
    has_symbol_keys = eltype(e_keys) === Symbol

    print(io, isdir ? "ValDiEdge" : "ValEdge")
    arrow = isdir ? "->" : "--"
    print(io, " $(src(e)) $arrow $(dst(e))")

    if length(e_keys) == 1
        print(io, " with value " * (has_symbol_keys ? "$(e_keys[1]) = $(get_edgeval(e, 1))" :
                                                      "$(get_edgeval(e, 1))"))
    elseif length(e_keys) > 1
        print(io, " with values $(get_edgeval(e, :))")
    end

    println(io)
end


