

@testset "operators" begin

@testset "squash" begin

    @test squash(ValGraph(126)) isa ValGraph{Int8}
    @test squash(ValDiGraph(127)) isa ValDiGraph{UInt8}
    @test squash(ValOutDiGraph{UInt8}(255)) isa ValOutDiGraph{Int16} # we try to avoid nv(g) == typemax(eltype(g))

end

end
