
#=
using SimpleValueGraphs.AbstractTuples

import SimpleValueGraphs: default_eltype


function testset_toplogical_equivalent(g::SimpleGraph, gv::ValGraph)
    @testset "Topological equivalent" begin
        @test all(lr -> lr[1] == lr[2], zip(g.fadjlist, gv.fadjlist))
    end
end

function testset_toplogical_equivalent(g::SimpleDiGraph, gv::ValOutDiGraph)
    @testset "Topological equivalent" begin
        @test all(lr -> lr[1] == lr[2], zip(g.fadjlist, gv.fadjlist))
    end
end

function testset_toplogical_equivalent(g::SimpleDiGraph, gv::ValDiGraph)
    @testset "Topological equivalent" begin
        @test all(lr -> lr[1] == lr[2], zip(g.fadjlist, gv.fadjlist))
        @test all(lr -> lr[1] == lr[2], zip(g.badjlist, gv.badjlist))
    end
end

=#

@testset "constructor type stability" begin

    @inferred ValGraph(1)
    @inferred ValDiGraph(1)
    @inferred ValOutDiGraph(1)

    @inferred ValGraph{Int8}(1)
    @inferred ValDiGraph{UInt8}(1)
    @inferred ValOutDiGraph{Int16}(1)

    @inferred ValGraph{Int8, Tuple{Int64, String}, Tuple{}}(1, vertexval_init=undef)
    @inferred ValDiGraph{UInt8, Tuple{}, @NamedTuple{a::Union{Missing, Int}, b::Vector}}(1)
    @inferred ValOutDiGraph{Int16, @NamedTuple{a::Int, b::Int}, Tuple{String}}(1, vertexval_init=undef)
end

#  ------------------------------------------------------
#  Constructors from other value graphs
#  ------------------------------------------------------

