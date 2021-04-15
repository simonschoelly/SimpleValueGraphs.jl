
"""
    wrapped_graph(g::MyGraphWrapper)

Method to implement for creating graph wrapper types.
Should return the graph that is wrapped inside `g`.

### See also
[`wrapped_graph_type`](@ref), [`@wrap_graph!`](@ref)
"""
function wrapped_graph(::AbstractValGraph) end

"""
    wrapped_graph_type{::Type{<:MyGraphWrapper}}

Method to implement for creating graph wrapper types.
Should return the type of the graph that is wrapped inside
a graph wrapper.

### See also
[`wrapped_graph`](@ref), [`@wrap_graph!`](@ref)

"""
function wrapped_graph_type(::Type) end

_DEFAULT_INCLUDE = [
    :nv,
    :is_directed,
    :zero,
    :has_edge,
    :get_graphval,
    :get_vertexval,
    :get_edgeval,
    :set_graphval!,
    :set_vertexval!,
    :set_edgeval!,
    :add_vertex!,
    :rem_vertex!,
    :add_edge!,
    :rem_edge!,
   ]

_EXTRA_INCLUDE = [
    :ne,
]

"""
    @wrap_graph! MyGraphWrapper include=[] exclude=[]

Generate default method implementations for graph wrappers.
These default implementations simply call the wrapped graph. For that, one
needs to implement `wrapped_graph` and `wrapped_graph_type` for the custom graph wrapper.

Methods given as a `Vector` to the keyword argument `excluded` are not created.
By default, methods for the following functions are generated:
$(join(map(s -> '`' * string(s) * '`', _DEFAULT_INCLUDE), ", ")).
Additional method that can be generated are:
$(join(map(s -> '`' * string(s) * '`', _EXTRA_INCLUDE), ", ")).

### See also
[`wrapped_graph`](@ref), [`wrapped_graph_type`](@ref)
"""
macro wrap_graph!(GT, args...)

    functions_to_generate = _DEFAULT_INCLUDE

    # TODO maybe we can somehow assert that GT is something like a type
    # for now we just use an `typeintersect`. If GT is not an `AbstractValGraph`
    # this will simply result in a `Union{}` type
    GT = :(typeintersect(SimpleValueGraphs.AbstractValGraph, $GT))

    for arg in args
        if !(arg isa Expr) ||
                arg.head != :(=) ||
                length(arg.args) != 2 ||
                arg.args[1] ∉ (:include, :exclude) ||
                !(arg.args[2] isa Expr) ||
                arg.args[2].head != :vect

            error("Argument must be of the form `include=[function names...]` or exclude=[function names...]`")
        end
        # TODO we could also fail if there are unknown functions specified in one of the lists
        if arg.args[1] == :include
            include_list = intersect(arg.args[2].args, _EXTRA_INCLUDE)
            union!(functions_to_generate, include_list)
        else
            exclude_list = arg.args[2].args
            setdiff!(functions_to_generate, exclude_list)
        end

    end

    return Expr(:block, map(f -> _generate_wrapped_function!(Val(f), esc(GT)), functions_to_generate)...)
end

function _generate_wrapped_function!(::Val{:nv}, GT)

    return :(SimpleValueGraphs.nv(g::$GT) = nv(wrapped_graph(g)))
end

function _generate_wrapped_function!(::Val{:is_directed}, GT)

    return :(SimpleValueGraphs.is_directed(G::Type{<:$GT}) = is_directed(wrapped_graph_type(G)))
end

function _generate_wrapped_function!(::Val{:zero}, GT)

    return :(SimpleValueGraphs.zero(G::Type{<:$GT}) = zero(wrapped_graph_type(G)))
end

function _generate_wrapped_function!(::Val{:has_edge}, GT)

    return :(SimpleValueGraphs.has_edge(g::$GT, s::Integer, d::Integer) = has_edge(wrapped_graph(g), s, d))
end

function _generate_wrapped_function!(::Val{:add_vertex!}, GT)

    return :(SimpleValueGraphs.add_vertex!(g::$GT, vals) = add_vertex!(wrapped_graph(g), vals))
end

