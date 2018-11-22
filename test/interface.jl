using Base.Iterators: product

@testset "Interface" begin

@testset "From SimpleGraph" begin
    for ((gs, info), E_VAL) in product(make_testgraphs(SimpleGraph), test_edge_value_types)
        gv = SimpleValueGraph(gs, E_VAL)
        @test eltype(gs) == eltype(gv)
        @test edge_val_type(gv) == E_VAL
        @test all(edges(gv)) do e
            edge_val(e) == default_edge_val(E_VAL)
        end
        @test nv(gs) == nv(gv)
        @test ne(gs) == ne(gv)
        @test all(edges(gs)) do e 
            has_edge(gv, src(e), dst(e))
        end
    end
end

@testset "add_edge!" begin
    for (V, E_VAL) in product(test_vertex_types, test_edge_value_types)
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
    

end # testset Interface
