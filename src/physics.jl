using LinearAlgebra: I, cross, ×

# A PointMass is a mass at a given point on space (R^3).
"""
    PointMass(m, x)

Wrapper around a mass
and a position on ``R^3``.
"""
struct PointMass{T} <: Any where {T<:Real}
    mass::T
    pos::Vector{T}
    function PointMass{T}(m, x) where {T<:Real}
        m > 0 || error("Error: negative mass given.")
        length(x) == 3 || error("Error: PointMass must three dimensional.")
        return new(m, x)
    end
end

# Alternative constructors
PointMass(m::Real, x::Vector{<:Real}) = PointMass{typeof(promote(m,x[1])[1])}(m,x)

"""
    pos(p::PointMass)

Returns position of a [`PointMass`](@ref).
"""
@inline pos(p::PointMass) = p.pos

"""
    mass(p::PointMass)

Returns mass of a [`PointMass`](@ref).
"""
@inline mass(p::PointMass) = p.mass

# Velocity of a set of trajectories
velocity(xs, t; ε=1e-6) =
    map((a,b) -> (pos(a) - pos(b))/(2*ε), xs(t+ε), xs(t-ε))

"""
    center_of_mass(xs)

Gets a system of [`PointMass`](@ref)es and returns their
center of mass via
```math
cm(x) = \\frac{1}{\\sum m_i}\\sum m_i x_i.
```
"""
@inline center_of_mass(xs) =
    sum(mass.(xs) .* pos.(xs)) / sum(mass.(xs))

"""
    inertia_tensor(xs)

Gets a system of [`PointMass`](@ref)es and returns their
inertia tensor via
```math
I = \\sum m_i \\langle x_i, x_i \\rangle \\text{id} - x_i \\otimes x_i.
```
"""
@inline inertia_tensor(xs) =
    sum(mass(x) * (pos(x)'pos(x) * I - kron(pos(x)',pos(x))) for x in xs)

"""
    angular_momentum(xs, vs)

Receives a system of [`PointMass`](@ref)es and their velocities, and returns their
angular momentum vector via
```math
L = \\sum m_i x_i \times v_i.
```
"""
@inline angular_momentum(xs, vs) =
    sum(mass(x) * (cross(pos(x), v)) for (x,v) in zip(xs,vs))

"""
    centralize(xs)

Receives a system of [`PointMass`](@ref)es and returns
the same system translated such that their center of mass
is fixed on the origin.
"""
function centralize(xs)
    cm = center_of_mass(xs)
    return map(r -> PointMass(mass(r), pos(r) - cm), xs)
end

# Extend Quaternions.rotate to deal with point masses
using .Quaternions: rotate

@inline function Quaternions.rotate(x::PointMass; angle=0, axis=[0,0,0])
    return PointMass(mass(x), Quaternions.rotate(pos(x); angle=angle, axis=axis))
end
