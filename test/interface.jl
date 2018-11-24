using Base.Iterators: product
using LinearAlgebra: issymmetric
import SimpleValueGraphs.TupleOrNamedTuple

pbar = Progress(6, 0.2)

@testset "Interface" begin



@testset "From SimpleGraph" begin
    for ((gs, info), E_VAL) in product(make_testgraphs(SimpleGraph), test_edgeval_types)
        gv = SimpleValueGraph(gs, E_VAL)
        @test eltype(gs) == eltype(gv)
        @test edgeval_type(gv) == E_VAL
        @test all(edges(gv)) do e
            val(e) == default_edgeval(E_VAL)
        end
        @test nv(gs) == nv(gv)
        @test ne(gs) == ne(gv)
        @test all(edges(gs)) do e 
            has_edge(gv, src(e), dst(e))
        end
    end
end

next!(pbar)

@testset "add_edge!" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        n = 5
        m = 25
        gs = SimpleGraph{V}(n)
        gv = SimpleValueGraph{V, E_VAL}(n)
        for i = 1:m
            u = rand(1:n)
            v = rand(1:n)
            w = rand_sample(E_VAL)
            add_edge!(gs, u, v)
            add_edge!(gv, u, v, w)
            @test ne(gs) == ne(gv)
            @test has_edge(gv, u, v)
            @test has_edge(gv, u, v, w)
            @test get_edgeval(gv, u, v) == w
        end
    end
end

next!(pbar)
    
@testset "rem_edge!" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        n = 5
        k = 25
        gs = CompleteGraph(V(n))
        gv = SimpleValueGraph(gs, E_VAL)
        for i = 1:k
            u = rand(1:n)
            v = rand(1:n)
            rem_edge!(gs, u, v)
            rem_edge!(gv, u, v)
            @test ne(gs) == ne(gv)
            @test !has_edge(gv, u, v)
            @test get_edgeval(gv, u, v) == nothing
        end
    end
end

next!(pbar)

@testset "get_edgeval & set_edgeval!" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        n = 5
        m = 6
        k = 10
        gs = erdos_renyi(V(5), 6)
        gv = SimpleValueGraph(gs, E_VAL)
        for i = 1:k
            u = rand(1:n)
            v = rand(1:n)
            w = rand_sample(E_VAL)
            set_edgeval!(gv, u, v, w)
            @test get_edgeval(gv, u, v) == (has_edge(gs, u, v) ? w : nothing)
        end
    end
end

next!(pbar)

# TODO this should be in a file test/operators.jl
@testset "map_edgevals!" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        g = SimpleValueGraph(CycleGraph(V(5)), E_VAL)
        u = rand(vertices(g))
        w1 = rand_sample(E_VAL)
        w2 = rand_sample(E_VAL)
        map_edgevals!(g) do s, d, value
            return u ∈ (s, d) ? w1 : w2
        end
        @test all(edges(g)) do e
            return val(e) == (u ∈ (src(e), dst(e)) ? w1 : w2)
        end
    end
end

next!(pbar)

# TODO this should be in a file test/operators.jl
@testset "map_edgevals! with key" begin
    for (V, E_VAL) in product(test_vertex_types, filter(T -> T <: TupleOrNamedTuple, test_edgeval_types))
        g = SimpleValueGraph(CycleGraph(V(5)), E_VAL)
        u = rand(vertices(g))
        key = rand(1:length(E_VAL.parameters))
        w1 = rand_sample(E_VAL)[key]
        w2 = rand_sample(E_VAL)[key]
        map_edgevals!(g, key) do s, d, value
            return u ∈ (s, d) ? w1 : w2
        end
        @test all(edges(g)) do e
            return val(e)[key] == (u ∈ (src(e), dst(e)) ? w1 : w2)
        end
    end
end

next!(pbar)

end # testset Interface
