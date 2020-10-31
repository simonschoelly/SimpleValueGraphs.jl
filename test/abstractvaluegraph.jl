using SimpleValueGraphs: hasedgekey, hasedgekey_or_throw

@testset "abstractvaluegraph" begin

@testset "hasedgekey" begin

    @test hasedgekey(EdgeValGraph{Int, Tuple{Int, Int}}, 1)
    @test hasedgekey(EdgeValGraph{Int, Tuple{Int, Int}}, 2)
    @test !hasedgekey(EdgeValGraph{Int, Tuple{Int, Int}}, 3)

    @test hasedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, 1)
    @test hasedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, 2)
    @test !hasedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, 0)
    @test hasedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, :a)
    @test hasedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, :b)
    @test !hasedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, :c)

    g = EdgeValOutDiGraph((s, d) -> (rand(Int), rand(Int)), cycle_digraph(5), edgeval_types=(Int, Int))
    @test hasedgekey(g, 1)
    @test hasedgekey(g, 2)
    @test !hasedgekey(g, 3)

end

@testset "hasedgekey_or_throw" begin

    @test hasedgekey_or_throw(EdgeValGraph{Int, Tuple{Int, Int}}, 1) === nothing
    @test hasedgekey_or_throw(EdgeValGraph{Int, Tuple{Int, Int}}, 2) === nothing
    @test_throws ErrorException hasedgekey_or_throw(EdgeValGraph{Int, Tuple{Int, Int}}, 3)

    g = EdgeValDiGraph((s, d) -> (a=rand(Int), b=rand(Int)), cycle_digraph(5), edgeval_types=(a=Int, b=Int))
    @test hasedgekey_or_throw(g, 1) === nothing
    @test hasedgekey_or_throw(g, 2) === nothing
    @test_throws ErrorException hasedgekey_or_throw(g, -1)
    @test hasedgekey_or_throw(g, :a) === nothing
    @test hasedgekey_or_throw(g, :b) === nothing
    @test_throws ErrorException hasedgekey_or_throw(g, :c)
end


end # testset
