# # Introduction

# ElTopo.jl is a library which allows to restructure and refine triangular mesh as it evolves. Suitable to simulate time dependant boundary problems, such as droplet behaviour uppon external fields, gradients, and it's changing surface tension. Or interfaces of homogenous liquids in a container. Full range of possibilities can be explored in the original C++ library ElTopo, which is interfaces here with Cxx.jl. 

# ## The Enright test

# To see the algorithm in action we may look how a triangulated sphere behaves under periodic incompressable shear flow.

# First, let's define a Enright velocity field:
using GeometryTypes
using Makie
using ElTopo

function velocity(t,pos)
    x,y,z = pos
    
    x = x*0.15 + 0.35
    y = y*0.15 + 0.35
    z = z*0.15 + 0.35

    u = 2*sin(pi*x)^2 * sin(2*pi*y) * sin(2*pi*z) * sin(2/3*pi*t)
    v = - sin(2*pi*x) * sin(pi*y)^2 * sin(2*pi*z) * sin(2/3*pi*t)
    w = - sin(2*pi*x) * sin(2*pi*y) * sin(pi*z)^2 * sin(2/3*pi*t)

    [u,v,w] /0.3 #/0.15
end

# First let's create a sphere mesh.
include("sphere.jl")
msh = unitsphere(2)


# Now let's do something fun. 
x = Node(msh)
y = lift(x->x,x)

scene = Scene(show_axis=false)

wireframe!(scene,y,linewidth = 3f0)
mesh!(scene,y, color = :white, shading = false)

display(scene)

t = 0
Δt = 0.01
N = convert(Int,floor(pi/ Δt))

## msh = HomogenousMesh(v0,f0)
par = SurfTrack(allow_vertex_movement=true)

record(scene, "enright.gif", 1:N) do i # for i in 1:N
    update_cam!(scene,Vec3f0(4,4,4), Vec3f0(2, 0, 0))  

    ### Second order RK2
    global v = msh.vertices
    global f = msh.faces
    
    k1 = [velocity(t,pos) for pos in v]
    v1 = v .+ k1 .* Δt
    k2 = [velocity(t+Δt/2,pos) for pos in v1]

    v2 = v .+ k2 .* Δt

    mshn = HomogenousMesh(v2,f)
    global msh = stabilize(mshn,par)

    push!(x,msh)
    
    AbstractPlotting.force_update!()
    sleep(Δt)

    global t+=Δt
end

# ![](enright.gif)
