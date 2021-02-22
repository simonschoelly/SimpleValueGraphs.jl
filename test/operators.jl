

@testset "operators" begin

@testset "squash" begin

    @test squash(ValGraph(126)) isa ValGraph{Int8}
    @test squash(ValDiGraph(127)) isa ValDiGraph{UInt8}
    @test squash(ValOutDiGraph{UInt8}(255)) isa ValOutDiGraph{Int16} # we try to avoid nv(g) == typemax(eltype(g))

end

@testset "reverse" begin

    g1 = DummyValGraph(ValGraph(2, edgeval_types=(a=String,)))
    add_edge!(g1, 1, 2, val="xyz")
    @test reverse(g1) === g1

    @test is_directed(typeof(SimpleValueGraphs.Reverse(g1))) == false

    g2 = DummyValGraph(ValDiGraph(5, vertexval_types=(a=Int,), vertexval_init=v -> (v,),
                                  edgeval_types=(b=String,), graphvals=(c=100,)))
    add_edge!(g2, 1, 2, val="abc")
    add_edge!(g2, 2, 1, val="def")
    add_edge!(g2, 3, 4, val="ghi")
    add_edge!(g2, 4, 4, val="jkl")

    rg = reverse(g2)

    @test reverse(rg) == g2

    @test is_directed(typeof(g2)) == true

    @test rg isa SimpleValueGraphs.Reverse
    @test rg.graph === g2

    @test nv(rg) == nv(g2) == 5
    add_vertex!(rg, val=6)
    @test nv(rg) == nv(g2) == 6

    @test get_vertexval(rg, 6) == get_vertexval(g2, 6) == 6
    set_vertexval!(rg, 6, 600)
    @test get_vertexval(rg, 6, :) == get_vertexval(g2, 6, :) == (a=600,)
    @test get_vertexval(rg, 6, 1) == get_vertexval(g2, 6, 1) == 600
    @test get_vertexval(rg, 6, :a) == get_vertexval(g2, 6, :a) == 600

    @test get_edgeval(rg, 1, 2) == get_edgeval(g2, 2, 1) == "def"
    set_edgeval!(rg, 1, 2, :, ("DEF",))
    @test get_edgeval(rg, 1, 2, :) == get_edgeval(g2, 2, 1, :) == (b="DEF",)
    set_edgeval!(rg, 2, 1, 1, "ABC")
    @test get_edgeval(rg, 2, 1, 1) == get_edgeval(g2, 1, 2, 1) == "ABC"
    set_edgeval!(rg, 4, 4, :b, "JKL")
    @test get_edgeval(rg, 4, 4, :b) == get_edgeval(g2, 4, 4, :b) == "JKL"

    @test ne(rg) == ne(g2) == 4
    add_edge!(rg, 1, 6, val="mno")
    @test get_edgeval(rg, 1, 6) == get_edgeval(g2, 6, 1) == "mno"
    @test has_edge(rg, 1, 6)
    @test has_edge(g2, 6, 1)
    @test !has_edge(rg, 6, 1)
    @test !has_edge(g2, 1, 6)
    @test ne(rg) == ne(g2) == 5

    @test get_graphval(rg) == get_graphval(g2) == 100
    set_graphval!(rg, 1, 200)
    @test get_graphval(rg, 1) == get_graphval(g2, 1) == 200
    set_graphval!(rg, :c, 300)
    @test get_graphval(rg, :c) == get_graphval(g2, :c) == 300
    set_graphval!(rg, :, (300,))
    @test get_graphval(rg, :) == get_graphval(g2, :) == (c=300,)

end



end