@testset "ValGraph{$V_OUT}(::ValGraph{$V_IN}" for
            V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValGraph{V_IN}(5;
        vertexval_types=(Int8,),
        vertexval_init=v -> (v,),
        edgeval_types=(a=Int8, b=Int16),
    )
    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValGraph{V_OUT}(g1)
    @test g2 isa ValGraph{V_OUT, vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == ne(g1)
    @test g2.fadjlist == g1.fadjlist
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValGraph(::ValGraph{$V_IN}" for V_IN ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValGraph{V_IN}(5;
        vertexval_types=(Int8,),
        vertexval_init=v -> (v,),
        edgeval_types=(Int8, Int16),
    )
    add_edge!(g1, 1, 2, (Int8(1), Int16(2)))
    add_edge!(g1, 2, 3, (Int8(2), Int16(3)))
    add_edge!(g1, 5, 5, (Int8(51), Int16(52)))

    g2 = ValGraph(g1)
    @test g2 isa ValGraph{eltype(g1), vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == ne(g1)
    @test g2.fadjlist == g1.fadjlist
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValDiGraph{$V_OUT}(::ValGraph{$V_IN}" for
            V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValGraph{V_IN}(5;
        vertexval_types=(x=Int8,),
        vertexval_init=v -> (x=Int8(v),),
        edgeval_types=(a=Int8, b=Int16),
    )
    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValDiGraph{V_OUT}(g1)
    @test g2 isa ValDiGraph{V_OUT, vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == 5
    @test g2.fadjlist == g2.badjlist == [[2], [1, 3], [2], Int[], [5]]
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g2.redgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValDiGraph(::ValGraph{$V_IN}" for V_IN ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValGraph{V_IN}(5;
        vertexval_types=(x=Int8,),
        vertexval_init=v -> (x=Int8(v),),
        edgeval_types=(a=Int8, b=Int16),
    )
    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValDiGraph(g1)
    @test g2 isa ValDiGraph{eltype(g1), vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == 5
    @test g2.fadjlist == g2.badjlist == [[2], [1, 3], [2], Int[], [5]]
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g2.redgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValOutDiGraph{$V_OUT}(::ValGraph{$V_IN}" for
            V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValGraph{V_IN}(5;
        vertexval_types=(x=Int8,),
        vertexval_init=v -> (x=Int8(v),),
        edgeval_types=(a=Int8, b=Int16),
    )
    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValOutDiGraph{V_OUT}(g1)
    @test g2 isa ValOutDiGraph{V_OUT, vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == 5
    @test g2.fadjlist == [[2], [1, 3], [2], Int[], [5]]
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValOutDiGraph(::ValGraph{$V_IN}" for V_IN ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValGraph{V_IN}(5;
        vertexval_types=(x=Int8,),
        vertexval_init=v -> (x=Int8(v),),
        edgeval_types=(a=Int8, b=Int16),
    )
    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValOutDiGraph(g1)
    @test g2 isa ValOutDiGraph{eltype(g1), vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == 5
    @test g2.fadjlist == [[2], [1, 3], [2], Int[], [5]]
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValDiGraph{$V_OUT}(::ValDiGraph{$V_IN}" for
            V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValDiGraph{V_IN}(5;
        vertexval_types=(x=Int, y=Int),
        vertexval_init=v -> (x=Int(v), y=Int(10 * v)),
        edgeval_types=(a=Int8, b=Int16),
    )

    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 3, 2, (a=Int8(3), b=Int16(2)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValDiGraph{V_OUT}(g1)
    @test g2 isa ValDiGraph{V_OUT, vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == ne(g1)
    @test g2.fadjlist == g1.fadjlist
    @test g2.badjlist == g1.badjlist
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.redgevals == g1.redgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValDiGraph(::ValDiGraph{$V_IN}" for V_IN ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValDiGraph{V_IN}(5;
        vertexval_types=(x=Int, y=Int),
        vertexval_init=v -> (x=Int(v), y=Int(10 * v)),
        edgeval_types=(a=Int8, b=Int16),
    )

    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 3, 2, (a=Int8(3), b=Int16(2)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValDiGraph(g1)
    @test g2 isa ValDiGraph{eltype(g1), vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == ne(g1)
    @test g2.fadjlist == g1.fadjlist
    @test g2.badjlist == g1.badjlist
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.redgevals == g1.redgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValOutDiGraph{$V_OUT}(::ValOutDiGraph{$V_IN}" for
            V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValOutDiGraph{V_IN}(5;
        vertexval_types=(x=Int, y=Int),
        vertexval_init=v -> (x=Int(v), y=Int(10 * v)),
        edgeval_types=(a=Int8, b=Int16),
    )

    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 3, 2, (a=Int8(3), b=Int16(2)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValOutDiGraph{V_OUT}(g1)
    @test g2 isa ValOutDiGraph{V_OUT, vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == ne(g1)
    @test g2.fadjlist == g1.fadjlist
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValOutDiGraph(::ValOutDiGraph{$V_IN}" for V_IN ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValDiGraph{V_IN}(5;
        vertexval_types=(x=Int, y=Int),
        vertexval_init=v -> (x=Int(v), y=Int(10 * v)),
        edgeval_types=(a=Int8, b=Int16),
    )

    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 3, 2, (a=Int8(3), b=Int16(2)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValOutDiGraph(g1)
    @test g2 isa ValOutDiGraph{eltype(g1), vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == ne(g1)
    @test g2.fadjlist == g1.fadjlist
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValOutDiGraph{$V_OUT}(::ValDiGraph{$V_IN}" for
            V_IN ∈ (Int64, Int32, Int8, UInt8), V_OUT ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValOutDiGraph{V_IN}(5;
        vertexval_types=(x=Int, y=Int),
        vertexval_init=v -> (x=Int(v), y=Int(10 * v)),
        edgeval_types=(a=Int8, b=Int16),
    )

    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 3, 2, (a=Int8(3), b=Int16(2)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValOutDiGraph{V_OUT}(g1)
    @test g2 isa ValOutDiGraph{V_OUT, vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == ne(g1)
    @test g2.fadjlist == g1.fadjlist
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

@testset "ValOutDiGraph(::ValDiGraph{$V_IN}" for V_IN ∈ (Int64, Int32, Int8, UInt8)

    g1 = ValDiGraph{V_IN}(5;
        vertexval_types=(x=Int, y=Int),
        vertexval_init=v -> (x=Int(v), y=Int(10 * v)),
        edgeval_types=(a=Int8, b=Int16),
    )

    add_edge!(g1, 1, 2, (a=Int8(1), b=Int16(2)))
    add_edge!(g1, 2, 3, (a=Int8(2), b=Int16(3)))
    add_edge!(g1, 3, 2, (a=Int8(3), b=Int16(2)))
    add_edge!(g1, 5, 5, (a=Int8(51), b=Int16(52)))

    g2 = ValOutDiGraph(g1)
    @test g2 isa ValOutDiGraph{eltype(g1), vertexvals_type(g1), edgevals_type(g1), graphvals_type(g1)}
    @test ne(g2) == ne(g1)
    @test g2.fadjlist == g1.fadjlist
    @test g2.vertexvals == g1.vertexvals
    @test g2.edgevals == g1.edgevals
    @test g2.graphvals == g1.graphvals
end

