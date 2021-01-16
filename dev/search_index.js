var documenterSearchIndex = {"docs":
[{"location":"matrices/#Matrices","page":"Matrices","title":"Matrices","text":"","category":"section"},{"location":"matrices/","page":"Matrices","title":"Matrices","text":"SimpleValueGraphs currently supports two kind of matrices from graphs: adjacency matrices that contain the topology of the graph.","category":"page"},{"location":"matrices/#Adjacency-matrices","page":"Matrices","title":"Adjacency matrices","text":"","category":"section"},{"location":"matrices/","page":"Matrices","title":"Matrices","text":"The adjacency_matrix function creates an adjacency matrix from a value graph . In contrast to LightGraphs, this is just a immutable matrix view of the graph, i.e if the graph changes, then so does this matrix. Therefore to get a mutable adjacency matrix one has to convert it before to some other matrix type.","category":"page"},{"location":"matrices/","page":"Matrices","title":"Matrices","text":"It is also possible to use the constructor AdjacencyMatrix to create a view of any LightGraphs.AbstractGraph.","category":"page"},{"location":"matrices/","page":"Matrices","title":"Matrices","text":"julia> g1 = SimpleValueGraphs.swissmetro_graph();\n\njulia> adjacency_matrix(g)\n6×6 AdjacencyMatrix{ValGraph{[...]}:\n 0  0  0  0  0  1\n 0  0  0  1  0  1\n 0  0  0  1  0  0\n 0  1  1  0  0  0\n 0  0  0  0  0  1\n 1  1  0  0  1  0\n\njulia> g2 = smallgraph(:housex)\n{5, 8} undirected simple Int64 graph\n\njulia> AdjacencyMatrix(g2)\n5×5 AdjacencyMatrix{SimpleGraph{Int64}}:\n 0  1  1  1  0\n 1  0  1  1  0\n 1  1  0  1  1\n 1  1  1  0  1\n 0  0  1  1  0","category":"page"},{"location":"matrices/#Value-matrices","page":"Matrices","title":"Value matrices","text":"","category":"section"},{"location":"matrices/","page":"Matrices","title":"Matrices","text":"One can also create a matrix view of the edge values of a graph, where entry (i,j) of the matrix contains the edge value of the edge i -> j. Entries in the matrix for non-existing edges are represented by some extra value.","category":"page"},{"location":"matrices/","page":"Matrices","title":"Matrices","text":"julia> g = ValGraph(3, edgeval_types = (a = Int, b = String));\n\njulia> add_edge!(g, 1, 2, (a=10, b=\"abc\"))\ntrue\n\njulia> add_edge!(g, 1, 3, (a=20, b=\"xyz\"))\ntrue\n\njulia> ValMatrix(g, :a, 0)\n3×3 ValMatrix{Int64,ValGraph{[...]},:a}:\n  0  10  20\n 10   0   0\n 20   0   0\n\njulia> ValMatrix(g, :b, nothing)\n3×3 ValMatrix{Union{Nothing, String},ValGraph{[...]},:b}:\n nothing  \"abc\"    \"xyz\"\n \"abc\"    nothing  nothing\n \"xyz\"    nothing  nothing","category":"page"},{"location":"matrices/","page":"Matrices","title":"Matrices","text":"One can also use the LightGraphs.weights function to obtain this matrix. If the graph does not have any edge values, this returns a LightGraphs.DefaultDistance instead.","category":"page"},{"location":"matrices/","page":"Matrices","title":"Matrices","text":" julia> weights(g1, :a)\n3×3 ValMatrix{Int64,ValDiGraph{[...]},:a}:\n 0  10   0\n 0   0  20\n 0   0   0\n\njulia> g2 = ValDiGraph(3);\n\njulia> add_edge!(g2, 1, 2);\n\njulia> weights(g2)\n3 × 3 default distance matrix (value = 1)","category":"page"},{"location":"graphtypes/#Graph-Types","page":"Graph types","title":"Graph Types","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"SimpleValueGraphs currently defines an abstract graph type and three concrete implementations.","category":"page"},{"location":"graphtypes/#AbstractValGraph","page":"Graph types","title":"AbstractValGraph","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"The abstract type AbstractValGraph denotes a graph that can have multiple vertex and edge values. It has the signature ","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"    AbstractValGraph{V, V_VALS, E_VALS} <: LightGraphs.AbstractGraph{V}","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"where the parameters have the following meaning:","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"V is the type used for indexing vertices, called the eltype of the graph. Should   be a subtype of Integer.\nV_VALS is the type of the vertex values.\nE_VALS is the type of the edge values.","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"The value types V_VALS and E_VALS are either subtypes of Tuple  for unnamed values or of NamedTuple for named values. For example","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"    AbstractValGraph{Int16, NamedTuple{(:label,) Tuple{String}}, Tuple{Int64, Float32}}","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"is an AbstractValGraph with eltype Int16, a single vertex value of type String called label and two unnamed edge values of type Int64 and Float32.","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"Use the empty tuple type Tuple{} to denote that a graph does not have vertex or edge values.","category":"page"},{"location":"graphtypes/#Querying-for-type-information","page":"Graph types","title":"Querying for type information","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"info: Info\nHere we use the function SimpleValueGraphs.swissmetro_graph() to load an example graph. The signature of this graphs type looks a bit more complicated, but we can check what kind of AbstractValGraph it is:julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> supertype(typeof(g))\nAbstractValGraph{\n    Int8,\n    NamedTuple{(:name, :population),Tuple{String,Int32}},\n    NamedTuple{(:distance,),Tuple{Float64}}\n}","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"The eltype of an AbstractValGraph can be queried with the eltype function:","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> eltype(g)\nInt8","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"The types of the vertex and edge values can be queried with vertexvals_type  and edgevals_type","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> vertexvals_type(g)\nNamedTuple{(:name, :population),Tuple{String,Int32}}\n\njulia> edgevals_type(g)\nNamedTuple{(:distance,),Tuple{Float64}}","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"Furthermore we have hasvertexkey and hasedgekey to check if a graph has a vertex or edge value for some specific key:","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> hasvertexkey(g, :name)\ntrue\n\njulia> hasvertexkey(g, :code)\nfalse\n\njulia> hasedgekey(g, 1)\ntrue","category":"page"},{"location":"graphtypes/#Concrete-graphs","page":"Graph types","title":"Concrete graphs","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"     ValGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C} <: AbstractEdgeValGraph{V, V_VALS, E_VALS}\nValOutDiGraph{V, V_VALS, E_VALS, V_VALS_C, E_VALS_C} <: AbstractEdgeValGraph{V, V_VALS, E_VALS}\n   ValDiGraph{V, V_VALS, E_VALS, C_VALS_C, E_VALS_C} <: AbstractEdgeValGraph{V, V_VALS, E_VALS}","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"`V_VALS_Cand E_VALS_C are the types of the internal data structure used to store the  values. These types are always based on V_VALS and E_VALS, and are calculated automatically by the constructor.","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"All three graph types represent simple graphs but also allow for self-loops.","category":"page"},{"location":"graphtypes/#ValGraph","page":"Graph types","title":"ValGraph","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"Is an undirected graph","category":"page"},{"location":"graphtypes/#ValOutDiGraph","page":"Graph types","title":"ValOutDiGraph","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"Is a directed graph that for each vertex only stores the outgoing edges. Therefore it only support iterating over outgoing edges of a specific vertex. The advantage is that it uses much less memory than ValDiGraph.","category":"page"},{"location":"graphtypes/#ValDiGraph","page":"Graph types","title":"ValDiGraph","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"Is a directed graph that for each vertex only stores both the incoming as well as the outgoing edges. Is supports iterating over incoming and outgoing edges of a specific vertex with the disadvantage that it might use nearly twice as much memory as ValOutDiGraph.","category":"page"},{"location":"graphtypes/#Constructors","page":"Graph types","title":"Constructors","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"The constructors for all three graph types are basically the same, so we focus on ValGraph here.","category":"page"},{"location":"graphtypes/#Graphs-without-values","page":"Graph types","title":"Graphs without values","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"Graphs without any values an be created with ","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"    ValGraph{V = Int32}(n)","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"where n is the number of vertices. One notable difference to LightGraphs is that the eltype is not bases on the type of n but is always taken from the parameter V.","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"julia> g1 = ValGraph(4)\n{4, 0} undirected ValGraph with\n              eltype: Int32\n  vertex value types: ()\n    edge value types: ()\n\njulia> g2 = ValDiGraph{Int8}(4)\n{4, 0} directed ValDiGraph with\n              eltype: Int8\n  vertex value types: ()\n    edge value types: ()","category":"page"},{"location":"graphtypes/#Graphs-with-edge-values","page":"Graph types","title":"Graphs with edge values","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"If the graph should have edge values, their types can be specified in the constructor with the keyword argument edgeval_types. This is either a Tuple of types for unnamed edge values or a NamedTuple of types for named edge values.  Note that we still need to use a Tuple or NamedTuple if we have just a single type.","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"# Single unnamed edge value\njulia> g1 = ValGraph(4; edgeval_types=(Int64,))\n{4, 0} undirected ValGraph with\n              eltype: Int32\n  vertex value types: ()\n    edge value types: (Int64,)\n\n# Two named edge values\njulia> g2 = ValDiGraph{Int8}(4; edgeval_types=(a=String, b=Bool))\n{4, 0} directed ValDiGraph with\n              eltype: Int8\n  vertex value types: ()\n    edge value types: (a = String, b = Bool)","category":"page"},{"location":"graphtypes/#Graphs-with-vertex-values","page":"Graph types","title":"Graphs with vertex values","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"Similar to edge vales, vertex values can be specified with the verteval_types keyword argument. But the problem here is, that we already create some vertices in the constructor, so we also must specify how to initialize the values for these vertices. We do that by using the vertexval_initializer keyword argument, which is either undefin case we do not actually want to initialize these values (similar to undef for arrays) or a function v -> values that take a vertex index and returns a tuple or named tuple of vertex values","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"# Single unnamed vertex value, use undef for initialization\njulia> g1 = ValGraph(4; vertexval_types=(Int64,), vertexval_initializer=undef)\n{4, 0} undirected ValGraph with\n              eltype: Int32\n  vertex value types: (Int64,)\n    edge value types: ()\n\n# Two named vertex values, use a function for initialization\njulia> g2 = ValDiGraph{Int8}(4;\n                vertexval_types=(a=String, b=Bool),\n                vertexval_initializer= v -> (a=\"$v\", b=false)\n            )\n{4, 0} directed ValDiGraph with\n              eltype: Int8\n  vertex value types: (a = String, b = Bool)\n    edge value types: ()","category":"page"},{"location":"graphtypes/#Graph-from-LightGraphs-SimpleGraphs","page":"Graph types","title":"Graph from LightGraphs SimpleGraphs","text":"","category":"section"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"One can also initialize a graph from a LightGraphs SimpleGraph or SimpleDiGraph. If edge values are specified (with the edgeval_types keyword) we also need an initializer for edge values. We do that by using the edgeval_initializer keyword argument which can be either undef or a function (s, d) -> values that takes a source and target vertex and and return a tuple or named tuple of edge values.  The constructor takes care that it calls this function only with s <= d  for undirected graphs, so that we do not have to worry about symmetry. This is not the case if one uses undef though.","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"Furthermore, if the eltype is not specified as a parameter, it is taken from the simple graph.","category":"page"},{"location":"graphtypes/","page":"Graph types","title":"Graph types","text":"julia> using LightGraphs: smallgraph, PathDiGraph\n\njulia> g_simple = smallgraph(:house)\n{5, 6} undirected simple Int64 graph\n\njulia> g1 = ValGraph(g_simple;\n                edgeval_types=(Int64, ),\n                edgeval_initializer=(s, d) -> (s + d, )\n            )\n{5, 6} undirected ValGraph with\n              eltype: Int64\n  vertex value types: ()\n    edge value types: (Int64,)\n\njulia> g_simple_directed = PathDiGraph(3)\n{3, 2} directed simple Int64 graph\n\njulia> g2 = ValOutDiGraph{Int8}(g_simple_directed;\n                vertexval_types=(String, ),\n                vertexval_initializer=undef\n            )\n{3, 2} directed ValOutDiGraph with\n              eltype: Int8\n  vertex value types: (String,)\n    edge value types: ()","category":"page"},{"location":"modification/#Modifying-Graph-Properties","page":"Modifying graphs","title":"Modifying Graph Properties","text":"","category":"section"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"Subtypes of AbstractValGraph are not by default modifiable, but ValGraph, ValOutDiGraph and ValDiGraph are. Modifiable graphs may implement some of the methods here.","category":"page"},{"location":"modification/#Modifying-vertices","page":"Modifying graphs","title":"Modifying vertices","text":"","category":"section"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"To add a vertex, use the add_vertex method. If the graph has vertex values, they must also be passed to this function.","category":"page"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"julia> g2 = ValGraph(0, vertexval_types=(a=Int, ), vertexval_initializer=undef);\n\njulia> add_vertex!(g2, (a=50,))\ntrue\n\njulia> g1 = ValGraph(4);\n\njulia> add_vertex!(g1)\ntrue\n\njulia> g2 = ValGraph(0, vertexval_types=(a=Int, ), vertexval_initializer=undef);\n\njulia> add_vertex!(g2, (a=50,))\ntrue","category":"page"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"Vertex values can be set using the set_vertexval! function.","category":"page"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"julia> g = ValGraph(5, vertexval_types=(a=Int, String), vertexval_initializer=undef);\n\njulia> set_vertexval!(g, 1, :a, 50)\ntrue","category":"page"},{"location":"modification/#Modifying-edges","page":"Modifying graphs","title":"Modifying edges","text":"","category":"section"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"To add an edge, one can use the add_edge! method. As with vertices, if the graph has edge values, one must pass them to the function. If the edge already exists in that graph, it will change them to the new values.","category":"page"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"julia> g = ValDiGraph(5, edgeval_types=(Int,));\n\njulia> add_edge!(g, 1, 2, (10,))\ntrue\n\njulia> add_edge!(g, 1, 2, (20,))\nfalse\n\njulia> get_edgeval(g, 1, 2, :)\n(20,)","category":"page"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"One can remove edges using the rem_edge! function.","category":"page"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"julia> g = ValDiGraph(5, edgeval_types=(Int,));\n\njulia> add_edge!(g, 1, 2, (10,))\ntrue\n\njulia> ne(g)\n1\n\njulia> rem_edge!(g, 1, 2)\ntrue\n\njulia> ne(g)\n0","category":"page"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"To modify edge values, one can use the set_edgeval! function","category":"page"},{"location":"modification/","page":"Modifying graphs","title":"Modifying graphs","text":"julia> g = ValDiGraph(5, edgeval_types=(a=Int,b=String));\n\njulia> add_edge!(g, 1, 2, (a=10, b=\"xyz\"))\ntrue\n\njulia> set_edgeval!(g, 1, 2, :a, 20)\ntrue\n\njulia> set_edgeval!(g, 1, 2, :, (30, \"abc\"))\ntrue","category":"page"},{"location":"access/#Accessing-Graph-Properties","page":"Accessing graphs","title":"Accessing Graph Properties","text":"","category":"section"},{"location":"access/#Accessing-vertices","page":"Accessing graphs","title":"Accessing vertices","text":"","category":"section"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"To get the number of vertices of a graph one can use the nv function:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> nv(g)\n6","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"The vertex ids of a graph can be queried with the vertices function","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> vertices(g)\nBase.OneTo(6)\n\njulia> vertices(g) |> collect\n6-element Array{Int8,1}:\n 1\n 2\n 3\n 4\n 5\n 6","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"One can check if a graph has a specific vertex with the has_vertex function:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> has_vertex(g, 1)\ntrue\n\njulia> has_vertex(g, 8)\nfalse","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"To query for the vertex value of a graph g, one an use the function get_vertexval(g, vertex_id, key), where key is a Integer or in the case of named values also a Symbol that specifies which vertex value we are interested in:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\n# The first value of vertex 6, i.e. :name\njulia> get_vertexval(g, 6, 1)\n\"Zürich\"\n\n# The value of vertex 6 that is called :population\njulia> get_vertexval(g, 6, :population)\n415215","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"One can also query for all values of a vertex with the colon operator : as key:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> get_vertexval(g, 6, :)\n(name = \"Zürich\", population = 415215)","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"To iterate over neighboring vertices of a vertex, one can use the functions inneighbors, outneighbors, and all_neighbors. Note that while innehgbors and all_neighbors work also for graphs of type ValOutDiGraph, they may be rather slow.","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = ValOutDiGraph(path_digraph(3));\n\njulia> inneighbors(g, 2)\n1-element Array{Int64,1}:\n 1\n\njulia> outneighbors(g, 2)\n1-element Array{Int64,1}:\n 3\n\njulia> all_neighbors(g, 2)\n2-element Array{Int64,1}:\n 3\n 1","category":"page"},{"location":"access/#Accessing-edges","page":"Accessing graphs","title":"Accessing edges","text":"","category":"section"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"To get the number of vertices of a graph one can use the ne function:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> ne(g)\n5","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"To get all edges of g use the edges function. This function has an optional key argument, if it is set to :, then also all edge values are returned.","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"g = SimpleValueGraphs.swissmetro_graph();\n\njulia> collect(edges(g))\n5-element Array{ValEdge{Int8,Tuple{}},1}:\n ValEdge 1 -- 6\n\n ValEdge 2 -- 4\n\n ValEdge 2 -- 6\n\n ValEdge 3 -- 4\n\n ValEdge 5 -- 6\n\n\njulia> collect(edges(g, :))\n5-element Array{ValEdge{Int8,NamedTuple{(:distance,),Tuple{Float64}}},1}:\n ValEdge 1 -- 6 with value distance = 89.0\n\n ValEdge 2 -- 4 with value distance = 81.0\n\n ValEdge 2 -- 6 with value distance = 104.0\n\n ValEdge 3 -- 4 with value distance = 68.0\n\n ValEdge 5 -- 6 with value distance = 69.0\n\n\njulia> \n","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"To check if g has an edge between two vertices, one can use the has_edge function:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> has_edge(g, 1, 2)\nfalse\n\njulia> has_edge(g, 1, 6)\ntrue\n\njulia> has_edge(g, 6, 1)\ntrue","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"To query for the edge value between vertices s and d in g, one an use the function get_edgeval(g, s, d, key), where key is a Integer or in the case of named values also a Symbol that specifies which edge value we are interested in:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\n# The first value of the edge between 1 and 6, i.e. :name\njulia> get_edgeval(g, 1, 6, 1)\n89.0\n\n# We can also use the name :distance\njulia> get_edgeval(g, 1, 6, :distance)\n89.0","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"One can also query for all values of an edge with the colon operator : as key:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> get_edgeval(g, 1, 6, :)\n(distance = 89.0,)","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"There is also the function get_edgeval_or that returns an alternative value if that edge does not exist:","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\njulia> get_edgeval_or(g, 1, 1, :distance, missing)\nmissing\n\njulia> get_edgeval_or(g, 1, 6, :distance, missing)\n89.0","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"To query for the ingoing or outgoing edge values for some vertex v, one can use the inedgevals and outedgevals functions.","category":"page"},{"location":"access/","page":"Accessing graphs","title":"Accessing graphs","text":"julia> g = SimpleValueGraphs.swissmetro_graph();\n\n# ingoing edge values for vertex 6 and values for key 1\njulia> inedgevals(g, 6, 1)\n3-element Array{Float64,1}:\n  89.0\n 104.0\n  69.0\n\n# outgoing edge values for vertex 6 and values for key :distance\njulia> outedgevals(g, 6, :distance)\n3-element Array{Float64,1}:\n  89.0\n 104.0\n  69.0","category":"page"},{"location":"#Home","page":"Home","title":"Home","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This documentation is currently very much work in progress, though it already contains some basic that should get one started.","category":"page"}]
}
