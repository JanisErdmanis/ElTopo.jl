// A real minimal example. Compile it with 
// g++ test3.c libeltopo_release.a -llapack -lblas -lstdc++ -lm -I../common -I../eltopo3d -o test 
//C hello world example

// To make a shared library I used
// g++ ../eltopo3d/libeltopo_release.a -o eltopo.so -fPIC -shared -llapack -lblas -lstdc++ -lm -I../common -I../eltopo3d 


// export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:`pwd`"
// g++ test4.c -o test -I./usr/include ./usr/lib/eltopo.so

//#define NSIZE 20000

//#include <stdio.h>
//#include <math.h>
#include <vector>
//#include <vec.h>
#include <surftrack.h>
#include <subdivisionscheme.h>

#include "mesh.c"

/* int printmesh(int ii, int Nverticies, int Ntriangles, double * verticies, int * triangles) { */

/*   char buf[256]; */
/*   snprintf(buf, sizeof buf, "%s%d%s", "output/", ii, ".obj"); */

/*   FILE *fp; */

/*   fp = fopen(buf, "w+"); */
/*   for (int i=0;i<Nverticies;i++){ */
/*     fprintf(fp,"v %f %f %f \n",verticies[3*i],verticies[3*i+1],verticies[3*i+2]); */
/*   } */

/*   for (int i=0;i<Ntriangles;i++) { */
/*     fprintf(fp,"f %d %d %d\n",triangles[3*i]+1,triangles[3*i+1]+1,triangles[3*i+2]+1); */
/*   } */

/*   fclose(fp); */
/* } */

/* struct SurfaceMesh */
/* { */
/*   double * verticies; */
/*   int Nverticies; */
/*   int * triangles; */
/*   int Ntriangles; */
/* }; */

/* void improvemesh(SurfaceMesh msh,SurfaceMesh * outmsh) */
/* { */
/*   std::vector<Vec3d> vs; */
/*   std::vector<double> masses; */

/*   for ( int i = 0; i < msh.Nverticies; ++i ) */
/*     { */
/*       vs.push_back( Vec3d( msh.verticies[3*i], msh.verticies[3*i + 1], msh.verticies[3*i + 2] ) ); */
/*       masses.push_back( 0.5 );       */
/*     } */

/*   std::vector<Vec3st> ts; */
/*   for ( int i = 0; i < msh.Ntriangles; ++i ) */
/*     { */
/*       ts.push_back( Vec3st( msh.triangles[3*i], msh.triangles[3*i + 1], msh.triangles[3*i + 2] ) ); */
/*     } */

/* } */

int main()
{
  /* printmesh(0,Nverticies,Ntriangles,verticies,triangles); */

  /* SurfaceMesh msh; */
  /* msh.verticies = verticies; */
  /* msh.Nverticies = Nverticies; */
  /* msh.triangles = triangles; */
  /* msh.Ntriangles = Ntriangles; */

  /* double verticiesout[NSIZE]; */
  /* int trianglesout[NSIZE]; */
  /* SurfaceMesh mshout; */
  /* mshout.verticies = verticiesout; */
  /* mshout.triangles = trianglesout; */

//  improvemesh(msh,&mshout);

  SurfTrackInitializationParameters parameters;

  parameters.m_proximity_epsilon = 1e-4;
  parameters.m_friction_coefficient = 0.0;
  parameters.m_min_triangle_area = 1e-7;
  parameters.m_improve_collision_epsilon = 2e-6;
  parameters.m_use_fraction = false;
  parameters.m_min_edge_length = 0.05;
  parameters.m_max_edge_length = 0.2;
  parameters.m_max_volume_change = 0.1;
  parameters.m_min_triangle_angle = 35;
  parameters.m_max_triangle_angle = 180;
  parameters.m_use_curvature_when_splitting = false;
  parameters.m_use_curvature_when_collapsing = false;
  parameters.m_min_curvature_multiplier = 1.0;
  parameters.m_max_curvature_multiplier = 1.0;
  parameters.m_allow_vertex_movement = false;
  parameters.m_edge_flip_min_length_change = 1e-8;
  parameters.m_merge_proximity_epsilon = 1e-5;
  parameters.m_collision_safety = true;
  parameters.m_allow_topology_changes = false;
  parameters.m_allow_non_manifold = false;
  parameters.m_perform_improvement = true;
  parameters.m_subdivision_scheme = new ButterflyScheme();


  // So copying is unavoidable for reasonable amount of work
  // However one could still pass a vector to the algorithm initialized in julia
  // And after the operation make the loop which would print the stuff out
  
  std::vector<Vec<3,double>> vs;
  std::vector<double> masses; // The first thing to try 
  std::vector<Vec<3,size_t>> ts;

  for ( int i = 0; i < Nverticies; ++i )
    {
      vs.push_back( Vec3d( verticies[3*i], verticies[3*i + 1], verticies[3*i + 2] ) );
      masses.push_back( 0.5 );
    }
  for ( int i = 0; i < Ntriangles; ++i )
    {
      ts.push_back( Vec3st( triangles[3*i], triangles[3*i + 1], triangles[3*i + 2] ) );
    }

//  printf("Hello world. Number of input triangles are %d \n",ts.size());
  // The actual thing I want to initialize
  // Perhaps there are other ways to initialize this crap
  SurfTrack surface_tracker( vs, ts, masses, parameters );
  surface_tracker.m_verbose = false;

  printf("Hello world. Number of input triangles are %d \n",surface_tracker.m_mesh.num_triangles());


  surface_tracker.improve_mesh();
  surface_tracker.topology_changes();
  surface_tracker.defrag_mesh();

 printf("Hello world. Number of output triangles are %d \n",surface_tracker.m_mesh.num_triangles());
 
  // I could check if vs ts had been updated by printing them out. If that would work
  // it would be promising to start a julia question on how to do taht with Cxx
  // In that way one could perhaps avoid making use of preallocations
  // Also it would be helpfull to avoid segfaults by allowing Cxx to catch them.
  
  // Creating usual array objects

  // int Nverticies_out = surface_tracker.get_num_vertices();
  //double verticies_out[Nverticies_out*3];

  /* for ( int i = 0; i < Nverticies_out; ++i ) */
  /*   { */
  /*     outmsh->verticies[3*i+0] = surface_tracker.get_position(i)[0]; */
  /*     outmsh->verticies[3*i+1] = surface_tracker.get_position(i)[1]; */
  /*     outmsh->verticies[3*i+2] = surface_tracker.get_position(i)[2]; */
  /*   } */

  /* int Ntriangles_out = surface_tracker.m_mesh.num_triangles(); */
  /* //  int triangles_out[Ntriangles_out*3]; */
  /* for ( int i = 0; i < Ntriangles_out; ++i ) */
  /*   { */
  /*     const Vec3st& curr_tri = surface_tracker.m_mesh.get_triangle(i);  */
  /*     outmsh->triangles[3*i + 0] = curr_tri[0]; */
  /*     outmsh->triangles[3*i + 1] = curr_tri[1]; */
  /*     outmsh->triangles[3*i + 2] = curr_tri[2]; */
  /*   } */

  /* printf("Nverticies=%d  Ntriangles=%d   volume=%f \n",Nverticies_out,Ntriangles_out,surface_tracker.get_volume()); */

  /* outmsh->Nverticies = Nverticies_out; */
  /* outmsh->Ntriangles = Ntriangles_out; */




  
  //printmesh(101,mshout.Nverticies,mshout.Ntriangles,mshout.verticies,mshout.triangles);

  /* printf("Hello world\n"); */
  return 0;
}
