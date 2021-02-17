
import SimpleValueGraphs: typetuple

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
        @test g.vertexvals == ()
        @test g.edgevals == ()
    end

    @testset "ValDiGraph{UInt16, Tuple{}, NamedTuple{(), Tuple{}}}(gd)" begin

        g = ValDiGraph{UInt16, Tuple{}, NamedTuple{(), Tuple{}}}(gd)

        @test g isa ValDiGraph{UInt16, Tuple{}, NamedTuple{(), Tuple{}}}
        @test g.ne == 4
        @test g.fadjlist == [[], [2, 3], [4], [3]]
        @test g.badjlist == [[], [2], [2, 4], [3]]
        @test g.vertexvals == ()
        @test g.edgevals == ()
        @test g.redgevals == ()
    end

    @testset "ValGraph{UInt64, Tuple{Int32, Float32}, Tuple{}}(gs; vertexvals_init=undef)" begin

        g = ValGraph{UInt64, Tuple{Int32, Float32}, Tuple{}}(gs, vertexval_init=undef)

        @test g isa ValGraph{UInt64, Tuple{Int32, Float32}, Tuple{}}
        @test g.vertexvals isa Tuple{Vector{Int32}, Vector{Float32}}
        @test length(g.vertexvals[1]) == 3
        @test length(g.vertexvals[2]) == 3
        @test g.edgevals == ()
    end

    @testset "ValOutDiGraph{Int64, NamedTuple{(a, b), Tuple{Int32, Float32}}, Tuple{}}(gs; vertexvals_init=undef)" begin

        g = ValOutDiGraph{Int64, Tuple{Int32, Float32}, Tuple{}}(gd, vertexval_init=undef)

        @test g isa ValOutDiGraph{Int64, Tuple{Int32, Float32}, Tuple{}}
        @test g.vertexvals isa Tuple{Vector{Int32}, Vector{Float32}}
        @test length(g.vertexvals[1]) == 4
        @test length(g.vertexvals[2]) == 4
        @test g.edgevals == ()
    end

    @testset "ValDiGraph{Int64, NamedTuple{(a, b), Tuple{Int32, Float32}}, Tuple{}}(gs; vertexvals_init=undef)" begin

        g = ValDiGraph{Int64, Tuple{Int32, Float32}, Tuple{}}(gd, vertexval_init=undef)

        @test g isa ValDiGraph{Int64, Tuple{Int32, Float32}, Tuple{}}
        @test g.vertexvals isa Tuple{Vector{Int32}, Vector{Float32}}
        @test length(g.vertexvals[1]) == 4
        @test length(g.vertexvals[2]) == 4
        @test g.edgevals == ()
        @test g.redgevals == ()
    end


# ======================================================
# Simple[Di]Graph from value graph constructor
# ======================================================

    @testset "SimpleGraph{$V_OUT}(g::ValGraph{$V_IN})" for V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)

        g = ValGraph{V_IN}(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 5, 5)

        gs = SimpleGraph{V_OUT}(g)
        @test gs isa SimpleGraph{V_OUT}
        @test ne(gs) == 3
        @test gs.fadjlist == [[2], [1, 3], [2], Int[], [5]]

    end

    @testset "SimpleGraph(g::ValGraph{$V_IN})" for V_IN ∈ (Int64, Int32, Int8, UInt8)

        g = ValGraph{V_IN}(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 5, 5)

        gs = SimpleGraph(g)
        @test gs isa SimpleGraph{eltype(g)}
        @test ne(gs) == 3
        @test gs.fadjlist == [[2], [1, 3], [2], Int[], [5]]
    end

    @testset "SimpleDiGraph{$V_OUT}(g::ValDiGraph{$V_IN})" for V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)
        g = ValDiGraph{V_IN}(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        add_edge!(g, 2, 3)
        add_edge!(g, 2, 2)
        add_edge!(g, 5, 5)

        gs = SimpleDiGraph{V_OUT}(g)
        @test gs isa SimpleDiGraph{V_OUT}
        @test ne(gs) == 5
        @test gs.fadjlist == [[2], [1, 2, 3], Int[], Int[], [5]]
        @test gs.badjlist == [[2], [1, 2], [2], Int[], [5]]
    end

    @testset "SimpleDiGraph(g::ValDiGraph{$V_IN})" for V_IN ∈ (Int64, Int32, Int8, UInt8)

        g = ValDiGraph{V_IN}(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        add_edge!(g, 2, 3)
        add_edge!(g, 2, 2)
        add_edge!(g, 5, 5)

        gs = SimpleDiGraph(g)
        @test ne(gs) == 5
        @test gs isa SimpleDiGraph{eltype(g)}
        @test gs.fadjlist == [[2], [1, 2, 3], Int[], Int[], [5]]
        @test gs.badjlist == [[2], [1, 2], [2], Int[], [5]]
    end

    @testset "SimpleDiGraph{$V_OUT}(g::ValOutDiGraph{$V_IN})" for V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)
        g = ValOutDiGraph{V_IN}(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        add_edge!(g, 2, 3)
        add_edge!(g, 2, 2)
        add_edge!(g, 5, 5)

        gs = SimpleDiGraph{V_OUT}(g)
        @test gs isa SimpleDiGraph{V_OUT}
        @test ne(gs) == 5
        @test gs.fadjlist == [[2], [1, 2, 3], Int[], Int[], [5]]
        @test gs.badjlist == [[2], [1, 2], [2], Int[], [5]]
    end

    @testset "SimpleDiGraph(g::ValOutDiGraph{$V_IN})" for V_IN ∈ (Int64, Int32, Int8, UInt8)

        g = ValOutDiGraph{V_IN}(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 1)
        add_edge!(g, 2, 3)
        add_edge!(g, 2, 2)
        add_edge!(g, 5, 5)

        gs = SimpleDiGraph(g)
        @test ne(gs) == 5
        @test gs isa SimpleDiGraph{eltype(g)}
        @test gs.fadjlist == [[2], [1, 2, 3], Int[], Int[], [5]]
        @test gs.badjlist == [[2], [1, 2], [2], Int[], [5]]
    end

    @testset "SimpleDiGraph{$V_OUT}(g::ValGraph{$V_IN})" for V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)

        g = ValGraph{V_IN}(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 5, 5)

        gs = SimpleDiGraph{V_OUT}(g)
        @test gs isa SimpleDiGraph{V_OUT}
        @test ne(gs) == 5
        @test gs.fadjlist == [[2], [1, 3], [2], Int[], [5]]
        @test gs.badjlist == [[2], [1, 3], [2], Int[], [5]]

    end

    @testset "SimpleGraph(g::ValGraph{$V_IN})" for V_IN ∈ (Int64, Int32, Int8, UInt8)

        g = ValGraph{V_IN}(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 5, 5)

        gs = SimpleDiGraph(g)
        @test gs isa SimpleDiGraph{eltype(g)}
        @test ne(gs) == 5
        @test gs.fadjlist == [[2], [1, 3], [2], Int[], [5]]
        @test gs.badjlist == [[2], [1, 3], [2], Int[], [5]]
    end

end # testset
