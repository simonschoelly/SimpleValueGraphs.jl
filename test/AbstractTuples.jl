using SimpleValueGraphs.AbstractTuples

@testset "AbstractTuples" begin

tuples = [(), (1, ), (1, 2)]
named_tuples = [NamedTuple{}(), (a=1,), (a=1, b='2')]
all_tuples = [tuples; named_tuples]
not_abstract_tuples = [Int[], [1, 2], 1, Tuple, Tuple{Int, Int}, NamedTuple]

@testset "$t isa AbstractTuple" for t in all_tuples
    @test t isa AbstractTuple
end

@testset "$t isa AbstractTuple{$T}" for t in tuples, T in (typeof(t),)
    @test t isa AbstractTuple{T}
end

@testset "$t isa AbstractTuple{$T}" for
        t in named_tuples,
        T in (typeof(Tuple(t)),)

    @test t isa AbstractTuple{T}
end

@testset "$T <: AbstractTuple" for T in map(typeof, tuples)
    @test T <: AbstractTuple
end

@testset "$T <: AbstractTuple{$T}" for T in map(typeof, tuples)
    @test T <: AbstractTuple{T}
end

@testset "$T <: AbstractTuple{$TT}" for
        t in named_tuples,
        T in (typeof(t),),
        TT =  (typeof(Tuple(t)),)

    @test T <: AbstractTuple
end

@testset "!($t isa AbstractTuple" for t in not_abstract_tuples
    @test !(t isa AbstractTuple)
end

@test (a=1, b=2) isa NamedNTuple
@test (a=1, b=2) isa NamedNTuple{2}
@test (a=1, b=2) isa NamedNTuple{2, Int}
@test !((a=1, b=2) isa NamedNTuple{3})
@test !((a=1, b="2") isa NamedNTuple{2})
@test !((a=1, b=2) isa NamedNTuple{2, String})
@test !((1, 2) isa NamedNTuple)

@test (1, 2) isa AbstractNTuple
@test (a=1, b=2) isa AbstractNTuple
@test (1, 2) isa AbstractNTuple{2}
@test (a=1, b=2) isa AbstractNTuple{2}
@test (1, 2) isa AbstractNTuple{2, Int}
@test (a=1, b=2) isa AbstractNTuple{2, Int}
@test !((1, 2) isa AbstractNTuple{3})
@test !((a=1, b=2) isa AbstractNTuple{3})
@test !((1, "2") isa AbstractNTuple{2, Int})
@test !((a=1, b="2") isa AbstractNTuple{2, Int})
@test !((1, 2) isa AbstractNTuple{2, String})
@test !((a=1, b=2) isa AbstractNTuple{2, String})

end


