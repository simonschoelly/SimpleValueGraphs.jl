

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

        @testset "vals" begin
            @test vals(e) == values
            @test vals(e) isa E_VALS
        end

        @testset "val(e, $key)" for
            key in (keys(values) ∪ Base.OneTo(length(values))) # number & symbols

            @test val(e, key) == values[key]
            key isa Integer && @test val(e, key) isa E_VALS.types[key]
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

        @testset "vals" begin
            @test vals(e) == values
            @test vals(e) isa E_VALS
        end

        @testset "val(e, $key)" for
            key in (keys(values) ∪ Base.OneTo(length(values))) # number & symbols

            @test val(e, key) == values[key]
            @test val(e, key) == vals(e)[key]
            key isa Integer && @test val(e, key) isa E_VALS.types[key]
        end
    end

end


@testset "edge access functions val(e) [no key]" begin

    @testset "exactly one value, E_VALS == $E_VALS" for
        E_VALS in TEST_EDGEVAL_TYPES_SINGE_VALUE_SMALL

        values = rand_sample(E_VALS)
        e_undir = ValEdge(1, 2, values)
        e_dir = ValEdge(1, 2, values)

        @test val(e_undir) == val(e_undir, 1)
        @test val(e_undir) == vals(e_undir)[1]
        @test val(e_undir) isa E_VALS.types[1]

        @test val(e_dir) == val(e_dir, 1)
        @test val(e_dir) == vals(e_dir)[1]
        @test val(e_dir) isa E_VALS.types[1]

    end

    @testset "less ore more than one value, E_VALS == $E_VALS" for
        E_VALS in TEST_EDGEVAL_TYPES_NON_SINGE_VALUE_SMALL

        values = rand_sample(E_VALS)
        e_undir = ValEdge(1, 2, values)
        e_dir = ValEdge(1, 2, values)

        @test_throws Exception val(e_undir)
        @test_throws Exception val(e_dir)
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
        @test vals(e) == vals(e_rev)
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
        @test vals(e) == vals(e_rev)
        @test typeof(e) == typeof(e_rev)
    end


end
