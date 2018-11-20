@testset "LightGraphs functions" begin

# This rather messy file is more of a TODO list than a proper testset at the moment.

#=
@testset "a_star" begin
    g = testgraphA()
    @info a_star(g, 1, 4)
    @info a_star(g, 1, 4, ones(nv(g), nv(g)) )
end

@testset "add_vertex!" begin
    g = testgraphA()
    add_vertex!(g)
    Base.print_matrix(stdout, weights(g))
end
@testset "add_vertices!" begin
    g = testgraphA()
    @test add_vertices!(g, 2) == 2
    Base.print_matrix(stdout, weights(g))
end
@testset "adjacency_matrix" begin
    g = testgraphA()
    @info adjacency_matrix(g)
end
@testset "adjacency_spectrum" begin
    g = testgraphA()
    @info adjacency_spectrum(g)
end
@testset "articulation" begin
    g = SimpleValueGraph(PathGraph(5))
    add_edge!(g, 2, 3, 10.0)
    add_edge!(g, 3, 4, 0.0)
    @test sort(articulation(g)) == [2,3,4]
end
@testset "attracting_components" begin
    # TODO only defined for directed graphs
end


@testset "barabasi_albert!" begin
    g = testgraphA()
    nv_old = nv(g)
    ne_old = ne(g)
    n = 10
    k = 3
    barabasi_albert!(g, n, k)
    @test nv(g) == n
    @test ne(g) == (n - nv_old) * k + ne_old
end
@testset "bellman_ford_shortest_paths" begin
    g = testgraphA()
    @test bellman_ford_shortest_paths(g, 1).dists == bellman_ford_shortest_paths(g, 1, weights(g)).dists
    @info bellman_ford_shortest_paths(g, [2, 4])
end
@testset "bfs_parents" begin
    g = testgraphA()
    @test length(bfs_parents(g, 1)) == nv(g) 
    @test length(bfs_parents(g, 1, dir=:in)) == nv(g) 
end
@testset "bfs_tree" begin
    g = testgraphA()
    @test nv(bfs_tree(g, 1)) == nv(g) 
    @test ne(bfs_tree(g, 1, dir=:in)) == nv(g) - 1
end
@testset "bipartite_map" begin
    g = SimpleValueGraph(CompleteBipartiteGraph(3,5))
    @info bipartite_map(g)
    @test length(bipartite_map(SimpleValueGraph(CycleGraph(5)))) == 0
end
@testset "blockcounts" begin
    # TODO not sure how that works
end
@testset "blockfractions" begin
    # TODO not sure how that works
end
@testset "cartesian_product" begin
    g = testgraphA()
    g2 = cartesian_product(g, g)
    @test nv(g2) == nv(g)^2
    Base.print_matrix(stdout, weights(g2))
    # TODO cartesian product does not yet consider weights
end
=#

@testset "common_neighbors" begin
    g = testgraphA()
    @test common_neighbors(g, 1, 2) == [4,5,6,7]
end

#=
@testset "connected_components" begin
    g = testgraphA()
    @test length(connected_components(blockdiag(g,g))) == 2
end

@testset "core_number" begin
    g = SimpleValueGraph(StarGraph(7))
    @test unique(core_number(g)) == [1]
end

@testset "crosspath" begin
    # TODO this does not work as intended
end

@testset "cycle_basis" begin
    # TODO only works for AbstractSimpleGraphs
end


@testset "degree" begin
    @info "degree"
    g = SimpleValueGraph(CompleteBipartiteGraph(2,3))
    @test degree(g) == [3, 3, 2, 2, 2]
    @test degree(g, 1) == 3
end

@testset "degree_centrality" begin
    @info "degree_centrality"
    g = erdos_renyi(10, 20)
    h = SimpleValueGraph(g)
    @test degree_centrality(g) == degree_centrality(h)
end

@testset "dfs_tree" begin
    @info "dfs_tree"
    g = erdos_renyi(10, 20)
    h = graph_with_randvals(g)
    @test dfs_tree(g, 2) == dfs_tree(h, 2)
end

@testset "diameter" begin
    @info "diameter"
    #= seems to crash for some reasons
    g = erdos_renyi(10, 30)
    h = graph_with_randvals(g)
    @test diameter(g) == diameter(h)
    =#
end

@testset "difference" begin
    # TODO this operators does not work correctly yet
end

