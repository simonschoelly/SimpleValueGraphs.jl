
import SimpleValueGraphs: typetuple, default_edgeval_types

@testset "SimpleGraphs.jl" begin

    gs = SimpleGraph(Edge{Int16}.([(2, 2), (2, 3)]))
    gd = SimpleDiGraph(Edge{UInt16}.([(2, 2), (2, 3), (3,4), (4, 3)]))

    @testset "ValGraph{Int16, Tuple{}, Tuple{}}(gs)" begin

        g = ValGraph{Int16, Tuple{}, Tuple{}}(gs)

        @test g isa ValGraph{Int16, Tuple{}, Tuple{}}
        @test g.ne == 2
        @test g.fadjlist == [[], [2, 3], [2]]
        @test g.vertexvals == ()
        @test g.edgevals == ()
    end

    @testset "ValOutDiGraph{Int32, NamedTuple{(), Tuple{}}, Tuple{}}(gd)" begin

        g = ValOutDiGraph{Int32, NamedTuple{(), Tuple{}}, Tuple{}}(gd)

        @test g isa ValOutDiGraph{Int32, NamedTuple{(), Tuple{}}, Tuple{}}
        @test g.ne == 4
        @test g.fadjlist == [[], [2, 3], [4], [3]]
        @test g.vertexvals == NamedTuple()
        @test g.edgevals == ()
    end

    @testset "ValDiGraph{UInt16, Tuple{}, NamedTuple{(), Tuple{}}}(gd)" begin

        g = ValDiGraph{UInt16, Tuple{}, NamedTuple{(), Tuple{}}}(gd)

        @test g isa ValDiGraph{UInt16, Tuple{}, NamedTuple{(), Tuple{}}}
        @test g.ne == 4
        @test g.fadjlist == [[], [2, 3], [4], [3]]
        @test g.badjlist == [[], [2], [2, 4], [3]]
        @test g.vertexvals == ()
        @test g.edgevals == NamedTuple()
        @test g.redgevals == NamedTuple()
    end

    @testset "ValGraph{UInt64, Tuple{Int32, Float32}, Tuple{}}(gs; vertexvals_initializer=undef)" begin

        g = ValGraph{UInt64, Tuple{Int32, Float32}, Tuple{}}(gs, vertexval_initializer=undef)

        @test g isa ValGraph{UInt64, Tuple{Int32, Float32}, Tuple{}}
        @test g.vertexvals isa Tuple{Vector{Int32}, Vector{Float32}}
        @test length(g.vertexvals[1]) == 3
        @test length(g.vertexvals[2]) == 3
        @test g.edgevals == ()
    end

    @testset "ValOutDiGraph{Int64, NamedTuple{(a, b), Tuple{Int32, Float32}}, Tuple{}}(gs; vertexvals_initializer=undef)" begin

        g = ValOutDiGraph{Int64, Tuple{Int32, Float32}, Tuple{}}(gd, vertexval_initializer=undef)

        @test g isa ValOutDiGraph{Int64, Tuple{Int32, Float32}, Tuple{}}
        @test g.vertexvals isa Tuple{Vector{Int32}, Vector{Float32}}
        @test length(g.vertexvals[1]) == 4
        @test length(g.vertexvals[2]) == 4
        @test g.edgevals == ()
    end

    @testset "ValDiGraph{Int64, NamedTuple{(a, b), Tuple{Int32, Float32}}, Tuple{}}(gs; vertexvals_initializer=undef)" begin

        g = ValDiGraph{Int64, Tuple{Int32, Float32}, Tuple{}}(gd, vertexval_initializer=undef)

        @test g isa ValDiGraph{Int64, Tuple{Int32, Float32}, Tuple{}}
        @test g.vertexvals isa Tuple{Vector{Int32}, Vector{Float32}}
        @test length(g.vertexvals[1]) == 4
        @test length(g.vertexvals[2]) == 4
        @test g.edgevals == ()
        @test g.redgevals == ()
    end
end # testset
