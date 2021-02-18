
@testset "get_vertexval(g, v, ::Symbol)" begin

    g1 = ValGraph{Int8}(2, vertexval_types=(a=Int, b=Bool), vertexval_init=v -> (v, iseven(v)))
    g2 = ValOutDiGraph{Int16}(2, vertexval_types=(a=Int, b=Bool), vertexval_init=v -> (v, iseven(v)))
    g3 = ValDiGraph{UInt8}(2, vertexval_types=(a=Int, b=Bool), vertexval_init=v -> (v, iseven(v)))

    @test get_vertexval(g1, 1, :a) == 1
    @test get_vertexval(g1, Int8(2), :b) == true

    @test get_vertexval(g2, UInt8(1), :b) == false
    @test get_vertexval(g2, 2, :a) == 2

    @test get_vertexval(g3, 1, :b) == false
    @test get_vertexval(g3, 2, :a) == 2
end

