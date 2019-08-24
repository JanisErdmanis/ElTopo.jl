__precompile__(false)
module ElTopo

using Cxx
using Parameters
using GeometryTypes

include("../deps/deps.jl")

"""
    SurfTrack([...])

Constructs a SurfTrack instance which holds parameters for ElTopo surface tracker stabilization. 
"""
@with_kw struct SurfTrack
    "Elements closer than this are considered \"near\" (or proximate)"
    proximity_epsilon::Float64 = 1e-4
    friction_coefficient::Float64 = 0.0
    min_triangle_area::Float64 = 1e-7

    " Collision epsilon to use during mesh improvment operations (i.e. if any mesh elements are closer than this, the operation is aborted). NOTE: This should be greater than collision_epsilon, to prevent improvement operations from moving elements into 
     a collision configuration."
    improve_collision_epsilon::Float64 = 2e-6
    
    "Whether to set the min and max edge lengths as fractions of the initial average edge length"
    use_fraction::Bool = false
    
    # If use_fraction is true, these are taken to be fractions of the average edge length of the new surface. If use_fraction is false, these are absolute.
    min_edge_length::Float64 = 0.05
    max_edge_length::Float64 = 0.2 
    max_volume_change::Float64 = 0.1
    
    "In-triangle minimum angle to enforce"
    min_triangle_angle::Float64 = 0
    "In-triangle maximum angle to enforce"
    max_triangle_angle::Float64 = 180   
    
    use_curvature_when_splitting::Bool = false
    use_curvature_when_collapsing::Bool = false
    
    "Clamp curvature scaling with minimum bound"
    min_curvature_multiplier::Float64 = 1
    "Clamp curvature scaling with maximum bound"
    max_curvature_multiplier::Float64 = 1
    
    allow_vertex_movement::Bool = false
    
    "Minimum edge length improvement in order to flip an edge"
    edge_flip_min_length_change::Float64 = 0.05
    
    "Elements within this distance will trigger a merge attempt"   
    merge_proximity_epsilon::Float64 = 1e-5
    
    "Whether to enforce collision-free surfaces (including during mesh maintenance operations)"
    collision_safety::Bool = true
    
    "Whether to allow changes in topology"
    allow_topology_changes::Bool = false
    
    "Wether to allow non-manifold (edges incident on more than two triangles)"
    allow_non_manifold::Bool = false
    
    "Whether to allow mesh improvement"
    perform_improvement::Bool = true
end


Libdl.dlopen(eltopo,Libdl.RTLD_GLOBAL)

addHeaderDir(dirname(@__FILE__)*"/../deps/usr/include/",kind=C_System)

cxxinclude("vector")
cxxinclude("subdivisionscheme.h")
cxxinclude("surftrack.h")


function stabilize(points,faces,p::SurfTrack)
    pointsout = Point{3,Float64}[]
    facesout = Face{3,UInt64}[]
    
    icxx"""
         std::vector<Vec3d> vs;
         std::vector<Vec3st> ts;
         std::vector<double> ms;

    $:(
    for i in 1:length(points)
        p1,p2,p3 = points[i]
        icxx"vs.push_back(Vec3d($p1,$p2,$p3));"
        icxx"ms.push_back(0.5);"
    end
    );

    $:(
    for i in 1:length(faces)
        v1,v2,v3 = faces[i] .- 1
        icxx"ts.push_back(Vec3st($v1,$v2,$v3));"
    end
    );

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

      SurfTrack surface_tracker(vs,ts,ms,parameters);

    surface_tracker.m_verbose = false;

    surface_tracker.improve_mesh();
    surface_tracker.topology_changes();
    surface_tracker.defrag_mesh();

    for ( int i = 0; i < surface_tracker.get_num_vertices(); ++i )
        $:(
           p1 = icxx"return surface_tracker.get_position(i)[0];";
           p2 = icxx"return surface_tracker.get_position(i)[1];";
           p3 = icxx"return surface_tracker.get_position(i)[2];";
           push!(pointsout,Point(p1,p2,p3));
        );

    for ( int i = 0; i < surface_tracker.m_mesh.num_triangles(); ++i )
        $:(
           v1 = icxx"return surface_tracker.m_mesh.get_triangle(i)[0];";
           v2 = icxx"return surface_tracker.m_mesh.get_triangle(i)[1];";
           v3 = icxx"return surface_tracker.m_mesh.get_triangle(i)[2];";
           push!(facesout,Face(v1+1,v2+1,v3+1));
        );
    """

    return pointsout,facesout
end


"""
    stabilize(msh::HomogenousMesh,p::SurfTrack)

Computes stabilized mesh for a given initial triangulation `msh` with stabilization parameters `p`.
"""
function stabilize(msh::HomogenousMesh,parameters::SurfTrack)
    newvertices, newfaces = stabilize(msh.vertices,msh.faces,parameters)
    return HomogenousMesh(newvertices,newfaces)
end

export stabilize, SurfTrack

end
