var documenterSearchIndex = {"docs":
[{"location":"enright/#","page":"Enright test","title":"Enright test","text":"EditURL = \"https://github.com/akels/ElTopo.jl/blob/master/examples/enright.jl\"","category":"page"},{"location":"enright/#Enright-test-1","page":"Enright test","title":"Enright test","text":"","category":"section"},{"location":"enright/#","page":"Enright test","title":"Enright test","text":"To see the algorithm in action we may look how a triangulated sphere behaves under periodic incompressable shear flow defined in velocity method:","category":"page"},{"location":"enright/#","page":"Enright test","title":"Enright test","text":"function velocity(t,pos)\n    x,y,z = pos\n\n    x = x*0.15 + 0.35\n    y = y*0.15 + 0.35\n    z = z*0.15 + 0.35\n\n    u = 2*sin(pi*x)^2 * sin(2*pi*y) * sin(2*pi*z) * sin(2/3*pi*t)\n    v = - sin(2*pi*x) * sin(pi*y)^2 * sin(2*pi*z) * sin(2/3*pi*t)\n    w = - sin(2*pi*x) * sin(2*pi*y) * sin(pi*z)^2 * sin(2/3*pi*t)\n\n    [u,v,w] /0.3 #/0.15\nend","category":"page"},{"location":"enright/#","page":"Enright test","title":"Enright test","text":"As previosly, let's load the a sphere mesh with two subdivisions from icosahedron:","category":"page"},{"location":"enright/#","page":"Enright test","title":"Enright test","text":"using ElTopo\ninclude(\"sphere.jl\")\nmsh = unitsphere(2)","category":"page"},{"location":"enright/#","page":"Enright test","title":"Enright test","text":"Knowing the mesh, which corresponds to initial conditions, we can use RK2 method to integrate the velocity field. While at every time step we can stabilize the triangulation and visualize that with the fantastic Makie package:","category":"page"},{"location":"enright/#","page":"Enright test","title":"Enright test","text":"using GeometryTypes\nusing AbstractPlotting, GLMakie\n\nx = Node(msh)\ny = lift(x->x,x)\n\nscene = Scene(show_axis=false)\n\nwireframe!(scene,y,linewidth = 3f0)\nmesh!(scene,y, color = :white, shading = false)\n\ndisplay(scene)\n\nt = 0\nΔt = 0.01\nN = convert(Int,floor(pi/ Δt))\n\npar = SurfTrack(allow_vertex_movement=true)\n\nrecord(scene, \"enright.gif\", 1:N) do i # for i in 1:N\n    update_cam!(scene,Vec3f0(4,4,4), Vec3f0(2, 0, 0))\n\n    global v = msh.vertices\n    global f = msh.faces\n\n    k1 = [velocity(t,pos) for pos in v]\n    v1 = v .+ k1 .* Δt\n    k2 = [velocity(t+Δt/2,pos) for pos in v1]\n\n    v2 = v .+ k2 .* Δt\n\n    mshn = HomogenousMesh(v2,f)\n    global msh = stabilize(mshn,par)\n\n    push!(x,msh)\n\n    AbstractPlotting.force_update!()\n\n    global t+=Δt\nend","category":"page"},{"location":"enright/#","page":"Enright test","title":"Enright test","text":"(Image: )","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"EditURL = \"https://github.com/akels/ElTopo.jl/blob/master/examples/index.jl\"","category":"page"},{"location":"#Introduction-1","page":"Introduction","title":"Introduction","text":"","category":"section"},{"location":"#","page":"Introduction","title":"Introduction","text":"ElTopo.jl is a interface to a C++ library eltopo. ElTopo the C++ library is a package for tracking dynamic surfaces represented as triangle meshes in 3D. It robustly handles topology changes such as merging and pinching off, while adaptively maintaining a tangle-free, high-quality triangulation. Suitable to simulate time dependant boundary problems, such as droplet behaviour uppon external field, interface dynamics of liquids in a container, etc.","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"Currently, the wrapper works only on Linux (Help wanted! See ElTopoBuilder and Travis ) and does not expose internal triangular mesh data structure methods. Nevertheless, it provides the mesh stabilization method with expossed parameters to control it. And together with SurfaceTopology.jl should be useful for soft surface dynamics calculations.","category":"page"},{"location":"#The-API-1","page":"Introduction","title":"The API","text":"","category":"section"},{"location":"#","page":"Introduction","title":"Introduction","text":"The wrapper focuses on the high-level functionality provided in ElTopo. There are three important functions in it SurfTrack::improve_mesh, SurfTrack::topology_changes and SurfTrack::integrate. The first two methods are combined under the name stabilize whereas the latter one, which modifies tangential velocities to avoid vertex collisions, is not wrapped [1].","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"Modules = [ElTopo]","category":"page"},{"location":"#ElTopo.SurfTrack","page":"Introduction","title":"ElTopo.SurfTrack","text":"SurfTrack([...])\n\nConstructs a SurfTrack instance which holds parameters for ElTopo surface tracker stabilization. \n\n\n\n\n\n","category":"type"},{"location":"#ElTopo.stabilize-Tuple{GeometryTypes.HomogenousMesh,SurfTrack}","page":"Introduction","title":"ElTopo.stabilize","text":"stabilize(msh::HomogenousMesh,p::SurfTrack)\n\nComputes stabilized mesh for a given initial triangulation msh with stabilization parameters p.\n\n\n\n\n\n","category":"method"},{"location":"#","page":"Introduction","title":"Introduction","text":"Let's first load ElTopo library and load the triangulation to stabilize. In this case, a sphere made out of two subdivisions of an icosahedron.","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"using ElTopo\ninclude(\"sphere.jl\")\nmsh = unitsphere(2)","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"Berore executing stabilization method we need to initialize parameters. See docstrings for fields and also article.","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"scale = 0.2\npar = SurfTrack(\n    min_edge_length = 0.7*scale,\n    max_edge_length = 1.5*scale,\n    max_volume_change = 0.1*scale^3,\n    merge_proximity_epsilon = 0.5*scale,\n)","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"Then putting parameters and mesh in we can execute stabilization:","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"newmsh = stabilize(msh,par)","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"[1]: I had issues with using Cxx to represent SurfTrack instance in julia. Thus the best I was able to do was to use a single icxx block in julia function to do all the stuff. In spite of that, I think that covers most of the use cases.","category":"page"}]
}
