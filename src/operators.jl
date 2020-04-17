# TODO disabled


# ==== weight related operators =====

# TODO docstring
# TODO maybe better pass a ValueEdge to f
function transform_edgevals!(f::Function, g::ValueGraph)
    V = eltype(g)
    E_VAL = edgeval_type(g)
    n = nv(g)
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index::Int = 1
        while index <= len && list_i[index] <= i
            j = list_i[index]
            new_val = f(V(i), V(j), value_for_index(edgevals, E_VAL, i, index))
            set_value_for_index!(edgevals, V(i), index, new_val)

            index2 = searchsortedfirst(fadjlist[j], i)
            set_value_for_index!(edgevals, V(j), index2, new_val)

            index += 1
        end
    end
end


function transform_edgevals!(f::Function, g::ValueGraph{V, E_VAL, <: TupleOrNamedTuple}, key) where {V, E_VAL}
    n = nv(g)
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index::Int = 1
        while index <= len && list_i[index] <= i
            j = list_i[index]
            new_val = f(V(i), V(j), value_for_index(edgevals, E_VAL, i, index, key))
            set_value_for_index!(edgevals, i, index, key, new_val)

            index2 = searchsortedfirst(fadjlist[j], i)
            set_value_for_index!(edgevals, j, index2, key, new_val)

            index += 1
        end
    end
end

function transform_edgevals!(f::Function, g::OutValueDiGraph)
    V = eltype(g)
    E_VAL = edgeval_type(g)
    n = nv(g)
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index::Int = 1
        while index <= len
            j = list_i[index]
            new_val = f(V(i), V(j), value_for_index(edgevals, E_VAL, i, index))
            set_value_for_index!(edgevals, V(i), index, new_val)

            index += 1
        end
    end
end

function transform_edgevals!(f::Function, g::OutValueDiGraph{V, E_VAL, <: TupleOrNamedTuple}, key) where {V, E_VAL}
    n = nv(g)
    fadjlist = g.fadjlist
    edgevals = g.edgevals
    for i = 1:n
        list_i = fadjlist[i]
        len = length(list_i)
        index::Int = 1
        while index <= len
            j = list_i[index]
            new_val = f(V(i), V(j), value_for_index(edgevals, E_VAL, i, index, key))
            set_value_for_index!(edgevals, i, index, key, new_val)

            index += 1
        end
    end
end
