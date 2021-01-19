using LinearAlgebra: ishermitian, issymmetric
using SparseArrays: AbstractSparseMatrix
using SimpleValueGraphs: OneEdgeValGraph
using LightGraphs: DefaultDistance

@testset "matrices" begin

    @testset "AdjacencyMatrix" begin

        for G      in (ValGraph, ValOutDiGraph, ValDiGraph),
            V      in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            gs     in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

            g = G{V, Tuple{}, E_VALS}(gs.graph;
                edgeval_init=(s, d) -> rand_sample(E_VALS)
            )

            @testset "g::$(typeof(g))" begin

                a = adjacency_matrix(g)

                @testset "constructor" begin
                    @test typeof(a) == AdjacencyMatrix{typeof(g)}
                    @test a isa AbstractSparseMatrix{Bool, Int}
                end

                @testset "size(a)" begin
                     @test size(a) == (nv(g), nv(g))
                end

                @testset "getindex" begin
                    for u in 1:nv(g), v in 1:nv(g)
                        @test a[u, v] == has_edge(g, u, v)
                    end
                end

                if g isa ValGraph
                    @testset "ishermitian" begin
                        @test ishermitian(a)
                    end

                    @testset "issymmetric" begin
                        @test issymmetric(a)
                    end

                    @testset "adjoint is same matrix" begin
                        @test adjoint(a) === a
                    end

                    @testset "transpose is same matrix" begin
                        @test transpose(a) === a
                    end
                end

            end
        end

    end

    @testset "ValMatrix" begin
        for G      in (ValGraph, ValOutDiGraph, ValDiGraph),
            V      in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            gs     in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

            g = G{V, Tuple{}, E_VALS}(gs.graph;
                edgeval_init=(s, d) -> rand_sample(E_VALS)
            )

            @testset "g::$(typeof(g))" begin
                for key in allkeys_for_E_VALS(E_VALS)

                    @testset "key = $key, zerovalue=$zv" for zv in (nothing, rand_sample(fieldtype(E_VALS, key)))

                        M = ValMatrix(g, key, zv)

                        @testset "size" begin
                            @test size(M) == (nv(g), nv(g))
                        end

                        @testset "getindex" begin
                            @test all(Iterators.product(vertices(g), vertices(g))) do (s, d)
                                M[s, d] == (has_edge(g, s, d) ? get_edgeval(g, s, d, key) : zv)
                            end
                        end

                        if fieldtype(E_VALS, key) <: Real && zv isa Real && g isa ValGraph
                            @testset "ishermitian" begin
                                @test ishermitian(M) == true
                            end
                        end

                        if g isa ValGraph
                            @testset "issymmetric" begin
                                @test issymmetric(M) == true
                            end
                        end

                        if fieldtype(E_VALS, key) <: Real && zv isa Real && g isa ValGraph
                            @testset "isadjoint" begin
                                @test adjoint(M) === M
                            end
                        end

                        if g isa ValGraph
                            @testset "transpose" begin
                                @test transpose(M) === M
                            end
                        end

                        @testset "weights" begin

                            @testset "weights(g, $key; zerovalue=$zv)" begin
                                Mw = weights(g, key, zerovalue=zv)
                                @test typeof(M) == typeof(Mw)
                                @test M == Mw
                            end

                            if fieldtype(E_VALS, key) isa Number
                                @testset "weights(g, $key)" begin
                                    Mw = weights(g, key)
                                    @test M isa ValMatrix{fieldtype(E_VALS, key), typeof(g), key}
                                end
                            end

                            if g isa OneEdgeValGraph
                                @testset "weights(g; zerovalue=$zv)" begin
                                    Mw = weights(g, zerovalue=zv)
                                    @test M == Mw
                                end

                                if fieldtype(E_VALS, key) isa Number
                                    @testset "weights(g)" begin
                                        Mw = weights(g)
                                        @test M isa ValMatrix{fieldtype(E_VALS, key), typeof(g), key}
                                    end
                                end
                            end
                        end

                    end
                end
            end
        end
    end

    @testset "weights for value graphs without values" for
        G      in (ValGraph, ValOutDiGraph, ValDiGraph),
        V      in TEST_VERTEX_TYPES_SMALL,
        E_VALS in (Tuple{}, NamedTuple{(), Tuple{}}),
        gs     in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

        g = G{V, Tuple{}, E_VALS}(gs.graph;
            edgeval_init=(s, d) -> rand_sample(E_VALS)
        )

        @test weights(g) == DefaultDistance(nv(g))
    end

end # testset
