# Introduction

ElTopo is a package which interfaces C++ library [eltopo](https://github.com/tysonbrochu/eltopo) and which is built with [ElTopoBuilder](https://github.com/akels/ElTopoBuilder). At the moment only Linux platform is supported, but since BinaryBuilder is being used, it should not take much effort for adding support for other platforms.

# The API

As explained in [the main repository](https://github.com/tysonbrochu/eltopo):

> El Topo is a free C++ package for tracking dynamic surfaces represented as triangle meshes in 3D. It robustly handles topology changes such as merging and pinching off, while adaptively maintaining a tangle-free, high-quality triangulation.

There are three important functions in the ElTopo library `SurfTrack::improve_mesh`, `SurfTrack::topology_changes` and `SurfTrack::integrate`. To avoid some unneeded data movement and initializations the first two are combined under the name `improvemesh` and all together under the name `improvemeshcol`. In a following way one defines the parameters which defines what mesh operations would be applied:
```
using ElTopo

scale = 0.2
par = Elparameters(
                   m_use_fraction = false,
                   m_min_edge_length = 0.7*scale,
                   m_max_edge_length = 1.5*scale,
                   m_max_volume_change = 0.1*scale^3,
                   m_min_curvature_multiplier = 1.0,
                   m_max_curvature_multiplier = 1.0,
                   m_merge_proximity_epsilon = 0.5*scale,
                   m_proximity_epsilon = 0.00001,
m_perform_improvement = true, 
m_collision_safety = false,
m_min_triangle_angle = 15,
m_max_triangle_angle = 120,
m_allow_vertex_movement = true,
m_use_curvature_when_collapsing = false,
m_use_curvature_when_splitting = false,
m_dt = h
)
```
Then one can use `p,f = improvemeshcol(p,f,par) ` or `actualdt,p,f = improvemeshcol(p,f,p + h*v2,par) ` to perform needed mesh improvement. 

# Showcase

To test the wrapper we integrated Enright velocity field which was was dicussed in [eltopo](https://github.com/tysonbrochu/eltopo) library's paper.



| ![](img/topologystab.svg) | ![](https://raw.githubusercontent.com/akels/ElTopo.jl/master/img/thinfeatures.svg)  |
|---|---|
| Evolution | Thin features are preserved |
