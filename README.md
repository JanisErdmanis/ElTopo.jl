[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://akels.github.io/ElTopo.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://akels.github.io/ElTopo.jl/dev)
[![Build Status](https://travis-ci.org/akels/LaplaceBIE.jl.svg?branch=master)](https://travis-ci.org/akels/ElTopo.jl)

# Introduction

ElTopo.jl is a interface to a C++ library eltopo. ElTopo the C++ library is a package for tracking dynamic surfaces represented as triangle meshes in 3D. It robustly handles topology changes such as merging and pinching off, while adaptively maintaining a tangle-free, high-quality triangulation. Suitable to simulate time dependant boundary problems, such as droplet behaviour uppon external field, interface dynamics of liquids in a container, etc.