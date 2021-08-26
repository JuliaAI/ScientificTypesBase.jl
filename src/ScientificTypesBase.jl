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
    ManifoldPoint
export scitype, scitype_union, elscitype, nonmissing, trait

# utils (should not be re-exported)
export TRAIT_FUNCTION_GIVEN_NAME, set_convention

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

abstract type           Infinite <: Known end
abstract type          Finite{N} <: Known end
abstract type         Image{W,H} <: Known end
abstract type ScientificTimeType <: Known end
abstract type            Textual <: Known end
abstract type           Table{K} <: Known end

abstract type Continuous <: Infinite end
abstract type  Count <: Infinite end

abstract type    Multiclass{N} <: Finite{N} end
abstract type OrderedFactor{N} <: Finite{N} end

abstract type ScientificDate <: ScientificTimeType end
abstract type ScientificTime <: ScientificTimeType end
abstract type ScientificDateTime <: ScientificTimeType end

abstract type  GrayImage{W,H} <: Image{W,H} end
abstract type ColorImage{W,H} <: Image{W,H} end

# when sampled, objects with these scitypes return objects of scitype Ω:
abstract type Sampleable{Ω} end
abstract type Density{Ω} <: Sampleable{Ω} end

abstract type ManifoldPoint{M} <: Known end

# aliases:
const Binary     = Finite{2}
const Scientific = Union{Missing,Found} # deprecated (no longer publicized)

# for internal use
const Arr = AbstractArray

# -------------------------------------------------------------------
# Convention

abstract type Convention end
struct NoConvention <: Convention end

const CONVENTION = Ref{Convention}(NoConvention())

"""
    set_convention(C)

Set the current convention to `C`.
"""
set_convention(C::Convention) = (CONVENTION[] = C; nothing)

"""
    convention()

Return the current convention.
"""
function convention()::Convention
    C = CONVENTION[]
    if C isa NoConvention
        @warn "No convention specified. Did you forget to use the " *
              "`set_convention` function?"
    end
    return C
end

# -------------------------------------------------------------------
# trait

const TRAIT_FUNCTION_GIVEN_NAME = Dict{Symbol,Function}()

"""
    trait(X)

Check `X` against traits specified in `TRAIT_FUNCTION_GIVEN_NAME` and
return a symbol corresponding to the first matching trait, or `:other`
if `X` didn't match any of the trait functions. If more than one trait
matches, throw an error.

"""
function trait(X)::Symbol
    ret = :other
    found = false
    for (name, f) in TRAIT_FUNCTION_GIVEN_NAME
        if f(X)
            found && error("Bad dictionary "*
                           "`ScientificTypesBase.TRAIT_FUNCTION_GIVEN_NAME`. ")
            ret = name
            found = true
        end
    end
    return ret
end

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
