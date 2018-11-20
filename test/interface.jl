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
    

end # testset Interface
