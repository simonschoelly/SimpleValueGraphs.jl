#  ======================================================
#  Constructors
#  ======================================================


mutable struct SimpleValueDiGraph{T<:Integer, U} <: AbstractSimpleValueGraph{T, U}
    ne::Integer
    fadjlist::Vector{Vector{T}}
    badjlist::Vector{Vector{T}}
    value_fadjlist::Vector{Vector{U}}
end

SimpleValueDiGraph(nv::Integer) = SimpleValueDiGraph(nv::Integer, default_value_type)

function SimpleValueDiGraph(nv::T, ::Type{U}) where {T<:Integer, U} 
    fadjlist = Vector{Vector{T}}(undef, nv)
    badjlist = Vector{Vector{T}}(undef, nv)
    value_fadjlist = Vector{Vector{U}}(undef, nv)
    for u in Base.OneTo(nv)
        fadjlist[u] = Vector{T}()
        badjlist[u] = Vector{T}()
        value_fadjlist[u] = Vector{U}()
    end
    SimpleValueDiGraph(0, fadjlist, badjlist, value_fadjlist)
end

SimpleValueDiGraph(g::SimpleDiGraph) = SimpleValueDiGraph(g, default_value_type)

function SimpleValueDiGraph(g::SimpleDiGraph{T}, ::Type{U}) where {T, U}
    n = nv(g)
    ne_ = ne(g)
    fadjlist = deepcopy(g.fadjlist)
    badjlist = deepcopy(g.fadjlist)
    value_fadjlist = Vector{Vector{U}}(undef, n)
    for u in Base.OneTo(n)
        len = length(fadjlist[u])
        list = Vector{U}(undef, len)
        for i in Base.OneTo(len) 
            list[i] = default_value(SimpleValueDiGraph{T, U})
        end
        value_fadjlist[u] = list
    end
    SimpleValueGraph(ne_, fadjlist, badjlist, value_fadjlist)
end

