using ElTopo
using JLD

#const sphere = "$(dirname(@__FILE__))/sphere.jld"
#@load $sphere

data = load("$(dirname(@__FILE__))/sphere.jld")
points,faces = data["points"], data["faces"]


@info "Testing improvemesh"

p = Elparameters()
improvemesh(points,faces,p)

@info "Testing improvemeshcol"

function velocity(t,pos)
    x,y,z = pos
    
    x = x*0.15 + 0.35
    y = y*0.15 + 0.35
    z = z*0.15 + 0.35

    u = 2*sin(pi*x)^2 * sin(2*pi*y) * sin(2*pi*z) * sin(2/3*pi*t)
    v = - sin(2*pi*x) * sin(pi*y)^2 * sin(2*pi*z) * sin(2/3*pi*t)
    w = - sin(2*pi*x) * sin(2*pi*y) * sin(pi*z)^2 * sin(2/3*pi*t)

    [u,v,w] /0.15
end

v = zero(points)
t = 1
for i in 1:size(points,2)
    v[:,i] = velocity(t,points[:,i])
end

par = Elparameters(m_dt=1.0)
improvemeshcol(points,faces,points + 0.01*v,par)
