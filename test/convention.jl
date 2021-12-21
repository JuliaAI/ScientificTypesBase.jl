@testset "nonmissing" begin
    U = Union{Missing,Int}
    @test nonmissing(U) == Int
end

@testset "table" begin
    T0 = Table(Continuous)
    @test T0 == Table{K} where K<:AbstractVector{<:Continuous}
    T1 = Table(Continuous, Count)
    @test T1 == Table{K} where K<:Union{AbstractVector{<:Continuous}, AbstractVector{<:Count}}
    T2 = Table(Continuous, Union{Missing,Continuous})
    @test T2 == Table{K} where K<:Union{AbstractVector{<:Union{Missing,Continuous}}}
end
