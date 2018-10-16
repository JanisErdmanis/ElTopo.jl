WORKSPACE = dirname(@__FILE__)

@info "Obtaining sources"

mkpath("$WORKSPACE/srcdir")
cd("$WORKSPACE/srcdir")

try 
    run(`git clone https://github.com/tysonbrochu/eltopo.git`)
catch
    @info "Perhaps source already exists. Continuing..."
end

run(`wget https://raw.githubusercontent.com/akels/ElTopoBuilder/master/src/eltopoc.cpp`)

@info "Configuring"

cp("$WORKSPACE/patches/Makefile.local_defs","$WORKSPACE/srcdir/eltopo/eltopo3d/Makefile.local_defs",force=true)

@info "Compiling"

cd("$WORKSPACE/srcdir/eltopo/eltopo3d")
run(`make depend`)
run(`make release`)

@info "Making shared objects"

cd(WORKSPACE)
mkpath("$WORKSPACE/usr/lib/")
mkpath("$WORKSPACE/usr/include/")

cd("$WORKSPACE/srcdir/eltopo/eltopo3d/obj/")
objects = filter(x->x!="depend",readdir())
run(`g++ $objects -o $WORKSPACE/usr/lib/eltopo.so -fPIC -shared -llapack -lblas -lstdc++ -lm`)

cd("$WORKSPACE")
run(`g++ srcdir/eltopoc.cpp -o usr/lib/eltopoc.so -fPIC -shared -I./srcdir/eltopo/common -I./srcdir/eltopo/eltopo3d $WORKSPACE/usr/lib/eltopo.so`)



