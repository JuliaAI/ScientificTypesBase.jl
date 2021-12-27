# ScientificTypesBase.jl

| [Linux] | Coverage |
| :-----------: | :------: |
| [![Build status](https://github.com/JuliaAI/ScientificTypesBase.jl/workflows/CI/badge.svg)](https://github.com/JuliaAI/ScientificTypesBase.jl/actions)| [![codecov.io](http://codecov.io/github/JuliaAI/ScientificTypesBase.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaAI/ScientificTypesBase.jl?branch=master) |

A light-weight, dependency-free, Julia interface defining a collection
of types (without instances) for implementing conventions about the
scientific interpretation of data.

This package makes a distinction between the **machine type** and
**scientific type** of a Julia object:

* The _machine type_ refers to the Julia type being used to represent
  the object (for instance, `Float64`).

* The _scientific type_ is one of the types defined in this package
  reflecting how the object should be _interpreted_ (for instance,
  `Continuous` or `Multiclass{3}`).

The distinction is useful because the same machine type is often used
to represent data with *differing* scientific interpretations - `Int`
is used for product numbers (a factor) but also for a person's weight
(a continuous variable) - while the same scientific type is frequently
represented by *different* machine types - both `Int` and `Float64`
are used to represent weights, for example.

For implementation of a concrete convention assigning specific
scientific types (interpretations) to julia objects, see instead the
[ScientificTypes.jl](https://github.com/JuliaAI/ScientificTypes.jl)
package.

Formerly "ScientificTypesBase.jl" code lived at "ScientificTypes.jl".
Since version 2.0 the code at "ScientificTypes.jl" is code that
formerly resided at "MLJScientificTypes.jl" (now deprecated).

```
Finite{N}
├─ Multiclass{N}
└─ OrderedFactor{N}

Infinite
├─ Continuous
└─ Count

Image{W,H}
├─ ColorImage{W,H}
└─ GrayImage{W,H}

ScientificTimeType
├─ ScientificDate
├─ ScientificTime
└─ ScientificDateTime

Sampleable{Ω}
└─ Density{Ω}

Annotated{S}

AnnotationFor{S}

Multiset{S}

Table{K}

Textual

ManifoldPoint{MT}

Compositional{D}

Unknown
```

> Figure 1. The type hierarchy defined in ScientificTypesBase.jl (The Julia native `Missing` and `Nothing` type are also regarded as a scientific types).

#### Contents

 - [Who is this repository for?](#who-is-this-repository-for)
 - [What's provided here?](#what-is-provided-here)
 - [Defining a new convention](#defining-a-new-convention)


## Who is this repository for?

This package should only be used by developers who intend to define
their own scientific type convention.  The
[ScientificTypes.jl](https://github.com/JuliaAI/ScientificTypes.jl)
package (versions 2.0 and higher) implements such a convention, first
adopted in the [MLJ](https://github.com/JuliaAI/MLJ.jl) universe, but
which can be adopted by other statistical and scientific software.

The purpose of this package is to provide a mechanism for articulating
conventions around the scientific interpretation of data. With such a
convention in place, a numerical algorithm declares its data
requirements in terms of scientific types, the user has a convenient
way to check compliance of his data with that requirement, and the
developer understands precisely the constraints his data specification
places on the actual machine type of the data supplied.

## What is provided here?

#### 1. Scientific types

ScientificTypesBase provides the new julia types appearing in Figure 1
above, signifying "scientific type" for use in method dispatch (e.g.,
for trait values). Instances of the types play no role.

The types `Finite{N}`, `Multiclass{N}` and `OrderedFactor{N}` are all
parametrised by the number of levels `N`, while `Image{W,H}`,
`GrayImage{W,H}` and `ColorImage{W,H}` are all parametrised by the
image width and height dimensions, `(W, H)`. The parameter `Ω` in
`Sampleable{Ω}` and `Density{Ω}` is the scientific type of the sample
space. The type `ManifoldPoint{MT}`, intended for points lying on a
manifold, is parameterized by the type `MT` of the manifold to which
the points belong.

The scientific type `ScientificDate` is for representing dates (for
example, the 23rd of April, 2029), `ScientificTime` represents time
within a 24-hour day, while `ScientificDateTime` represents both a
time of day and date. These types mirror the types `Date`, `Time` and
`DateTime` from the Julia standard library Dates (and indeed, in the
convention defined in ScientificTypes.jl](https://github.com/JuliaAI/ScientificTypes.jl)
the difference is only a formal one).

The type parameter `K` in `Table{K}` is for conveying the scientific
type(s) of a table's columns. See [More on the `Table`
type](#more-on-the-table-type).

The julia native types `Missing` and `Nothing` are also regarded as scientific
types. 

#### 2. The `scitype` and `Scitype` methods

ScientificTypesBase provides a method `scitype` for articulating a
particular convention: `scitype(X, C())` is the scientific type of object
`X` under convention `C`. For example, in the `DefaultConvention` convention, implemented 
by [ScientificTypes](https://github.com/JuliaAI/ScientificTypes.jl),
one has `scitype(3.14, Defaultconvention()) = Continuous` and 
`scitype(42, Defaultconvention()) = Count`.

> *Aside.* `scitype` is *not* a mapping of types to types but from
> *instances* to types. This is because one may want to distinguish
> the scientific type of objects having the same machine type. For
> example, in the `DefaultConvention` implemented in ScientificTypes.jl, some
> `CategoricalArrays.CategoricalValue` objects have the scitype
> `OrderedFactor` but others are `Multiclass`. In CategoricalArrays.jl
> the `ordered` attribute is not a type parameter and so it can only
> be extracted from instances. 

The developer implementing a particular scientific type convention
[overloads](#defining-a-new-convention) the `scitype` method
appropriately. However, this package provides certain rudimentary
fallback behaviour:

**Property 0.** For any convention `C`, `scitype(missing, C()) == Missing` 
and `scitype(nothing, C()) == Nothing` (regarding `Missing` and `Nothing` 
as native scientific types).

**Property 1.** For any convention `C` `scitype(X, C()) == Unknown`, unless 
`X` is a tuple, an abstract array, `nothing`, or `missing`.

**Property 2.** For any convention `C`, The scitype of a `k`-tuple is 
`Tuple{S1, S2, ..., Sk}` where `Sj` is the scitype of the `j`th element under 
convention `C`.

For example, in the `Defaultconvention` convention implemented 
by [ScientificTypes](https://github.com/JuliaAI/ScientificTypes.jl):

```julia
julia> scitype((1, 4.5), Defaultconvention())
Tuple{Count, Continuous}
```

**Property 3.** For any given convention `C`, the scitype of an 
`AbstractArray`, `A`, is always`AbstractArray{U}` where `U` is the union 
of the scitypes of the elements of `A` under convention `C`, with one 
exception: If `typeof(A) <:AbstractArray{Union{Missing,T}}` for some `T` 
different from `Any`, then the scitype of `A` is `AbstractArray{Union{Missing, U}}`, 
where `U` is the union over all non-missing elements under convention `C`, **even 
if `A` has no missing elements.**

This exception is made for performance reasons. In `DefaultConvention` implemented 
by [ScientificTypes](https://github.com/JuliaAI/ScientificTypes.jl):

```julia
julia> v = [1.3, 4.5, missing]
julia> scitype(v, DefaultConvention())
AbstractArray{Union{Missing, Continuous}, 1}
```

```julia
julia> scitype(v[1:2], DefaultConvention())
AbstractArray{Union{Missing, Continuous},1}
```

> *Performance note.* Computing type unions over large arrays is
> expensive and, depending on the convention's implementation and the
> array eltype, computing the scitype can be slow. In the common case
> that the scitype of an array can be determined from the machine type
> of the object alone, the implementer of a new connvention can speed
> up compututations by implementing a `Scitype` method.  Do
> `?ScientificTypesBase.Scitype` for details.


#### More on the `Table` type

An object of scitype `Table{K}` is expected to have a notion of
"columns", which are `AbstractVector`s, and the intention of the type
parameter `K` is to encode the scientific type(s) of its
columns. Specifically, developers are requested to adhere to the
following:

**Tabular data convention.** If `scitype(X, C()) <: Table`, for a given 
convention `C` then in fact

```julia
scitype(X, C()) == Table{Union{scitype(c1, C), ..., scitype(cn, C)}}
```

where `c1`, `c2`, ..., `cn` are the columns of `X`. With this
definition, common type checks can be performed with tables.  For
instance, you could check that each column of `X` has an element
scitype that is either `Continuous` or `Finite`:

```@example 5
scitype(X, C()) <: Table{<:Union{AbstractVector{<:Continuous}, AbstractVector{<:Finite}}}
```

A built-in `Table` constructor provides a shorthand for the right-hand side:

```@example 5
scitype(X, C()) <: Table(Continuous, Finite)
```

Note that `Table(Continuous, Finite)` is a *type* union and not a `Table` *instance*.


## Defining a new convention

If you want to implement your own convention, you can consider the
[ScientificTypes.jl](https://github.com/JuliaAI/ScientificTypes.jl)
as a blueprint.

The steps below summarise the possible steps in defining such a convention:

* declare a new convention,
* add explicit `scitype` (and `Scitype`) definitions,
* optionally define `coerce` methods for your convention

Each step is explained below, taking `DefaultConvenion` as an example.

### Naming the convention

In the module, define a singleton as thus

```julia
struct MyConvention <: ScientificTypesBase.Convention end
```

### Adding explicit `scitype` declarations.

When overloading `scitype` one needs to dipatch over the convention,
as in this example:

```julia
ScientificTypesBase.scitype(::Integer, ::MyConvention) = Count
```
To avoid method ambiguities, avoid dispatching only on the first argument.
For example, defining
```julia
ScientificTypesBase.scitype(::AbstractFloat, C) = Continous
```
would lead to ambiguities in another package defining 
```julia
ScientificTypesBase.scitype(a, ::MyConvention) = Count
```

Since `ScientificTypesBase.jl` does not define a single-argument `scitype(X)` method, an implementation of a new scientific convention will typically want to explicitly implement the single argument method in their package, to save users from needing to explicitly specify a convention. That is, so the user can call `scitype(2.3)` instead of `scitype(2.3, MyConvention())`.

For example, one declares:
```julia
scitype(X) = scitype(X, MyConvention())
```

### Defining a `coerce` function

It may be very useful to define a function to coerce machine types so
as to correct an unintended scientific interpretation, according to a
given convention.  In the `DefaultConvention` convention, this is implemented by
defining `coerce` methods (no stub provided by `ScientificTypesBase`)

For instance consider the simplified:

```julia
function coerce(y::AbstractArray{T}, T2::Type{<:Union{Missing, Continuous}}
                ) where T <: Union{Missing, Real}
    return float(y)
end
```

Under this definition, `coerce([1, 2, 4], Continuous)` is mapped to
`[1.0, 2.0, 4.0]`, which has scitype `AbstractVector{Continuous}`.

In the case of tabular data, one might additionally define `coerce`
methods to selectively coerce data in specified columns. See
[ScientificTypes](https://github.com/JuliaAI/ScientificTypes.jl)
for examples.