function _generate_wrapped_function!(::Val{:rem_vertex!}, GT)

    return :(SimpleValueGraphs.rem_vertex!(g::$GT, v::Integer) = rem_vertex!(wrapped_graph(g), v))
end

function _generate_wrapped_function!(::Val{:add_edge!}, GT)

    return :(SimpleValueGraphs.add_edge!(g::$GT, s::Integer, d::Integer, vals) = add_edge!(wrapped_graph(g), s, d, vals))
end

function _generate_wrapped_function!(::Val{:rem_edge!}, GT)

    return :(SimpleValueGraphs.rem_edge!(g::$GT, s::Integer, d::Integer) = rem_edge!(wrapped_graph(g), s, d))
end

function _generate_wrapped_function!(::Val{:get_vertexval}, GT)

    return quote
        SimpleValueGraphs.get_vertexval(g::$GT, v::Integer, key::Integer) = get_vertexval(wrapped_graph(g), v, key)
        SimpleValueGraphs.get_vertexval(g::$GT, v::Integer, key::Symbol) = get_vertexval(wrapped_graph(g), v, key)
        SimpleValueGraphs.get_vertexval(g::$GT, v::Integer, ::Colon) = get_vertexval(wrapped_graph(g), v, :)
    end
end

function _generate_wrapped_function!(::Val{:set_vertexval!}, GT)

    return quote
        SimpleValueGraphs.set_vertexval!(g::$GT, v::Integer, key::Integer, value) = set_vertexval!(wrapped_graph(g), v, key, value)
        SimpleValueGraphs.set_vertexval!(g::$GT, v::Integer, key::Symbol, value) = set_vertexval!(wrapped_graph(g), v, key, value)
        SimpleValueGraphs.set_vertexval!(g::$GT, v::Integer, ::Colon, values) = set_vertexval!(wrapped_graph(g), v, :, values)
    end
end

function _generate_wrapped_function!(::Val{:get_edgeval}, GT)

    return quote
        SimpleValueGraphs.get_edgeval(g::$GT, s::Integer, d::Integer, key::Integer) = get_edgeval(wrapped_graph(g), s, d, key)
        SimpleValueGraphs.get_edgeval(g::$GT, s::Integer, d::Integer, key::Symbol) = get_edgeval(wrapped_graph(g), s, d, key)
        SimpleValueGraphs.get_edgeval(g::$GT, s::Integer, d::Integer, ::Colon) = get_edgeval(wrapped_graph(g), s, d, :)
    end
end

function _generate_wrapped_function!(::Val{:set_edgeval!}, GT)

    return quote
        SimpleValueGraphs.set_edgeval!(g::$GT, s::Integer, d::Integer, key::Integer, value) = set_edgeval!(wrapped_graph(g), s, d, key, value)
        SimpleValueGraphs.set_edgeval!(g::$GT, s::Integer, d::Integer, key::Symbol, value) = set_edgeval!(wrapped_graph(g), s, d, key, value)
        SimpleValueGraphs.set_edgeval!(g::$GT, s::Integer, d::Integer, ::Colon, values) = set_edgeval!(wrapped_graph(g), s, d, :, values)
    end
end

function _generate_wrapped_function!(::Val{:get_graphval}, GT)

    return quote
        SimpleValueGraphs.get_graphval(g::$GT, key::Integer) = get_graphval(wrapped_graph(g), key)
        SimpleValueGraphs.get_graphval(g::$GT, key::Symbol) = get_graphval(wrapped_graph(g), key)
        SimpleValueGraphs.get_graphval(g::$GT, ::Colon) = get_graphval(wrapped_graph(g), :)
    end
end

function _generate_wrapped_function!(::Val{:set_graphval!}, GT)

    return quote
        SimpleValueGraphs.set_graphval!(g::$GT, key::Integer, value) = set_graphval!(wrapped_graph(g), key, value)
        SimpleValueGraphs.set_graphval!(g::$GT, key::Symbol, value) = set_graphval!(wrapped_graph(g), key, value)
        SimpleValueGraphs.set_graphval!(g::$GT, ::Colon, values) = set_graphval!(wrapped_graph(g), :, values)
    end
end



function _generate_wrapped_function!(::Val{:ne}, GT)

    return :(SimpleValueGraphs.ne(g::$GT) = ne(wrapped_graph(g)))
end
