using LinearAlgebra: ishermitian, issymmetric, mul!
using SparseArrays: AbstractSparseMatrix
using SimpleValueGraphs: OneEdgeValGraph
using Graphs: DefaultDistance

@testset "matrices" begin

    @testset "AdjacencyMatrix" begin

        for G      in (ValGraph, ValDiGraph),
            V      in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            gs     in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

            g = DummyValGraph(G{V, Tuple{}, E_VALS}(gs.graph;
                edgeval_init=(s, d) -> rand_sample(E_VALS)
            ))

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

                if !is_directed(g)
                    @testset "ishermitian for undirected" begin
                        @test ishermitian(a)
                    end

                    @testset "issymmetric for undirected" begin
                        @test issymmetric(a)
                    end

                    @testset "adjoint is same matrix for undirected" begin
                        @test adjoint(a) === a
                    end

                    @testset "transpose is same matrix for undirected" begin
                        @test transpose(a) === a
                    end
                end

                @testset "ishermitian" begin
                    @test ishermitian(a) == ishermitian(Matrix(a))
                end

                @testset "issymmetric" begin
                    @test issymmetric(a) == issymmetric(Matrix(a))
                end

                @testset "adjoint" begin
                    @test adjoint(a) == adjoint(Matrix(a))
                end

                @testset "transpose" begin
                    @test transpose(a) == transpose(Matrix(a))
                end

            end
        end

    end

    @testset "mul! with AdjacencyMatrix and Vector" begin

        g1 = DummyValGraph(ValGraph{Int8}(6))
        add_edge!(g1, 2, 3)
        add_edge!(g1, 2, 4)
        add_edge!(g1, 5, 5)
        v1 = zeros(Float64, 6)
        mul!(v1, adjacency_matrix(g1), [1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
        @test v1 == [0.0, 7.0, 2.0, 2.0, 5.0, 0.0]

        g2 = DummyValGraph(ValDiGraph{Int16}(6))
        add_edge!(g2, 1, 1)
        add_edge!(g2, 2, 3)
        add_edge!(g2, 3, 4)
        add_edge!(g2, 4, 3)
        add_edge!(g2, 4, 5)
        v2 = zeros(Int16, 6)
        mul!(v2, adjacency_matrix(g2), [1, 2, 3, 4, 5, 6])
        @test v2 == [1, 3, 4, 8, 0, 0]
    end

    @testset "ValMatrix" begin
        for G      in (ValGraph, ValDiGraph),
            V      in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            gs     in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

            g = DummyValGraph(G{V, Tuple{}, E_VALS}(gs.graph;
                edgeval_init=(s, d) -> rand_sample(E_VALS)
            ))

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

                        if eltype(M) <: Union{Number, Missing}
                            @testset "ishermitian" begin
                                 @test ishermitian(M) == ishermitian(Matrix(M))
                            end
                        end

                        if eltype(M)  <: Union{Number, Missing}
                            @testset "issymmetric" begin
                                @test issymmetric(M) == issymmetric(Matrix(M))
                            end
                        end

                        if eltype(M) <: Real && !is_directed(g)
                            @testset "adjoint for real, symmetric" begin
                                @test adjoint(M) === M
                            end
                        end

                        if eltype(M) <: Union{Number, Missing}
                            @testset "adjoint" begin
                                @test adjoint(M) == adjoint(Matrix(M))
                            end
                        end

                        if !is_directed(g)
                            @testset "transpose for symmetric" begin
                                @test transpose(M) === M
                            end
                        end

                        if eltype(M) <: Union{Number, Missing}
                            @testset "transpose" begin
                                @test transpose(M) == transpose(Matrix(M))
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
        G      in (ValGraph, ValDiGraph),
        V      in TEST_VERTEX_TYPES_SMALL,
        E_VALS in (Tuple{}, NamedTuple{(), Tuple{}}),
        gs     in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

        g = DummyValGraph(G{V, Tuple{}, E_VALS}(gs.graph;
            edgeval_init=(s, d) -> rand_sample(E_VALS))
        )

        @test weights(g) == DefaultDistance(nv(g))
    end

    @testset "weights for graph with two edge values and no key specified" begin

        @test_throws ArgumentError weights(DummyValGraph(ValGraph(3, edgeval_types=(a=Int, b=String))))
        @test_throws ArgumentError weights(DummyValGraph(ValDiGraph(2, edgeval_types=(Int, String))); zerovalue=nothing)
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

        g4 = DummyValGraph(ValGraph(0, graphvals=(1, 2, "xyz")))
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
