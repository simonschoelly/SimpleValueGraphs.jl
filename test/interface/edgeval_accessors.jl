import SimpleValueGraphs: tuple_of_types


@testset "Edgeval setters" begin

    @testset "set_edgeval!(::$G{\$V, \$E_VALS}, s, d, :, vals)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Correct values set" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)

                    vals = rand_sample(E_VALS)
                    set_edgeval!(g, s, d, :, vals)
                    get_edgeval(g, s, d, :) == vals || return false

                end
            end

            if !is_directed(g)
                @testset "Correct values set for reverse edge" begin
                    @test all(edges(gs) ∪ reverse.(edges(gs))) do e
                        s, d = src(e), dst(e)
                        vals = rand_sample(E_VALS)
                        set_edgeval!(g, s, d, :, vals)

                        get_edgeval(g, d, s, :) == vals
                    end
                end
            end
        end
    end

    @testset "set_edgeval!(::$G{\$V, \$E_VALS}, s, d, val, \$key)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, key = $key" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            key in allkeys_for_E_VALS(E_VALS)

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Correct values set" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    val = rand_sample(E_VALS)[key]
                    set_edgeval!(g, s, d, key, val)

                    get_edgeval(g, s, d, :)[key] == val

                end
            end

            if !is_directed(g)
                @testset "Correct values set for reverse edge" begin
                    @test all(edges(gs) ∪ reverse.(edges(gs))) do e
                        s, d = src(e), dst(e)
                        val = rand_sample(E_VALS)[key]
                        set_edgeval!(g, s, d, key, val)

                        get_edgeval(g, d, s, :)[key] == val
                    end
                end
            end
        end
    end

    @testset "set_edgeval!(::$G{\$V, \$E_VALS}, s, d, val)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SINGE_VALUE_SMALL

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Correct values set" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    val = rand_sample(E_VALS.types[1])
                    set_edgeval!(g, s, d, val)

                    get_edgeval(g, s, d, :)[1] == val

                end
            end

            if !is_directed(g)
                @testset "Correct values set for reverse edge" begin
                    @test all(edges(gs) ∪ reverse.(edges(gs))) do e
                        s, d = src(e), dst(e)
                        val = rand_sample(E_VALS.types[1])
                        set_edgeval!(g, s, d, val)

                        get_edgeval(g, d, s, :)[1] == val
                    end
                end
            end
        end
    end
end

@testset "Edgeval getters" begin

    @testset "get_edgeval(::$G{\$V, \$E_VALS}, s, d, :)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Getting correct values" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    vals = rand_sample(E_VALS)
                    set_edgeval!(g, s, d, :, vals)

                    get_edgeval(g, s, d, :) == vals
                end
            end
        end
    end

    @testset "get_edgeval_or(::$G{\$V, \$E_VALS}, s, d, :, \$default)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, default = $(repr(default))" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            default in (nothing, 0)

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Getting correct values" begin

                @test all(Iterators.product(vertices(g), vertices(g))) do (s, d)
                    vals = rand_sample(E_VALS)
                    if has_edge(g, s, d)
                        set_edgeval!(g, s, d, :, vals)
                    end

                    get_edgeval_or(g, s, d, :, default) == (has_edge(g, s, d) ? vals : default)
                end
            end
        end
    end

    # covering a special case
    @testset "get_edgeval_or for ValGraph with colon key - deg(s) > deg(d)" begin

        g = ValGraph(star_graph(3), edgeval_types=(Int, ), edgeval_initializer=(s, d) -> (rand(Int),))

        @test get_edgeval_or(g, 1, 2, :, nothing) == get_edgeval_or(g, 2, 1, :, nothing)
    end

    @testset "get_edgeval with colon for non existing edge should throw error" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        g = G(3, edgeval_types=(Int, Float64))

        @test_throws ErrorException get_edgeval(g, 1, 2, :)
    end

    @testset "get_edgeval(::$G{\$V, \$E_VALS}, s, d, \$key)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, key = $key" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            key in allkeys_for_E_VALS(E_VALS)

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Getting correct value" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    vals = rand_sample(E_VALS)
                    set_edgeval!(g, s, d, :, vals)

                    get_edgeval(g, s, d, key) == vals[key]
                end
            end
        end
    end

    @testset "get_edgeval(::$G{\$V, \$E_VALS}, s, d)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SINGE_VALUE_SMALL

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Getting correct value" begin
                edges_to_test = is_directed(g) ? edges(gs) :
                            edges(gs) ∪ reverse.(edges(gs))

                @test all(edges_to_test) do e
                    s, d = src(e), dst(e)
                    vals = rand_sample(E_VALS)
                    set_edgeval!(g, s, d, :, vals)

                    get_edgeval(g, s, d) == vals[1]
                end
            end
        end
    end

    @testset "get_edgeval with correct key for non existing edge should throw error" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        g = G(4, edgeval_types=(Int, ))

        @test_throws ErrorException get_edgeval(g, 1, 2, 1)
    end

    @testset "get_edgeval_or(::$G{\$V, \$E_VALS}, s, d, \$key, default)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, key = $key, default = $(repr(default))" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            key in allkeys_for_E_VALS(E_VALS),
            default in (nothing, 0)

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Getting correct value" begin

                @test all(Iterators.product(vertices(g), vertices(g))) do (s, d)
                    vals = rand_sample(E_VALS)
                    if has_edge(g, s, d)
                        set_edgeval!(g, s, d, :, vals)
                    end

                    get_edgeval_or(g, s, d, key, default) == (has_edge(g, s, d) ?
                        vals[key] : default)
                end
            end
        end
    end

    @testset "get_edgeval_or(::$G{\$V, \$E_VALS}, s, d, default)" for
        G in (ValGraph, ValOutDiGraph, ValDiGraph)

        @testset "Params: V = $V, E_VALS = $E_VALS, default = $(repr(default))" for
            V in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SINGE_VALUE_SMALL,
            default in (nothing, 0)

            gs = is_directed(G) ? cycle_digraph(V(5)) : cycle_graph(V(4))
            g = G(gs, edgeval_types=tuple_of_types(E_VALS), edgeval_initializer=(s, d) -> rand_sample(E_VALS))
            @assert g isa G{V, Tuple{}, E_VALS}

            @testset "Getting correct value" begin

                @test all(Iterators.product(vertices(g), vertices(g))) do (s, d)
                    vals = rand_sample(E_VALS)
                    if has_edge(g, s, d)
                        set_edgeval!(g, s, d, :, vals)
                    end

                    get_edgeval_or(g, s, d, default) == (has_edge(g, s, d) ?
                        vals[1] : default)
                end
            end
        end
    end

end
