@testset "modifiers" begin

@testset "add_edge! 1" begin

    g1 = ValGraph{Int, Tuple{}, Tuple{Int}}(3)
    # adding first edge succeed
    @test add_edge!(g1, 1, 2, (10, ))
    @test ne(g1) == 1
    @test get_edgeval(g1, 1, 2, 1) == 10
    @test get_edgeval(g1, 2, 1, 1) == 10

    # adding same edge with different value returns false but changes value
    @test !add_edge!(g1, 1, 2, (20, ))
    @test ne(g1) == 1
    @test get_edgeval(g1, 1, 2, 1) == 20
    @test get_edgeval(g1, 2, 1, 1) == 20

    # adding a self-loop works
    @test add_edge!(g1, 1, 1, (30, ))
    @test ne(g1) == 2
    @test get_edgeval(g1, 1, 1, 1) == 30
    @test get_edgeval(g1, 1, 1, 1) == 30

    # another edge, this time higher vertex first
    @test add_edge!(g1, 3, 2, (40, ))
    @test ne(g1) == 3
    @test get_edgeval(g1, 2, 3, 1) == 40
    @test get_edgeval(g1, 3, 2, 1) == 40

    # adding an edge outside of boundaries does nothing
    @test !add_edge!(g1, 1, 4, (50, ))
    @test ne(g1) == 3
    @test !add_edge!(g1, 0, 3, (60, ))
    @test ne(g1) == 3
    @test !add_edge!(g1, -1, -2, (70, ))
    @test ne(g1) == 3
end

@testset "add_edge! 2" begin

    g1 = ValDiGraph{Int, Tuple{}, NamedTuple{(:a, :b), Tuple{Char, Float64}}}(4)
    # adding first edge succeed
    @test add_edge!(g1, 1, 2, (a='x', b=1.0))
    @test ne(g1) == 1
    @test get_edgeval(g1, 1, 2, :) == (a='x', b=1.0)
    @test !has_edge(g1, 2, 1)

    # adding the reverse edge should not change the previous one
    @test add_edge!(g1, 2, 1, (a='y', b=2.0))
    @test ne(g1) == 2
    @test get_edgeval(g1, 1, 2, :) == (a='x', b=1.0)
    @test get_edgeval(g1, 2, 1, :) == (a='y', b=2.0)

    # adding an edge twice should return false change the value the second time
    @test add_edge!(g1, 1, 3, (a='z', b=3.0))
    @test ne(g1) == 3
    @test get_edgeval(g1, 1, 3, :) == (a='z', b=3.0)
    @test !add_edge!(g1, 1, 3, (a='z', b=4.0))
    @test ne(g1) == 3
    @test get_edgeval(g1, 1, 3, :) == (a='z', b=4.0)
end

@testset "add_edge! 3" begin

    g1 = ValOutDiGraph{Int, Tuple{}, NamedTuple{(:a, :b), Tuple{Char, Float64}}}(4)
    # adding first edge succeed
    @test add_edge!(g1, 1, 2, (a='x', b=1.0))
    @test ne(g1) == 1
    @test get_edgeval(g1, 1, 2, :) == (a='x', b=1.0)
    @test !has_edge(g1, 2, 1)

    # adding the reverse edge should not change the previous one
    @test add_edge!(g1, 2, 1, (a='y', b=2.0))
    @test ne(g1) == 2
    @test get_edgeval(g1, 1, 2, :) == (a='x', b=1.0)
    @test get_edgeval(g1, 2, 1, :) == (a='y', b=2.0)

    # adding an edge twice should return false change the value the second time
    @test add_edge!(g1, 1, 3, (a='z', b=3.0))
    @test ne(g1) == 3
    @test get_edgeval(g1, 1, 3, :) == (a='z', b=3.0)
    @test !add_edge!(g1, 1, 3, (a='z', b=4.0))
    @test ne(g1) == 3
    @test get_edgeval(g1, 1, 3, :) == (a='z', b=4.0)
end

# make sure that adding an edge works even if the edge values are slightly different,
# as long as the values can be converted
@testset "add_ege! 4" begin

    g1 = ValGraph{Int8}(2, edgeval_types=(Int16, Int16, Float32))
    add_edge!(g1, 1, Int16(2), (3, 4.0, 5.0))
    @test get_edgeval(g1, 1, 2, :) == (3, 4, 5.0)

    g2 = ValDiGraph{UInt8}(3, edgeval_types=(a=Int32, b=Float64, c=Union{Nothing, Int16}))
    add_edge!(g2, UInt8(1), Int16(2), (a=Int8(3), b=Float32(4.0), c=Int32(5.0)))
    @test get_edgeval(g2, 1, 2, :) == (a=3, b=4.0, c=5)

    g3 = ValOutDiGraph{UInt8}(3, edgeval_types=(a=Int32, b=Float64, c=Union{Nothing, Int16}))
    add_edge!(g3, UInt8(1), Int16(2), (a=Int8(3), b=Float32(4.0), c=nothing))
    @test get_edgeval(g3, 1, 2, :) == (a=3, b=4.0, c=nothing)

end

@testset "add_vertex!" begin

    g1 = ValGraph{Int8}(0, vertexval_types=(Int16, Int16, Float32), vertexval_init=undef)
    add_vertex!(g1, (3, 4.0, 5.0))
    @test get_vertexval(g1, 1, :) == (3, 4, 5.0)

    g2 = ValDiGraph{UInt8}(0, vertexval_types=(a=Int32, b=Float64, c=Union{Nothing, Int16}), vertexval_init=undef)
    add_vertex!(g2, (a=Int8(3), b=Float32(4.0), c=Int32(5.0)))
    @test get_vertexval(g2, Int16(1), :) == (a=3, b=4.0, c=5)

    g3 = ValOutDiGraph{UInt8}(0, vertexval_types=(a=Int32, b=Float64, c=Union{Nothing, Int16}), vertexval_init=undef)
    add_vertex!(g3, (a=Int8(3), b=Float32(4.0), c=nothing))
    @test get_vertexval(g3, 1, :) == (a=3, b=4.0, c=nothing)

end

@testset "rem_edge! 1" begin
    g = ValGraph{Int, Tuple{}, NamedTuple{(:a,), Tuple{Int}}}(3)

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

    # removing a self-loop
    @test rem_edge!(g, 3, 3)
    @test !has_edge(g, 3, 3)
    @test ne(g) == 0
end

@testset "rem_edge! 2" begin
    g = ValDiGraph{Int, Tuple{}, Tuple{Float64, Float64}}(4)

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
    g = ValOutDiGraph{Int, Tuple{}, Tuple{Float64, Float64}}(4)

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
