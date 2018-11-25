
@testset "operators" begin

pbar = Progress(4, 0.2, "operators")

# TODO this should be in a file test/operators.jl
@testset "map_edgevals! undirected" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        g = SimpleValueGraph(CycleGraph(V(5)), E_VAL)
        u = rand(vertices(g))
        w1 = rand_sample(E_VAL)
        w2 = rand_sample(E_VAL)
        map_edgevals!(g) do s, d, value
            return (u ∈ (s, d)) ? w1 : w2
        end
        @test all(edges(g)) do e
            return val(e) == (u ∈ (src(e), dst(e)) ? w1 : w2)
        end
    end
end

next!(pbar)

# TODO this should be in a file test/operators.jl
@testset "map_edgevals! directed" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        g = SimpleValueDiGraph(CycleDiGraph(V(5)), E_VAL)
        u = rand(vertices(g))
        w1 = rand_sample(E_VAL)
        w2 = rand_sample(E_VAL)
        map_edgevals!(g) do s, d, value
            return (s == u) ? w1 : w2
        end
        @test all(edges(g)) do e
            return val(e) == (src(e) == u ? w1 : w2)
        end
    end
end

next!(pbar)

# TODO this should be in a file test/operators.jl
@testset "map_edgevals! with key undirected" begin
    for (V, E_VAL) in product(test_vertex_types, filter(T -> T <: TupleOrNamedTuple, test_edgeval_types))
        g = SimpleValueGraph(CycleGraph(V(5)), E_VAL)
        u = rand(vertices(g))
        key = rand(1:length(E_VAL.parameters))
        w1 = rand_sample(E_VAL)[key]
        w2 = rand_sample(E_VAL)[key]
        map_edgevals!(g, key) do s, d, value
            return (u ∈ (s, d)) ? w1 : w2
        end
        @test all(edges(g)) do e
            return val(e)[key] == (u ∈ (src(e), dst(e)) ? w1 : w2)
        end
    end
end

next!(pbar)

# TODO this should be in a file test/operators.jl
@testset "map_edgevals! with key directed" begin
    for (V, E_VAL) in product(test_vertex_types, filter(T -> T <: TupleOrNamedTuple, test_edgeval_types))
        g = SimpleValueDiGraph(CycleDiGraph(V(5)), E_VAL)
        u = rand(vertices(g))
        key = rand(1:length(E_VAL.parameters))
        w1 = rand_sample(E_VAL)[key]
        w2 = rand_sample(E_VAL)[key]
        map_edgevals!(g, key) do s, d, value
            return (s == u) ? w1 : w2
        end
        @test all(edges(g)) do e
            return val(e)[key] == (u == src(e) ? w1 : w2)
        end
    end
end

next!(pbar)

end # testset



