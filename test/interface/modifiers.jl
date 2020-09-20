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

    # adding an edge twice should return false change the value the second time
    @test add_edge!(g1, 1, 3, (a='z', b=3.0))
    @test ne(g1) == 3
    @test get_val(g1, 1, 3, :) == (a='z', b=3.0)
    @test !add_edge!(g1, 1, 3, (a='z', b=4.0))
    @test ne(g1) == 3
    @test get_val(g1, 1, 3, :) == (a='z', b=4.0)
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

    # adding an edge twice should return false change the value the second time
    @test add_edge!(g1, 1, 3, (a='z', b=3.0))
    @test ne(g1) == 3
    @test get_val(g1, 1, 3, :) == (a='z', b=3.0)
    @test !add_edge!(g1, 1, 3, (a='z', b=4.0))
    @test ne(g1) == 3
    @test get_val(g1, 1, 3, :) == (a='z', b=4.0)
end

@testset "rem_edge! 1" begin
    g = EdgeValGraph{Int, NamedTuple{(:a,), Tuple{Int}}}(3)

    # removing non existing edge should return false
    @test !rem_edge!(g, 1, 2)
    @test !rem_edge!(g, 0, 4) # out of bounds
    @test ne(g) == 0

    # removing an existing edge
    add_edge!(g, 1, 2, (a=10,))
    @test rem_edge!(g, 1, 2)
    @test !has_edge(g, 1, 2)
    @test !has_edge(g, 2, 1)
    @test ne(g) == 0
    # can't remove twice
    @test !rem_edge!(g, 1, 2)

    add_edge!(g, 1, 2, (a=20,))
    add_edge!(g, 3, 3, (a=20,))

    # removing with src, dst interchanged
    @test rem_edge!(g, 2, 1)
    @test !has_edge(g, 1, 2)
    @test !has_edge(g, 2, 1)
    @test ne(g) == 1

    # remvoing a self-loop
    @test rem_edge!(g, 3, 3)
    @test !has_edge(g, 3, 3)
    @test ne(g) == 0
end

@testset "rem_edge! 2" begin
    g = EdgeValDiGraph{Int, Tuple{Float64, Float64}}(4)

    # removing non existing edge should return false
    @test !rem_edge!(g, 1, 1)
    @test !rem_edge!(g, -1, 3) # out of bounds
    @test ne(g) == 0

    # removing an one-directed existing edge
    add_edge!(g, 1, 2, (1.0, 2.0))
    @test rem_edge!(g, 1, 2)
    @test !has_edge(g, 1, 2)
    @test !has_edge(g, 2, 1)
    @test ne(g) == 0
    # can't remove twice
    @test !rem_edge!(g, 1, 2)

    # removing an two-directed existing edge
    add_edge!(g, 3, 4, (3.0, 4.0))
    add_edge!(g, 4, 3, (3.0, 4.0))
    @test rem_edge!(g, 3, 4)
    @test !has_edge(g, 3, 4)
    @test has_edge(g, 4, 3)
    @test ne(g) == 1
    # remove other edge
    @test rem_edge!(g, 4, 3)
    @test !has_edge(g, 3, 4)
    @test !has_edge(g, 4, 3)
    @test ne(g) == 0

end

@testset "rem_edge! 3" begin
    g = EdgeValOutDiGraph{Int, Tuple{Float64, Float64}}(4)

    # removing non existing edge should return false
    @test !rem_edge!(g, 1, 1)
    @test !rem_edge!(g, -1, 3) # out of bounds
    @test ne(g) == 0

    # removing an one-directed existing edge
    add_edge!(g, 1, 2, (1.0, 2.0))
    @test rem_edge!(g, 1, 2)
    @test !has_edge(g, 1, 2)
    @test !has_edge(g, 2, 1)
    @test ne(g) == 0
    # can't remove twice
    @test !rem_edge!(g, 1, 2)

    # removing an two-directed existing edge
    add_edge!(g, 3, 4, (3.0, 4.0))
    add_edge!(g, 4, 3, (3.0, 4.0))
    @test rem_edge!(g, 3, 4)
    @test !has_edge(g, 3, 4)
    @test has_edge(g, 4, 3)
    @test ne(g) == 1
    # remove other edge
    @test rem_edge!(g, 4, 3)
    @test !has_edge(g, 3, 4)
    @test !has_edge(g, 4, 3)
    @test ne(g) == 0

    # removing a self-loop
    add_edge!(g, 2, 2, (3.0, 4.0))
    @test rem_edge!(g, 2, 2)
    @test !has_edge(g, 2, 2)
    @test ne(g) == 0
    @test !rem_edge!(g, 2, 2)
    @test !has_edge(g, 2, 2)
    @test ne(g) == 0
end

end # testset