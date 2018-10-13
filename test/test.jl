include("../src/ElTopoCxx.jl")
using Main.ElTopo

using JLD
@load "sphere.jld"

p = SurfTrackInitializationParameters()
improve_mesh(points,faces,p)
