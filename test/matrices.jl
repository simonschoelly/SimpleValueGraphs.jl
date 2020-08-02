using LinearAlgebra: ishermitian, issymmetric
using SparseArrays: AbstractSparseMatrix

@testset "matrices" begin

    @testset "AdjacencyMatrix" begin

        for G      in (EdgeValGraph, EdgeValOutDiGraph, EdgeValDiGraph),
            V      in TEST_VERTEX_TYPES_SMALL,
            E_VALS in TEST_EDGEVAL_TYPES_SMALL,
            gs     in make_testgraphs(is_directed(G) ? SimpleDiGraph{V} : SimpleGraph{V})

            g = G{V, E_VALS}((s, d) -> rand_sample(E_VALS), gs.graph)

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

                if g isa EdgeValGraph
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

end
