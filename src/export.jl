
function graphviz_identifier(x)
    s = string(x)
    result = replace(s, "\"" => "\\\"")
    if endswith(result, '\\')
        result = result * " "
    end
    return result
end

function show(io::IO, m::MIME"text/vnd.graphviz", g::AbstractSimpleValueGraph)
    graph_symbol = is_directed(g) ? "digraph" : "graph"
    edge_symbol = is_directed(g) ? "->" : "--"
    println(io, "$graph_symbol {")
    for e in edges(g)
        s, d, v = src(e), dst(e), val(e)
        println(io, "$s $edge_symbol $d [value = \"$(graphviz_identifier(v))\"];")
    end
    println(io, "}")
end
