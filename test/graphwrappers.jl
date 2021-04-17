

# test graph wrapper for testing @wrap_graph!,
# should forward everything to the wrapped graph
struct TestGraphWrapper{V <: Integer, V_VALS, E_VALS, G_VALS, GI <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}} <: AbstractValGraph{V, V_VALS, E_VALS, G_VALS}

    inner::GI
end

SimpleValueGraphs.wrapped_graph(gw::TestGraphWrapper) = gw.inner

SimpleValueGraphs.wrapped_graph_type(::Type{<:TestGraphWrapper{V, V_VALS, E_VALS, G_VALS, GI}}) where {V, V_VALS, E_VALS, G_VALS, GI} = GI

SimpleValueGraphs.@wrap_graph! TestGraphWrapper include=[ne, outneighbors, inneighbors, outedgevals, inedgevals, edges]

@testset "graph wrapper" begin

gi = ValDiGraph{Int8}(
        4,
        vertexval_types=(a=Int, b=String),
        vertexval_init=v -> (a=v, b="$v"),
        edgeval_types=(c=String, d=Float64),
        graphvals=(e='x', f="y")
)
add_edge!(gi, 1, 2, ("1-2", 1.2))
add_edge!(gi, 2, 1, ("2-1", 2.1))
add_edge!(gi, 1, 4, ("1-4", 1.4))
add_edge!(gi, 4, 4, ("4-4", 4.4))

gw = TestGraphWrapper(gi)

@test nv(gw) == nv(gi)

@test is_directed(typeof(gw)) == is_directed(typeof(gi))

@test has_edge(gw, 1, 2) == has_edge(gi, 1, 2)
@test has_edge(gw, 1, 3) == has_edge(gi, 1, 3)

@test get_graphval(gw, 1) == get_graphval(gi, 1)
@test get_graphval(gw, :f) == get_graphval(gi, :f)
@test get_graphval(gw, :) == get_graphval(gi, :)

@test get_vertexval(gw, 1, 1) == get_vertexval(gi, 1, 1)
@test get_vertexval(gw, 2, :a) == get_vertexval(gi, 2, :a)
@test get_vertexval(gw, 3, :) == get_vertexval(gi, 3, :)

@test get_edgeval(gw, 1, 2, 1) == get_edgeval(gi, 1, 2, 1)
@test get_edgeval(gw, 2, 1, :d) == get_edgeval(gi, 2, 1, :d)
@test get_edgeval(gw, 4, 4, :) == get_edgeval(gi, 4, 4, :)

# TODO tests for modifiers

@test ne(gw) == ne(gi)

@test outneighbors(gw, 1) == outneighbors(gi, 1)
@test outneighbors(gw, 3) == outneighbors(gi, 3)

@test inneighbors(gw, 1) == inneighbors(gi, 1)
@test inneighbors(gw, 3) == inneighbors(gi, 3)

@test outedgevals(gw, 1, 2) == outedgevals(gi, 1, 2)
@test outedgevals(gw, 2, :c) == outedgevals(gi, 2, :c)
@test outedgevals(gw, 4, :) == outedgevals(gi, 4, :)

@test inedgevals(gw, 1, 2) == inedgevals(gi, 1, 2)
@test inedgevals(gw, 2, :c) == inedgevals(gi, 2, :c)
@test inedgevals(gw, 4, :) == inedgevals(gi, 4, :)

@test edges(gw) == edges(gi)
@test edges(gw, :) == edges(gi, :)

end # testset
