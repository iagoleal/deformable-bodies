######################################################
# Example of model: falling cat as a deformable body #
######################################################
using DeformableBodies

# Initial values for the body
# CM fixed at origin
const r_0 = centralize(
    [ PointMass(3.,  [0.,   0.,   0.])   # centro do corpo
    , PointMass(2.,  [0.,  -1.,   0.])   # parte de trás
    , PointMass(1.,  [ .5, -1.,   1.])   # pata tras 1
    , PointMass(1.,  [-.5, -1.,   1.])   # pata tras 2
    , PointMass( .2, [0.,  -1.5, -0.5])  # cauda
    , PointMass(2.,  [0.,   1.,   0.])   # parte da frente
    , PointMass(1.,  [ .5,  1.,   1.])   # pata frente 1
    , PointMass(1.,  [-.5,  1.,   1.])   # pata frente 2
    , PointMass(1.3, [0.,   1.2, -0.2])  # cabeça
    ])

# Define vector of trajectories
bodies = Array{Function, 1}()
# Cat's center does not move
push!(bodies, t -> r_0[1])

# Other parts move according to given rule
const tmax = 10.0
const tmax_r1 = tmax/20.0
const θmax = -π/6.0
const freq = 2*π/(tmax - tmax_r1)
for i in 2:9
    if i in (2,3,4,5)
        e_1 = [1.,0.,0.]
        ax  = rotate(r_0[2].pos - r_0[1].pos, axis=e_1, angle=θmax)
    elseif i in (6,7,8,9)
        e_1 = -[1.,0.,0.]
        ax  = -rotate(r_0[6].pos - r_0[1].pos, axis=e_1, angle=θmax)
    end
    ri(t) = let j = i
        if t < tmax_r1
            rotate(r_0[j], axis=e_1, angle=t*θmax/tmax_r1)
        elseif tmax_r1 < t < tmax
            rx = rotate(r_0[j], axis=e_1, angle=θmax)
            rotate(rx, axis=ax, angle=freq*(t-tmax_r1))
        else
            rx = rotate(r_0[j], axis=e_1, angle=θmax)
            rotate(rx, axis=ax, angle=freq*(tmax-tmax_r1))
        end
    end
    push!(bodies, ri)
end

model = Model( bodies
             , 0.
             , 10.
             , one(Quaternion)
             , zeros(3)
             )

rotbodies, L = solve(model)

println("Now test the difference between the variables `bodies` and `rotbodies`!")