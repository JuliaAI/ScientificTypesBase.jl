module ScientificTypesBase

# Type exports
export Convention

# re-export-able types and methods
export Scientific, Found, Unknown, Known, Finite, Infinite,
    OrderedFactor, Multiclass, Count, Continuous,
    ScientificTimeType, ScientificDate, ScientificDateTime,
    ScientificTime,
    Textual, Binary,
    ColorImage, GrayImage, Image, Table,
    Density, Sampleable,
    ManifoldPoint,
    Annotated, AnnotationOf, Multiset, Iterator,
    Compositional

export elscitype, nonmissing
# -------------------------------------------------------------------
# Scientific Types

abstract type Found          end
abstract type Known <: Found end
abstract type Unknown <: Found end

abstract type Annotated{S} <: Known end
abstract type AnnotationOf{S} <: Known end
abstract type Multiset{S} <: Known end

# for iterators over objects with scitype Ω that do not have some
# AbstractVector scitype:
abstract type Iterator{Ω} end

abstract type Infinite <: Known end
abstract type Finite{N} <: Known end
abstract type Image{W,H} <: Known end
abstract type ScientificTimeType <: Known end
abstract type Textual <: Known end
abstract type Table{K} <: Known end

abstract type Continuous <: Infinite end
abstract type Count <: Infinite end

abstract type Multiclass{N} <: Finite{N} end
abstract type OrderedFactor{N} <: Finite{N} end

abstract type ScientificDate <: ScientificTimeType end
abstract type ScientificTime <: ScientificTimeType end
abstract type ScientificDateTime <: ScientificTimeType end

abstract type GrayImage{W,H} <: Image{W,H} end
abstract type ColorImage{W,H} <: Image{W,H} end

# when sampled, objects with these scitypes return objects of scitype Ω:
abstract type Sampleable{Ω} end
abstract type Density{Ω} <: Sampleable{Ω} end

abstract type ManifoldPoint{M} <: Known end

# compositional data with D components, see CoDa.jl
abstract type Compositional{D} <: Known end

# aliases:
const Binary = Finite{2}
const Scientific = Union{Missing,Found} # deprecated (no longer publicized)

# for internal use
const Arr = AbstractArray
const TUPLE_SPECIALIZATION_THRESHOLD = 20
# ------------------------------------------------------------------
# Convention

abstract type Convention end

# -----------------------------------------------------------------
# nonmissing

if VERSION < v"1.3"
    # see also discourse.julialang.org/t/get-non-missing-type-in-the-case-of-parametric-type/29109
    """
        nonmissingtype(TT)

    Return the type `T` if `TT = Union{Missing,T}` for some `T` and return `TT`
    otherwise.
    """
    function nonmissingtype(::Type{T}) where T
        return T isa Union ? ifelse(T.a == Missing, T.b, T.a) : T
    end
end
nonmissing = nonmissingtype

# -----------------------------------------------------------------
# Constructor for table scientific type

"""
Table(...)

Constructor for the `Table` scientific type with:

```
Table(S1, S2, ..., Sn) <: Table
```

where  `S1, ..., Sn` are the scientific type of the table's columns which
are expected to be represented by abstract vectors.
"""
Table(Ts::Type...) = Table{<:Union{(Arr{<:T,1} for T in Ts)...}}

# -----------------------------------------------------------------
# scitype

include("scitype.jl")

end # module
