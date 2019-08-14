__precompile__(false)
module ElTopo

using Cxx
using Parameters
using GeometryTypes


### Should not be part of this code
import Base.convert

convert(::Type{Array{Point{3,Float64},1}},v::Array{Float64,2}) = [Point(v[1,i],v[2,i],v[3,i]) for i in 1:size(v,2)]

convert(::Type{Array{Face{3,Int64},1}},f::Array{Int64,2}) = [Face(f[1,i],f[2,i],f[3,i]) for i in 1:size(f,2)]


function convert(::Type{Array{Float64,2}},v::Array{Point{3,Float64},1})
    # Converting to array
    v_ = zeros(Float64,3,length(v))

    for i in 1:length(v)
        v_[1,i] = v[i][1]
        v_[2,i] = v[i][2]
        v_[3,i] = v[i][3]
    end

    return v_
end

function convert(::Type{Array{Int64,2}},f::Array{Face{3,Int64},1})
    # Converting to array
    f_ = zeros(Int64,3,length(f))

    for i in 1:length(f)
        f_[1,i] = f[i][1]
        f_[2,i] = f[i][2]
        f_[3,i] = f[i][3]
    end

    return f_
end
### 

include("../deps/depseltopo.jl")

@with_kw struct SurfTrack
    # Elements closer than this are considered "near" (or proximate)
    proximity_epsilon::Float64 = 1e-4
    friction_coefficient::Float64 = 0.0
    min_triangle_area::Float64 = 1e-7

    # Collision epsilon to use during mesh improvment operations (i.e. if any mesh elements are closer than this, the operation is 
    # aborted).  NOTE: This should be greater than collision_epsilon, to prevent improvement operations from moving elements into 
    # a collision configuration.
    improve_collision_epsilon::Float64 = 2e-6
    
    # Whether to set the min and max edge lengths as fractions of the initial average edge length
    use_fraction::Bool = false
    
    # If use_fraction is true, these are taken to be fractions of the average edge length of the new surface.
    # If use_fraction is false, these are absolute.
    min_edge_length::Float64 = 0.05
    max_edge_length::Float64 = 0.2 
    max_volume_change::Float64 = 0.1
    
    # In-triangle angles to enforce
    min_triangle_angle::Float64 = 0
    max_triangle_angle::Float64 = 180   
    
    use_curvature_when_splitting::Bool = false
    use_curvature_when_collapsing::Bool = false
    
    # Clamp curvature scaling to these values
    min_curvature_multiplier::Float64 = 1
    max_curvature_multiplier::Float64 = 1
    
    allow_vertex_movement::Bool = false
    
    # Minimum edge length improvement in order to flip an edge
    edge_flip_min_length_change::Float64 = 0.05
    
    # Elements within this distance will trigger a merge attempt   
    merge_proximity_epsilon::Float64 = 1e-5
    
    # Whether to enforce collision-free surfaces (including during mesh maintenance operations)
    collision_safety::Bool = true
    
    # Whether to allow changes in topology
    allow_topology_changes::Bool = false
    
    # Wether to allow non-manifold (edges incident on more than two triangles)
    allow_non_manifold::Bool = false
    
    # Whether to allow mesh improvement
    perform_improvement::Bool = true
end


Libdl.dlopen(eltopo,Libdl.RTLD_GLOBAL)
#addHeaderDir(pwd()*"/../deps/usr/include/",kind=C_System)

addHeaderDir(dirname(@__FILE__)*"/../deps/usr/include/",kind=C_System)
#addHeaderDir(pwd()*"/deps/usr/include/common",kind=C_System)

cxxinclude("vector")
cxxinclude("subdivisionscheme.h")
cxxinclude("surftrack.h")

############# C++ code ############

### Seems that moving Array to C++ and backwards is not so easally achievable due to 
### Its usage of stack allocated arrays for points. Something similar as StaicArrays.
### Therefore I need manually to manually upload vertices to the mesh for execution. 

