

const CANDIDATE_SQUASH_TYPES = [Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64]

"""
    squash(g::ValGraph)
    squash(g::ValDiGraph)
    squash(g::ValOutDiGraph)

Return a copy of `g` with an `eltype` as small as possible.

This can help with performance. Only the `eltype` is changed, all other
types stay the same.
"""
function squash(g::Union{ValGraph, ValDiGraph, ValOutDiGraph})

    nvg = nv(g)
    # TODO find a more future proof way to extract the unparametrized type
    G = typeof(g).name.wrapper
    for V ∈ CANDIDATE_SQUASH_TYPES

        nvg < typemax(V) && return G{V}(g)
    end
end

# TODO implement destructive squash!
