using LinearAlgebra: issymmetric

pbar = Progress(12, 0.2, "interface")

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

@testset "From SimpleDiGraph" begin
    for ((gs, info), E_VAL) in product(make_testgraphs(SimpleDiGraph), test_edgeval_types)
        gv = SimpleValueDiGraph(gs, E_VAL)
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


@testset "add_edge! undirected" begin
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

@testset "add_edge! directed" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        n = 5
        m = 25
        gs = SimpleDiGraph{V}(n)
        gv = SimpleValueDiGraph{V, E_VAL}(n)
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
    
@testset "rem_edge! undirected" begin
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

@testset "rem_edge! directed" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        n = 5
        k = 25
        gs = CompleteDiGraph(V(n))
        gv = SimpleValueDiGraph(gs, E_VAL)
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

@testset "get_edgeval & set_edgeval! undirected" begin
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

@testset "get_edgeval & set_edgeval! with key undirected" begin
    for (V, E_VAL) in product(test_vertex_types, filter(T -> T <: TupleOrNamedTuple, test_edgeval_types))
        n = 5
        m = 6
        k = 10
        gs = erdos_renyi(V(5), 6)
        gv = SimpleValueGraph(gs, E_VAL)
        for i = 1:k
            u = rand(1:n)
            v = rand(1:n)
            w = rand_sample(E_VAL)
            key = rand(1:length(E_VAL.parameters))
            set_edgeval!(gv, u, v, key, w[key])
            @test get_edgeval(gv, u, v, key) == (has_edge(gs, u, v) ? w[key] : nothing)
        end
    end
end

next!(pbar)

@testset "get_edgeval & set_edgeval! directed" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        n = 5
        m = 6
        k = 10
        gs = erdos_renyi(V(5), 6, is_directed=true)
        gv = SimpleValueDiGraph(gs, E_VAL)
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

@testset "get_edgeval & set_edgeval! with key directed" begin
    for (V, E_VAL) in product(test_vertex_types, filter(T -> T <: TupleOrNamedTuple, test_edgeval_types))
        n = 5
        m = 6
        k = 10
        gs = erdos_renyi(V(5), 6, is_directed=true)
        gv = SimpleValueDiGraph(gs, E_VAL)
        for i = 1:k
            u = rand(1:n)
            v = rand(1:n)
            w = rand_sample(E_VAL)
            key = rand(1:length(E_VAL.parameters))
            set_edgeval!(gv, u, v, key, w[key])
            @test get_edgeval(gv, u, v, key) == (has_edge(gs, u, v) ? w[key] : nothing)
        end
    end
end

next!(pbar)

@testset "add_vertex! undirected" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        g = SimpleValueGraph(CompleteGraph(V(4)), E_VAL)
        n = nv(g)
        m = ne(g)
        for i in 1:10
            add_vertex!(g)
            @test nv(g) == n + i
            @test ne(g) == m
        end
    end
end

next!(pbar)

@testset "add_vertex! directed" begin
    for (V, E_VAL) in product(test_vertex_types, test_edgeval_types)
        g = SimpleValueDiGraph(CompleteDiGraph(V(4)), E_VAL)
        n = nv(g)
        m = ne(g)
        for i in 1:10
            add_vertex!(g)
            @test nv(g) == n + i
            @test ne(g) == m
        end
    end
end

next!(pbar)

end # testset Interface
