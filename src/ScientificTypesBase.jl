module ScientificTypesBase

using InteractiveUtils # needed for displaying the type hierarchy with `scitype()`

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

"""
    Infinite{N}

Scientific type for scalar data with an intrinsic order, but of unbounded nature, either
discrete or continuous.

Subtypes: [`Continuous`](@ref), [`Count`](@ref)

See also `scitype`.

"""
abstract type Infinite <: Known end
"""
    Finite{N}

Scientific type for scalar, categorical data taking on one of `N` possible discrete values,
which may or may not have a natural ordering.

Subtypes: [`Multiclass{N}`](@ref), [`OrderedFactor{N}`](@ref)

Aliases: `Binary==Finite{2}`. Binary data can be unordered (`Multiclass{2}`) or ordered
(`OrderedFactor{2}`).

See also `scitype`.

"""
abstract type Finite{N} <: Known end
"""
    Image{W,H}

Scientific type for image data, where `W` is the width and `H` the height.

Subtypes: [`GrayImage{W,H}`](@ref), [`ColorImage{W,H}`](@ref)

See also `scitype`.

"""
abstract type Image{W,H} <: Known end
abstract type ScientificTimeType <: Known end
"""
    Textual

Scientific type for text data playing some linguistic role, for example in sentiment
analysis. This is to be contrasted with text used simply to label classes of a categorical
variable; see instead [`Finite`](@ref).

Examples: survey questions with discursive answers, text to be translated into a new
language, vocabularies, email messages.

See also `scitype`.

"""
abstract type Textual <: Known end
"""
    Table{K}

Scientific type for tabular data. Here `K` will be a union of the scitypes of the columns
(not the union of the *element* scitype of the columns).

See also `scitype`.

"""
abstract type Table{K} <: Known end
"""
    Continuous

Scientific type for continuous scalar data.

Examples: height, age, blood-pressure, weight, temperature.

Supertype: [`Infinite`](@ref)

See also `scitype`.

"""
abstract type Continuous <: Infinite end
"""
    Count

Scientific type for discrete, ordered data, of unbounded nature.

Examples: number of phone calls per hour, number of building occupants, number of
earthquakes per year over 6 on the Richter scale, number of unsaturated carbon-carbon
bonds in a molecule.

Supertype: [`Infinite`](@ref)

See also `scitype`.

"""
abstract type Count <: Infinite end
"""
    Multiclass{N}

Scientific type for scalar, categorical data with `N` possible values but no natural
ordering for those classes (nominal data).

Examples: gender, team member, model number, product color, ethnicity, zipcode

Supertype: [`Finite{N}`](@ref)

See also `scitype`.

"""
abstract type Multiclass{N} <: Finite{N} end
"""
    OrderedFactor{N}

Scientific type for scalar, categorical data with `N` possible values with a natural
ordering (ordinal data).

Includes the binary data scientific type `OrderedFactor{2}`, applying whenever it is
natural to assign a "positive" class, for example, by a standard convention (e.g, "is
toxic", "is an anomaly", "has the disease"). The "positive" class is the maximal class
under the ordering. The distinction is important to disambiguate statistical metrics such
as "number of true positives", "recall", etc.

Examples: letter grade in an exam, education level, number of stars in a review,
safe/toxic, inlier/outlier, rejected/accepted.

Supertype: [`Finite{N}`](@ref)

See also `scitype`.

"""
abstract type OrderedFactor{N} <: Finite{N} end

abstract type ScientificDate <: ScientificTimeType end
abstract type ScientificTime <: ScientificTimeType end
abstract type ScientificDateTime <: ScientificTimeType end
"""
    GrayImage{W,H}

Scientific type for a grey-scale image, where `W` is the width and `H` the height.

Supertype: [`Image{W,H}`](@ref)

See also `scitype`.

"""
abstract type GrayImage{W,H} <: Image{W,H} end
"""
    ColorImage{W,H}

Scientific type for a color image, where `W` is the width and `H` the height.

Supertype: [`Image{W,H}`](@ref)

See also `scitype`.

"""
abstract type ColorImage{W,H} <: Image{W,H} end
"""
    Sampleable{Ω}

Scientific type for an object, such a probability distribution, that can be sampled. Each
individual sample `x` will satisfy `scitype(x) isa Ω`.

Subtype: [`Density{Ω}`](@ref)

See also `scitype`.

"""
abstract type Sampleable{Ω} end
"""
    Density{Ω}

Scientific type for an object representing a probability density function or probability
mass function, and more generally, for any probability measure that is absolutely
continuous with respect to some standard measure on the sample space. Elements `x` of the
sample space will satisfy `scitype(x) isa Ω`. Objects of this type can, at least in
principle, be sampled.

Supertype: [`Sampleable{Ω}`](@ref)

See also `scitype`.

"""
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

const nonmissing = nonmissingtype

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
