using SimpleValueGraphs: is_validedgekey, validedgekey_or_throw

@testset "abstractvaluegraph" begin

@testset "is_validedgekey" begin

    @test is_validedgekey(EdgeValGraph{Int, Tuple{Int, Int}}, 1)
    @test is_validedgekey(EdgeValGraph{Int, Tuple{Int, Int}}, 2)
    @test !is_validedgekey(EdgeValGraph{Int, Tuple{Int, Int}}, 3)

    @test is_validedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, 1)
    @test is_validedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, 2)
    @test !is_validedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, 0)
    @test is_validedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, :a)
    @test is_validedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, :b)
    @test !is_validedgekey(EdgeValDiGraph{Int8, NamedTuple{(:a, :b), Tuple{Int, Int}}}, :c)

    g = EdgeValOutDiGraph((s, d) -> (rand(Int), rand(Int)), cycle_digraph(5), edgeval_types=(Int, Int))
    @test is_validedgekey(g, 1)
    @test is_validedgekey(g, 2)
    @test !is_validedgekey(g, 3)

end

@testset "validedgekey_or_throw" begin

    @test validedgekey_or_throw(EdgeValGraph{Int, Tuple{Int, Int}}, 1) === nothing
    @test validedgekey_or_throw(EdgeValGraph{Int, Tuple{Int, Int}}, 2) === nothing
    @test_throws ErrorException validedgekey_or_throw(EdgeValGraph{Int, Tuple{Int, Int}}, 3)

    g = EdgeValDiGraph((s, d) -> (a=rand(Int), b=rand(Int)), cycle_digraph(5), edgeval_types=(a=Int, b=Int))
    @test validedgekey_or_throw(g, 1) === nothing
    @test validedgekey_or_throw(g, 2) === nothing
    @test_throws ErrorException validedgekey_or_throw(g, -1)
    @test validedgekey_or_throw(g, :a) === nothing
    @test validedgekey_or_throw(g, :b) === nothing
    @test_throws ErrorException validedgekey_or_throw(g, :c)
end


end # testset