

@testset "AbstractValEdge" begin
    @test ValEdge <: AbstractValEdge
    @test ValDiEdge <: AbstractValEdge
end


@testset "Edge Constructors" for 
    V       in TEST_VERTEX_TYPES_SMALL,
    E_VALS  in TEST_EDGEVAL_TYPES_SMALL,
    u       in V[1, 2, typemax(V)], 
    v       in V[1, 2, typemax(V)]

    values = rand_sample(E_VALS)

    # We enforce that the constructor always puts the smaller vertex as src
    @testset "ValEdge($V($u), $V($v), $values)" begin

        src_should, dst_should = minmax(u, v)
        e = ValEdge(u, v, values)
        e_rev = ValEdge(v, u, values)

        @test e.src == e_rev.src == src_should
        @test e.dst == e_rev.dst == dst_should
        @test e.src <= e.dst
        @test e.vals == values
        @test e isa ValEdge{V, E_VALS}
    end

    @testset "ValDiEdge($V($u), $V($v), $values)" begin

        e = ValDiEdge(u, v, values)

        @test e.src == u
        @test e.dst == v
        @test e.vals == values
        @test e isa ValDiEdge{V, E_VALS}
    end
end


@testset "edge access functions" for
    V       in TEST_VERTEX_TYPES_SMALL,
    E_VALS  in TEST_EDGEVAL_TYPES_SMALL,
    u       in V[1, 2], 
    v       in V[1, 2]

    values = rand_sample(E_VALS)

    e = ValEdge(u, v, values)
    e_rev = ValEdge(v, u, values)
    @testset "e == ValEdge($V($u), $V($v), $values)" begin
        
        @testset "src, dst" begin
            @test issetequal((src(e), dst(e)), (u, v))
            @test issetequal((src(e_rev), dst(e_rev)), (u, v))
            @test src(e) isa V
            @test dst(e) isa V
        end

        @testset "get_val(e, :)" begin
            @test get_val(e, :) == values
            @test get_val(e, :) isa E_VALS
        end

        @testset "get_val(e, $key)" for
            key in (keys(values) ∪ Base.OneTo(length(values))) # number & symbols

            @test get_val(e, key) == values[key]
            key isa Integer && @test get_val(e, key) isa E_VALS.types[key]
        end
    end

    e = ValDiEdge(u, v, values)
    @testset "e == ValDiEdge($V($u), $V($v), $values)" begin
        
        @testset "src, dst" begin
            @test src(e) == u
            @test dst(e) == v
            @test src(e) isa V
            @test dst(e) isa V
        end

        @testset "get_val(e, :)" begin
            @test get_val(e, :) == values
            @test get_val(e, :) isa E_VALS
        end

        @testset "get_val(e, $key)" for
            key in (keys(values) ∪ Base.OneTo(length(values))) # number & symbols

            @test get_val(e, key) == values[key]
            @test get_val(e, key) == get_val(e, :)[key]
            key isa Integer && @test get_val(e, key) isa E_VALS.types[key]
        end
    end

end


@testset "reverse edge" begin

    @testset "edge == $e" for
        V       in TEST_VERTEX_TYPES_SMALL,
        E_VALS  in TEST_EDGEVAL_TYPES_SMALL,
        u       in V[1, 2], 
        v       in V[1, 2],
        e       in ( ValEdge(u, v, rand_sample(E_VALS)), )

        e_rev = reverse(e)
        @test src(e) == src(e_rev)
        @test dst(e) == dst(e_rev)
        @test get_val(e, :) == get_val(e_rev, :)
        @test typeof(e) == typeof(e_rev)
    end

    @testset "edge == $e" for
        V       in TEST_VERTEX_TYPES_SMALL,
        E_VALS  in TEST_EDGEVAL_TYPES_SMALL,
        u       in V[1, 2], 
        v       in V[1, 2],
        e       in ( ValDiEdge(u, v, rand_sample(E_VALS)), )

        e_rev = reverse(e)
        @test src(e) == dst(e_rev)
        @test dst(e) == src(e_rev)
        @test get_val(e, :) == get_val(e_rev, :)
        @test typeof(e) == typeof(e_rev)
    end


end
