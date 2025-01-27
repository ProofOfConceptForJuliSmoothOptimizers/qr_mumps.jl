# A [Julia](http://julialang.org) Interface to [qr_mumps](http://buttari.perso.enseeiht.fr/qr_mumps/)

| **Documentation** | **Linux/macOS/Windows/FreeBSD** | **Coverage** |
|:-----------------:|:-------------------------------:|:------------:|
| [![](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSmoothOptimizers.github.io/qr_mumps.jl/dev) | ![CI](https://github.com/JuliaSmoothOptimizers/qr_mumps.jl/workflows/CI/badge.svg?branch=master) [![Build Status](https://img.shields.io/cirrus/github/JuliaSmoothOptimizers/qr_mumps.jl?logo=Cirrus%20CI)](https://cirrus-ci.com/github/JuliaSmoothOptimizers/qr_mumps.jl) | [![codecov.io](https://codecov.io/github/JuliaSmoothOptimizers/qr_mumps.jl/coverage.svg?branch=master)](https://codecov.io/github/JuliaSmoothOptimizers/qr_mumps.jl?branch=master) |

## How to install

```julia
julia> ]
pkg> add https://github.com/JuliaSmoothOptimizers/qr_mumps.jl
pkg> test qr_mumps
```

## Content

[qr_mumps](http://buttari.perso.enseeiht.fr/qr_mumps/) is a software package for the solution of sparse, linear systems on multicore computers.
It implements a direct solution method based on the QR or Cholesky factorization of the input matrix. 
Therefore, it is suited to solving sparse least-squares problems, to computing the minimum-norm solution of sparse, underdetermined problems and to solving symmetric, positive-definite sparse linear systems.
It can obviously be used for solving square unsymmetric problems in which case the stability provided by the use of orthogonal transformations comes at the cost of a higher operation count with respect to solvers based on, e.g., the LU factorization such as [MUMPS](http://mumps.enseeiht.fr/).
qr_mumps supports real and complex, single or double precision arithmetic. 

## Custom Installation

**Note: qr_mumps is already precompiled with Yggdrasil for all platforms.**

To use your custom qr_mumps, set the environmental variables `JULIA_QR_MUMPS_LIBRARY_PATH`
to point the shared library.

**Very important note: you must set these environment variables before
calling `using qr_mumps` in every Julia session.**

For example:
```julia
ENV["JULIA_QR_MUMPS_LIBRARY_PATH"] = "/home/alexis/Applications/qr_mumps-3.0.1/build/lib"
using qr_mumps
```

Alternatively, you can set these permanently through your operating system.
