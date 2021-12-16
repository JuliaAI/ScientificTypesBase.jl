struct MockMLJ <: Convention end

@testset "void types" begin
    @test scitype(nothing, MockMLJ()) == Nothing
    @test scitype(missing, MockMLJ()) == Missing
    @test scitype([nothing, nothing], MockMLJ()) == AbstractVector{Nothing}
end

@testset "scitype" begin
    X = [1, 2, 3]
    @test scitype(X, MockMLJ()) == AbstractVector{Unknown}

    @test scitype(missing, MockMLJ()) == Missing
    @test scitype((5, 2), MockMLJ()) == Tuple{Unknown,Unknown}
    anyv = Any[5]
    @test scitype(anyv[1], MockMLJ()) == Unknown

    X = [missing, 1, 2, 3]
    @test scitype(X, MockMLJ()) == AbstractVector{Union{Missing, Unknown}}

    Xnm = X[2:end]
    @test scitype(Xnm, MockMLJ()) == AbstractVector{Union{Missing, Unknown}}

    Xm = Any[missing, missing]
    @test scitype(Xm, MockMLJ()) == AbstractVector{Missing}

    @test scitype([missing, missing], MockMLJ()) == AbstractVector{Missing}
end

@testset "scitype2" begin
    ScientificTypesBase.Scitype(::Type{<:Integer}, ::MockMLJ) = Count
    X = [1, 2, 3]
    @test scitype(X, MockMLJ()) == AbstractVector{Count}
    Xm = [missing, 1, 2, 3]
    @test scitype(Xm, MockMLJ()) == AbstractVector{Union{Missing,Count}}
    Xnm = Xm[2:end]
    @test scitype(Xnm, MockMLJ()) == AbstractVector{Union{Missing,Count}}
end

@testset "temporal types" begin
    @test ScientificDate <: ScientificTimeType
    @test ScientificDateTime <: ScientificTimeType
    @test ScientificTime <: ScientificTimeType
end

@testset "compositional" begin
    @test Compositional{3} <: Known
end

@testset "Empty array" begin
    ScientificTypesBase.Scitype(::Type{<:Integer}, ::MockMLJ) = Count
    ScientificTypesBase.Scitype(::Type{Missing}, ::MockMLJ) = Missing
    @test scitype(Int[], MockMLJ()) == AbstractVector{Count}
    @test scitype(Any[], MockMLJ()) == AbstractVector{Unknown}
    @test scitype(Missing[], MockMLJ()) == AbstractVector{Missing}
    @test scitype(Vector{Union{Int,Missing}}(), MockMLJ()) == AbstractVector{Union{Missing,Count}}
end
