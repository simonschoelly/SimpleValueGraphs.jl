

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

    g2 = DummyValGraph(ValDiGraph(5, vertexval_types=(Int,), vertexval_init=v -> (v,),
                                  edgeval_types=(a=String,), graphvals=(b=Int,)))
    add_edge!(g2, 1, 2, val="abc")
    add_edge!(g2, 2, 1, val="def")
    add_edge!(g2, 3, 4, val="ghi")
    add_edge!(g2, 4, 4, val="jkl")

    rg = reverse(g2)

    @test rg isa SimpleValueGraphs.Reverse
    @test rg.graph === g2

    @test nv(rg) == nv(g2) == 5
    add_vertex!(rg, val=6)
    @test nv(rg) == nv(g2) == 6

    @test get_vertexval(rg, 6, :) == get_vertexval(g2, 6, :) == (6,)
    set_vertexval!(rg, 6, 600)
    @test get_vertexval(rg, 6, :) == get_vertexval(g2, 6, :) == (600,)

end



end
