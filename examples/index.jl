# # Introduction

# ElTopo.jl is a interface to a C++ library [eltopo](https://github.com/tysonbrochu/eltopo). ElTopo the C++ library is a package for tracking dynamic surfaces represented as triangle meshes in 3D. It robustly handles topology changes such as merging and pinching off, while adaptively maintaining a tangle-free, high-quality triangulation. Suitable to simulate time dependant boundary problems, such as droplet behaviour uppon external field, interface dynamics of liquids in a container, etc.

# Currently, the wrapper works only on Linux (Help wanted! See [ElTopoBuilder](https://github.com/akels/ElTopoBuilder) and [Travis](https://travis-ci.org/akels/ElTopo.jl/jobs/574602453 ) ) and does not expose internal triangular mesh data structure methods. Nevertheless, it provides the mesh stabilization method with expossed parameters to control it. And together with `SurfaceTopology.jl` should be useful for soft surface dynamics calculations. 

# ##  The API

# The wrapper focuses on the high-level functionality provided in [ElTopo](https://github.com/tysonbrochu/eltopo). There are three important functions in it `SurfTrack::improve_mesh`, `SurfTrack::topology_changes` and `SurfTrack::integrate`. The first two methods are combined under the name `stabilize` whereas the latter one, which modifies tangential velocities to avoid vertex collisions, is not wrapped [^1]. 

# ```@autodocs
# Modules = [ElTopo]
# ```

# Let's first load ElTopo library and load the triangulation to stabilize. In this case, a sphere made out of two subdivisions of an icosahedron. 

using ElTopo
include("sphere.jl")
msh = unitsphere(2)

# Berore executing stabilization method we need to initialize parameters. See docstrings for fields and also [article](http://www.cs.ubc.ca/labs/imager/tr/2009/eltopo/sisc2009.pdf).

scale = 0.2
par = SurfTrack(
    min_edge_length = 0.7*scale,
    max_edge_length = 1.5*scale,
    max_volume_change = 0.1*scale^3,
    merge_proximity_epsilon = 0.5*scale,
)

# Then putting parameters and mesh in we can execute stabilization:

newmsh = stabilize(msh,par)

# [^1]: I had issues with using Cxx to represent `SurfTrack` instance in julia. Thus the best I was able to do was to use a single `icxx` block in julia function to do all the stuff. In spite of that, I think that covers most of the use cases.  
