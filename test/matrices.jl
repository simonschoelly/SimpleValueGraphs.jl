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

    @testset "convert AdjacencyMatrix to SparseMatrixCSC" begin

        g1 = ValGraph{Int8}(4)
        add_edge!(g1, 1, 2)
        add_edge!(g1, 2, 3)
        add_edge!(g1, 3, 3)
        m1 = AdjacencyMatrix(g1)
        @test SparseMatrixCSC(m1) isa SparseMatrixCSC{Bool, Int}
        @test SparseMatrixCSC(m1) == [0 1 0 0; 1 0 1 0; 0 1 1 0; 0 0 0 0]

        g2 = ValDiGraph{Int16}(4; edgeval_types=(a=String, b=Int))
        add_edge!(g2, 1, 1, ("", 1))
        add_edge!(g2, 1, 2, ("", 2))
        add_edge!(g2, 1, 3, ("", 3))
        add_edge!(g2, 2, 1, ("", 3))
        add_edge!(g2, 3, 2, ("", 0))
        m2 = AdjacencyMatrix(g2)
        @test SparseMatrixCSC(m2) isa SparseMatrixCSC{Bool, Int}
        @test SparseMatrixCSC(m2) == [1 1 1 0; 1 0 0 0; 0 1 0 0; 0 0 0 0]

        g3 = ValOutDiGraph{UInt32}(4; vertexval_types=(String, Int), vertexval_init=undef)
        add_edge!(g3, 1, 1)
        add_edge!(g3, 1, 3)
        add_edge!(g3, 2, 3)
        add_edge!(g3, 3, 1)
        m3 = AdjacencyMatrix(g3)
        @test SparseMatrixCSC(m3) isa SparseMatrixCSC{Bool, Int}
        @test SparseMatrixCSC(m3) == [1 0 1 0; 0 0 1 0; 1 0 0 0; 0 0 0 0]

        g4 = ValGraph(0, graphvals=(1, 2, "xyz"))
        m4 = AdjacencyMatrix(g4)
        @test SparseMatrixCSC(m4) isa SparseMatrixCSC{Bool, Int}
        @test SparseMatrixCSC(m4) == Matrix{Bool}(undef, 0, 0)

    end

    @testset "convert ValMatrix to SparseMatrixCSC" begin

        g1 = ValGraph{Int8}(4, edgeval_types=(Int,))
        add_edge!(g1, 1, 2, (12,))
        add_edge!(g1, 2, 3, (23,))
        add_edge!(g1, 3, 3, (33,))
        m1 = ValMatrix(g1, 1, 0)
        @test SparseMatrixCSC(m1) isa SparseMatrixCSC{Int, Int}
        @test SparseMatrixCSC(m1) == [0 12 0 0; 12 0 23 0; 0 23 33 0; 0 0 0 0]


        g2 = ValDiGraph{Int16}(4; edgeval_types=(a=String, b=Int))
        add_edge!(g2, 1, 1, ("", 11))
        add_edge!(g2, 1, 2, ("", 12))
        add_edge!(g2, 1, 3, ("", 13))
        add_edge!(g2, 2, 1, ("", 21))
        add_edge!(g2, 3, 2, ("", 32))
        m2 = ValMatrix(g2, :b, 0)
        @test SparseMatrixCSC(m2) isa SparseMatrixCSC{Int, Int}
        @test SparseMatrixCSC(m2) == [11 12 13 0; 21 0 0 0; 0 32 0 0; 0 0 0 0]


        g3 = ValOutDiGraph{UInt32}(4; edgeval_types=(Int, Float64))
        add_edge!(g3, 1, 1, (11, 1.0))
        add_edge!(g3, 1, 3, (13, 1.3))
        add_edge!(g3, 2, 3, (23, 2.3))
        add_edge!(g3, 3, 1, (31, 3.1))
        m3 = ValMatrix(g3, 2, 0.0)
        @test SparseMatrixCSC(m3) isa SparseMatrixCSC{Float64, Int}
        @test SparseMatrixCSC(m3) == [1.0 0 1.3 0; 0 0 2.3 0; 3.1 0 0 0; 0 0 0 0]


        g4 = ValGraph(0, graphvals=(1, 2, "xyz"), edgeval_types=(Float64, String))
        m4 = ValMatrix(g4, 1, 0.0)
        @test SparseMatrixCSC(m4) isa SparseMatrixCSC{Float64, Int}
        @test SparseMatrixCSC(m4) == Matrix{Float64}(undef, 0, 0)

    end


end # testset