@testset "diffusion" begin
    @info "diffusion"
    # TODO this seems to work, but diffusion should maybe consider the weights
    g = testgraphA()
    @info diffusion(g, 0.5, 4)
    @info diffusion_rate(g, 0.5, 4)
end

@testset "dijkstra_shortest_paths" begin
    @info "diijkstar_shortest_paths"
    # TODO test with different weights
    # TODO crashes with negative weights or zero weights
    g = SimpleValueGraph(5)
    add_edge!(g, 1, 2, 2.5)
    add_edge!(g, 1, 3, 0.1)
    add_edge!(g, 1, 4, 1.5)
    add_edge!(g, 1, 5)
    add_edge!(g, 2, 5)

    @test dijkstra_shortest_paths(g, 1).dists[2:end] == [2.0, 0.1, 1.5, 1.0]
end

@testset "eccentricity" begin
    # TODO not working, relies on dijkstra
end

@testset "edit_distance" begin
    # TODO should edit_distance use the weights?
end

@testset "egonet" begin
    # TODO not working, could be because it relies on induced subgraph
end

@testset "eigenvector_centrality" begin
    g = testgraphA()
    @info eigenvector_centrality(g)
end

@testset "floyd_warshall_shortest_paths" begin
    # TODO verify that this really works with negative values
    g = graph_with_randvals(erdos_renyi(10, 30))
    @info floyd_warshall_shortest_paths(g)
end

@testset "gdistances" begin
    g = erdos_renyi(10, 20)
    h = SimpleValueGraph(g)
    @test gdistances(h, 2) == gdistances(g, 2)
    dists = fill(typemax(eltype(h)), nv(h))
    gdistances!(h, 3, dists)
    @test dists == gdistances(g, 3)
end

@testset "global_clustering_coefficient" begin
    g = erdos_renyi(10, 20)
    h = SimpleValueGraph(g)
    @test global_clustering_coefficient(h) == global_clustering_coefficient(g)
end

@testset "greedy_color" begin
    g = graph_with_randvals(CompleteMultipartiteGraph([2,3,4,5]))
    @test greedy_color(g, sort_degree=false, reps=5).num_colors >= 4
    @test greedy_color(g, sort_degree=true, reps=5).num_colors >= 4
end

@testset "has_negative_edge_cycle" begin
    # TODO this functions ignores edge weights at the moment
end

@testset "has_path" begin
    g = erdos_renyi(20, 0.1)
    h = graph_with_randvals(g)
    @test all(v -> has_path(g, 2, v, exclude_vertices=[3,4]) == has_path(h, 2, v, exclude_vertices=[3,4]), vertices(g))
end

@testset "has_self_loops" begin
    g = graph_with_randvals(testgraphA())
    @test !has_self_loops(g)
    add_edge!(g, 5, 5)
    @test has_self_loops(g)
end

@testset "label_propagation" begin
    # TODO function does not consider weights at the moment
    g = CompleteGraph(4)
    h = graph_with_randvals(blockdiag(g, g))
    add_edge!(h, 1, nv(g) + 1)
    @test length(unique(label_propagation(h)[1])) == 2
end

@testset "laplacian_matrix" begin
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test laplacian_matrix(g) == laplacian_matrix(h)
    # TODO does not consider weights at the moment
end

@testset "laplacian_spectrum" begin
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test laplacian_spectrum(g) ≈ laplacian_spectrum(h)
    # TODO does not consider weights at the moment
end

=#

@testset "laplacian_spectrum" begin
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test local_clustering(g, 2) == local_clustering(h, 2)
end

@testset "laplacian_spectrum" begin
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test local_clustering_coefficient(g, 2) == local_clustering_coefficient(h, 2)
end


@testset "maximal_cliques" begin
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test maximal_cliques(g) == maximal_cliques(h)
end

#=

@testset "maximum_adjacency_visit" begin
    # TODO ducmentation is wrong, default weights are only 1.0 for simple graphs
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test maximum_adjacency_visit(g, weights(h)) == maximum_adjacency_visit(h)
    @test maximum_adjacency_visit(g, weights(h)) == maximum_adjacency_visit(h, weights(h))
end

@testset "merge_vertices" begin
    # TODO merge_vertices and merge_vertices! do not work correctly yet
end

