@testset "modifiers" begin

@testset "add_edge! 1" begin
    
    g1 = EdgeValGraph{Int, Tuple{Int}}(3)
    # adding first edge succeed
    @test add_edge!(g1, 1, 2, (10, ))
    @test ne(g1) == 1
    @test get_val(g1, 1, 2, 1) == 10
    @test get_val(g1, 2, 1, 1) == 10

    # adding same edge with different value returns false but changes value
    @test !add_edge!(g1, 1, 2, (20, ))
    @test ne(g1) == 1
    @test get_val(g1, 1, 2, 1) == 20
    @test get_val(g1, 2, 1, 1) == 20

    # adding a self-loop works
    @test add_edge!(g1, 1, 1, (30, ))
    @test ne(g1) == 2
    @test get_val(g1, 1, 1, 1) == 30
    @test get_val(g1, 1, 1, 1) == 30

    # another edge, this time higher vertex first
    @test add_edge!(g1, 3, 2, (40, ))
    @test ne(g1) == 3
    @test get_val(g1, 2, 3, 1) == 40
    @test get_val(g1, 3, 2, 1) == 40

    # adding an edge outside of boundaries does nothing
    @test !add_edge!(g1, 1, 4, (50, ))
    @test ne(g1) == 3
    @test !add_edge!(g1, 0, 3, (60, ))
    @test ne(g1) == 3
    @test !add_edge!(g1, -1, -2, (70, ))
    @test ne(g1) == 3
end

@testset "add_edge! 2" begin
    
    g1 = EdgeValDiGraph{Int, NamedTuple{(:a, :b), Tuple{Char, Float64}}}(4)
    # adding first edge succeed
    @test add_edge!(g1, 1, 2, (a='x', b=1.0))
    @test ne(g1) == 1
    @test get_val(g1, 1, 2, :) == (a='x', b=1.0)
    @test !has_edge(g1, 2, 1)

    # adding the reverse edge should not change the previous one
    @test add_edge!(g1, 2, 1, (a='y', b=2.0))
    @test ne(g1) == 2
    @test get_val(g1, 1, 2, :) == (a='x', b=1.0)
    @test get_val(g1, 2, 1, :) == (a='y', b=2.0)
end

@testset "add_edge! 3" begin

    g1 = EdgeValOutDiGraph{Int, NamedTuple{(:a, :b), Tuple{Char, Float64}}}(4)
    # adding first edge succeed
    @test add_edge!(g1, 1, 2, (a='x', b=1.0))
    @test ne(g1) == 1
    @test get_val(g1, 1, 2, :) == (a='x', b=1.0)
    @test !has_edge(g1, 2, 1)

    # adding the reverse edge should not change the previous one
    @test add_edge!(g1, 2, 1, (a='y', b=2.0))
    @test ne(g1) == 2
    @test get_val(g1, 1, 2, :) == (a='x', b=1.0)
    @test get_val(g1, 2, 1, :) == (a='y', b=2.0)
end

end # testset