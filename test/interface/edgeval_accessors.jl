import SimpleValueGraphs: tuple_of_types


@testset "Edgeval setters" begin

    @testset "set_edgevals!(::$G{\$V, \$E_VALS}, s, d, vals)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Correct values set" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)

                    vals = rand_sample(E_VALS)
                    set_edgevals!(g, s, d, vals)
                    get_edgevals(g, s, d) == vals || return false

                end
            end

            if !is_directed(g)
                @testset "Correct values set for reverse edge" begin
                    @test all(edges(gs) ∪ reverse.(edges(gs))) do e
                        s, d = src(e), dst(e)
                        vals = rand_sample(E_VALS)
                        set_edgevals!(g, s, d, vals)
                        
                        get_edgevals(g, d, s) == vals
                    end
                end
            end
        end
    end

    @testset "set_edgeval!(::$G{\$V, \$E_VALS}, s, d, val, key=\$key)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, key = $key" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            key in allkeys_for_E_VALS(E_VALS)

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Correct values set" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    val = rand_sample(E_VALS)[key]
                    set_edgeval!(g, s, d, val, key=key)

                    get_edgevals(g, s, d)[key] == val

                end
            end

            if !is_directed(g)
                @testset "Correct values set for reverse edge" begin
                    @test all(edges(gs) ∪ reverse.(edges(gs))) do e
                        s, d = src(e), dst(e)
                        val = rand_sample(E_VALS)[key]
                        set_edgeval!(g, s, d, val, key=key)
                        
                        get_edgevals(g, d, s)[key] == val
                    end
                end
            end
        end
    end

    @testset "set_edgeval!(::$G{\$V, \$E_VALS}, s, d, val)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SINGE_VALUE_SMALL

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Correct values set" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    val = rand_sample(E_VALS.types[1])
                    set_edgeval!(g, s, d, val)

                    get_edgevals(g, s, d)[1] == val

                end
            end

            if !is_directed(g)
                @testset "Correct values set for reverse edge" begin
                    @test all(edges(gs) ∪ reverse.(edges(gs))) do e
                        s, d = src(e), dst(e)
                        val = rand_sample(E_VALS.types[1])
                        set_edgeval!(g, s, d, val)
                        
                        get_edgevals(g, d, s)[1] == val
                    end
                end
            end
        end
    end
end

@testset "Edgeval getters" begin

    @testset "get_edgevals(::$G{\$V, \$E_VALS}, s, d)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Getting correct values" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    vals = rand_sample(E_VALS)
                    set_edgevals!(g, s, d, vals)

                    get_edgevals(g, s, d) == vals
                end
            end
        end
    end
        
    @testset "get_edgevals_or(::$G{\$V, \$E_VALS}, s, d, \$default)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, default = $(repr(default))" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            default in (nothing, 0)

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Getting correct values" begin

                @test all(Iterators.product(vertices(g), vertices(g))) do (s, d)
                    vals = rand_sample(E_VALS)
                    if has_edge(g, s, d)
                        set_edgevals!(g, s, d, vals)
                    end

                    get_edgevals_or(g, s, d, default) == (has_edge(g, s, d) ? vals : default)
                end
            end
        end
    end

    @testset "get_edgeval(::$G{\$V, \$E_VALS}, s, d, key=\$key)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, key = $key" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            key in allkeys_for_E_VALS(E_VALS)

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Getting correct value" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    vals = rand_sample(E_VALS)
                    set_edgevals!(g, s, d, vals)

                    get_edgeval(g, s, d, key=key) == vals[key]
                end
            end
        end
    end

    @testset "get_edgeval(::$G{\$V, \$E_VALS}, s, d)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SINGE_VALUE_SMALL

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Getting correct value" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    vals = rand_sample(E_VALS)
                    set_edgevals!(g, s, d, vals)

                    get_edgeval(g, s, d) == vals[1]
                end
            end
        end
    end

    @testset "get_edgeval_or(::$G{\$V, \$E_VALS}, s, d, default, key=\$key)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, key = $key, default = $(repr(default))" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            key in allkeys_for_E_VALS(E_VALS),
            default in (nothing, 0)

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Getting correct value" begin

                @test all(Iterators.product(vertices(g), vertices(g))) do (s, d)
                    vals = rand_sample(E_VALS)
                    if has_edge(g, s, d)
                        set_edgevals!(g, s, d, vals)
                    end

                    get_edgeval_or(g, s, d, default, key=key) == (has_edge(g, s, d) ?
                        vals[key] : default)
                end
            end
        end
    end

    @testset "get_edgeval_or(::$G{\$V, \$E_VALS}, s, d, default)" for
        G in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, default = $(repr(default))" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SINGE_VALUE_SMALL,
            default in (nothing, 0)

            gs = is_directed(G) ? CycleDiGraph(V(5)) : CycleGraph(V(4))
            g = G((s, d) -> rand_sample(E_VALS), gs, tuple_of_types(E_VALS))
            @assert g isa G{V, E_VALS}

            @testset "Getting correct value" begin

                @test all(Iterators.product(vertices(g), vertices(g))) do (s, d)
                    vals = rand_sample(E_VALS)
                    if has_edge(g, s, d)
                        set_edgevals!(g, s, d, vals)
                    end

                    get_edgeval_or(g, s, d, default) == (has_edge(g, s, d) ?
                        vals[1] : default)
                end
            end
        end
    end

end