### After that it is possible to
### icxx"$parameters.m_proximity_epsilon;"
function constructparameters(p::SurfTrack)
    icxx"""
      SurfTrackInitializationParameters parameters;
      parameters.m_proximity_epsilon = $(p.proximity_epsilon);
      parameters.m_friction_coefficient = $(p.friction_coefficient);
      parameters.m_min_triangle_area = $(p.min_triangle_area);
      parameters.m_improve_collision_epsilon = $(p.improve_collision_epsilon);
      parameters.m_use_fraction = $(p.use_fraction);
      parameters.m_min_edge_length = $(p.min_edge_length);
      parameters.m_max_edge_length = $(p.max_edge_length);
      parameters.m_max_volume_change = $(p.max_volume_change);
      parameters.m_min_triangle_angle = $(p.min_triangle_angle);
      parameters.m_max_triangle_angle = $(p.max_triangle_angle);
      parameters.m_use_curvature_when_splitting = $(p.use_curvature_when_splitting);
      parameters.m_use_curvature_when_collapsing = $(p.use_curvature_when_collapsing);
      parameters.m_min_curvature_multiplier = $(p.min_curvature_multiplier);
      parameters.m_max_curvature_multiplier = $(p.max_curvature_multiplier);
      parameters.m_allow_vertex_movement = $(p.allow_vertex_movement);
      parameters.m_edge_flip_min_length_change = $(p.edge_flip_min_length_change);
      parameters.m_merge_proximity_epsilon = $(p.merge_proximity_epsilon);
      parameters.m_collision_safety = $(p.collision_safety);
      parameters.m_allow_topology_changes = $(p.allow_topology_changes);
      parameters.m_allow_non_manifold = $(p.allow_non_manifold);
      parameters.m_perform_improvement = $(p.perform_improvement);
      parameters.m_subdivision_scheme = new ButterflyScheme();
      parameters; 
      """
end

### I could use GeometryTypes to make my life more seamless, even for plotting.
### 

function stabilize(points,faces,parameters::SurfTrack)
    
    ### Here one actually would do conversion of parameters
    p = constructparameters(parameters)
    faces = faces .- 1
    
    ### Creating C++ vector objects to construct C++ object
    vs = icxx"std::vector<Vec<3,double>> vs; vs;"
    ms = icxx"std::vector<double> masses; masses;"
    ts = icxx"std::vector<Vec<3,size_t>> ts; ts;"

    for i in 1:size(points,2)
        p1,p2,p3 = points[1,i], points[2,i], points[3,i]
        icxx"$vs.push_back(Vec3d($p1,$p2,$p3));"
        icxx"$ms.push_back(0.5);"
    end

    for i in 1:size(faces,2)
        v1,v2,v3 = faces[1,i], faces[2,i], faces[3,i]
        icxx"$ts.push_back(Vec3st($v1,$v2,$v3));"
    end
    
    ### Defining outputs
    vsout = icxx"std::vector<Vec<3,double>> vsout; vsout;"
    tsout = icxx"std::vector<Vec<3,size_t>> tsout; tsout;"

    ### Constructing surface tracker and creating outputs
    icxx"""
    SurfTrack surface_tracker($vs,$ts,$ms,$p);
    surface_tracker.m_verbose = false;

    surface_tracker.improve_mesh();
    surface_tracker.topology_changes();
    surface_tracker.defrag_mesh();

    for ( int i = 0; i < surface_tracker.get_num_vertices(); ++i ) 
            $vsout.push_back(surface_tracker.get_position(i));

    for ( int i = 0; i < surface_tracker.m_mesh.num_triangles(); ++i ) 
            $tsout.push_back(surface_tracker.m_mesh.get_triangle(i));

    """

    vsoutj = map(x->convert(Float64,icxx"$vsout[$(x[2])][$(x[1])];"),Iterators.product(0:2,0:(Int(icxx"$vsout.size();")-1)))
    tsoutj = map(x->Int(convert(UInt64,icxx"$tsout[$(x[2])][$(x[1])];")),Iterators.product(0:2,0:(Int(icxx"$tsout.size();")-1)))
    
    return vsoutj,tsoutj .+ 1
end

### This one needs to be a part of the algorithm
function stabilize(msh::HomogenousMesh,parameters::SurfTrack)
    vertices = convert(Array{Float64,2},msh.vertices)
    faces = convert(Array{Int64,2},msh.faces)

    nverticies, nfaces = stabilize(vertices,faces,parameters)

    nv = convert(Array{Point{3,Float64},1}, nverticies)
    nf = convert(Array{Face{3,Int64},1}, nfaces)

    return HomogenousMesh(nv,nf)
end
###

export stabilize, SurfTrack

end