@testset "mincut" begin
    # TODO check what happens for negative weights
    g = SimpleValueGraph(3)
    add_edge!(g, 1, 2, 0.1)
    add_edge!(g, 1, 3, 1.0)
    add_edge!(g, 2, 3, 0.1)
    @test mincut(g)[2] ≈ 0.2
end


@testset "neighborhood" begin
    # TODO what about negative values?
    g = SimpleValueGraph(4)
    add_edge!(g, 1, 2, 0.5)
    add_edge!(g, 2, 3, 1.5)
    add_edge!(g, 3, 4, 1.5)
    @test sort(neighborhood(g, 2, 0.2)) == [2]
    @test sort(neighborhood(g, 2, 1.2)) == [1, 2]
    @test sort(neighborhood(g, 2, 2.2)) == [1, 2, 3]

    dists = sort(neighborhood_dists(g, 2, 10.0))
    compare_to = [(1, 0.5), (2, 0.0), (3, 1.5), (4, 3.0)]
    @test all(i -> dists[i][2] ≈ compare_to[i][2], 1:length(compare_to))
end

@testset "non_backtracking_matrix" begin
    # TODO this functions and non_backtracking_randomwalk do not work yet
end
=#


@testset "num_self_loops" begin
    g = graph_with_randvals(testgraphA())
    @test num_self_loops(g) == 0
    add_edge!(g, 3, 3)
    @test num_self_loops(g) == 1
    add_edge!(g, 4, 4)
    @test num_self_loops(g) == 2
end


#=
@testset "outdegree" begin
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test outdegree(g) == outdegree(h)
    @test all(v -> outdegree(g, v) == outdegree(h, v), vertices(g))
end

@testset "outdegree_centrality" begin
    # TODO outdegree_centrality is not documented
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test outdegree_centrality(g) == outdegree_centrality(h)
end

@testset "pagerank" begin
    # TODO pagerank seems not to consider weights
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @test pagerank(g) ≈ pagerank(h)
end

@testset "period" begin
    # TODO works only with directed graphs
end

@testset "periphery" begin
    # TODO not working, relies on dijkstra
end

@testset "periphery" begin
    # TODO not working, relies on dijkstra
end

@testset "prim_mst" begin
    # TODO seems, to work but returns SimpleGraph Edges, verify that this is the right approach
end

@testset "radiality_centrality" begin
    # TODO not working, relies on dijkstra
end

@testset "radius" begin
    # TODO not working, relies on dijkstra
end

@testset "randomwalk" begin
    # TODO maybe should consider edge_weights
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @info randomwalk(h, 2, 20)
end

@testset "savegraph" begin
    # TODO not yet working
end
=#

@testset "saw" begin
    g = erdos_renyi(20, 30)
    h = graph_with_randvals(g)
    @info saw(h, 2, 100)
end

#=
@testset "simplecycles_hawick_james" begin
    # TODO seems only to work with SimpleGraphs
end

@testset "spectral_distance" begin
    # TODO should to involve weights?
    g1 = erdos_renyi(20, 30)
    g2 = erdos_renyi(20, 35)
    h1 = graph_with_randvals(g1)
    h2 = graph_with_randvals(g2)
    @test spectral_distance(g1, g2) == spectral_distance(h1, h2)
end

@testset "squash" begin
    # TODO does not work yet, maybe implement using convert
end

@testset "stress_centrality" begin
    # TODO does use weights?
    # TODo does not work, relies on dijkstra
end

@testset "strongly_connected_components" begin
    # TODO only works for directed graphs
end

@testset "symmetric difference" begin
    # TODO not correctly implemented yet
end
=#

@testset "tensor_product" begin
    # TODO does not work correctly yet
end

@testset "topological_sort_by_dfs" begin
    # TODO only works for directed graphs
end

#=
@testset "randomwalk" begin
    # TODO maybe should consider edge_weights
    g = erdos_renyi(10, 40)
    h = graph_with_randvals(g)
    @test triangles(g) == triangles(h)
end
=#

@testset "tensor_product" begin
    # TODO does not work correctly yet
end

@testset "union" begin
    # TODO does not work correctly yet
end


@testset "vertex_cover" begin
    g = erdos_renyi(10, 40)
    h = graph_with_randvals(g)
    @test vertex_cover(g, DegreeVertexCover()) == vertex_cover(h, DegreeVertexCover())
end


@testset "yen_k_shortest_paths" begin
    # TODO seems to freeze for negtive cycles
end

end


