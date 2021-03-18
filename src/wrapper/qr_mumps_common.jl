mutable struct c_spmat{T}
  irn :: Ptr{Cint}
  jcn :: Ptr{Cint}
  val :: Ptr{T}
  m   :: Cint
  n   :: Cint
  nz  :: Cint
  sym :: Cint
  h   :: Ptr{Cvoid}

  function c_spmat{T}() where T
    spmat = new(C_NULL, C_NULL, C_NULL, 0, 0, 0, 0, C_NULL)
    return spmat
  end

  function c_spmat{T}(irn, jcn, val, m, n, nz, sym, h) where T
    spmat = new(irn, jcn, val, m, n, nz, sym, h)
    return spmat
  end
end

@doc raw"""
This data type is used to store a sparse matrix in the COO (or coordinate) format through the irn, jcn
and val fields containing the row indices, column indices and values, respectively and the m, n and nz
containing the number of rows, columns and nonzeros, respectively. qr mumps uses a Fortran-style
1-based numbering and thus all row indices are expected to be between 1 and m and all the column
indices between 1 and n. Duplicate entries are summed during the factorization, out-of-bound entries
are ignored. The sym field is used to specify if the matrix is symmetric (> 0) or unsymmetric (= 0).
"""
mutable struct qrm_spmat{T} <: AbstractSparseMatrix{T, Cint}
  irn :: Vector{Cint}
  jcn :: Vector{Cint}
  val :: Vector{T}
  m   :: Cint
  n   :: Cint
  nz  :: Cint
  sym :: Cint
  h   :: Ptr{Cvoid}

  function qrm_spmat{T}(h :: Ptr{Cvoid}) where T
    spmat = new(Cint[], Cint[], T[], 0, 0, 0, 0, h)
    finalizer(qrm_spmat_destroy!, spmat)
    return spmat
  end
end

function Base.cconvert(::Type{Ref{c_spmat{T}}}, spmat :: qrm_spmat{T}) where T
    return c_spmat{T}(pointer(spmat.irn), pointer(spmat.jcn), pointer(spmat.val), spmat.m, spmat.n, spmat.nz, spmat.sym, spmat.h)
end

function Base.unsafe_convert(::Type{Ref{c_spmat{T}}}, spmat::c_spmat{T}) where T
  R = Ref{c_spmat{T}}
  return Base.unsafe_convert(R, Base.cconvert(R, spmat))
end

Base.size(spmat :: qrm_spmat) = (spmat.m, spmat.n)
SparseArrays.nnz(spmat :: qrm_spmat) = spmat.nz

function Base.show(io :: IO, ::MIME"text/plain", spmat :: qrm_spmat)
  println(io, "Sparse matrix -- qrm_spmat of size ", size(spmat), " with ", nnz(spmat), " nonzeros.")
end

@doc raw"""
This type is used to set the parameters that control the behavior of a sparse factorization, to collect
information about its execution (number of flops, memory consumpnion etc) and store the result of 
the factorization, namely, the factors with all the symbolic information needed to use them in the
solve phase.
"""
mutable struct qrm_spfct{T} <: Factorization{T}
  m        :: Cint
  n        :: Cint
  nz       :: Cint
  sym      :: Cint
  cperm_in :: Ptr{Cint}
  icntl    :: NTuple{20, Cint}
  rcntl    :: NTuple{10, Cfloat}
  gstats   :: NTuple{10, Clonglong}
  h        :: Ptr{Cvoid}

  function qrm_spfct{T}() where T
    spfct = new(0, 0, 0, 0, C_NULL, ntuple(x -> Cint(0), 20), ntuple(x -> Cfloat(0), 10), ntuple(x -> Clonglong(0), 10), C_NULL)
    finalizer(qrm_spfct_destroy!, spfct)
    return spfct
  end
end

function Base.show(io :: IO, ::MIME"text/plain", spfct :: qrm_spfct)
  println(io, "Sparse factorization -- qrm_spfct")
end

const GICNTL = ("qrm_eunit", "qrm_print_etree", "qrm_ounit", "qrm_dunit", "qrm_ncpu", "qrm_ngpu", "qrm_max_mem", "qrm_tot_mem")
const PICNTL = ("qrm_ordering", "qrm_minamalg", "qrm_mb", "qrm_nb", "qrm_ib", "qrm_bh", "qrm_keeph", "qrm_rhsnb", "qrm_nlz", "qrm_pinth")
const RCNTL  = ("qrm_amalgth", "qrm_rweigth", "qrm_mem_relax", "qrm_rd_eps")
const STATS  = ("qrm_e_nnz_r", "qrm_e_nnz_h", "qrm_e_facto_flops", "qrm_e_facto_mempeak", "qrm_nnz_r", "qrm_nnz_h", "qrm_facto_flops", "qrm_rd_num")

function error_handling(err :: Cint)
  status = "Unknown qr_mumps error: $err"
  err == 1  && (status = "The provided sparse matrix format is not supported.")
  err == 3  && (status = "qrm_spfct.rcntl is invalid.")
  err == 4  && (status = "Trying to allocate an already allocated allocatable or pointer.")
  err == 5  && (status = "Memory allocation problem.")
  err == 6  && (status = "Memory allocation problem.")
  err == 8  && (status = "Input column permutation not provided or invalid.")
  err == 9  && (status = "The requested ordering method is unknown.")
  err == 10 && (status = "Internal error: insufficient size for array.")
  err == 11 && (status = "Internal error: Error in lapack routine.")
  err == 12 && (status = "Internal error: out of memory.")
  err == 13 && (status = "The analysis must be done before the factorization.")
  err == 14 && (status = "The factorization must be done before the solve.")
  err == 15 && (status = "This type of norm is not implemented.")
  err == 16 && (status = "Requested ordering method not available (i.e., has not been installed).")
  err == 17 && (status = "Internal error: error from call to subroutine...")
  err == 18 && (status = "An error has occured in a call to COLAMD.")
  err == 19 && (status = "An error has occured in a call to SCOTCH.")
  err == 20 && (status = "An error has occured in a call to Metis.")
  err == 23 && (status = "Incorrect argument to qrm_set or qrm_get.")
  err == 25 && (status = "Internal error: problem opening file.")
  err == 27 && (status = "Incompatible values in qrm_spfct.icntl.")
  err == 28 && (status = "Incorrect value for qrm_mb, qrm_nb or qrm_ib.")
  err == 29 && (status = "Incorrect value for qrm_spmat.m, qrm_spmat.n or qrm_spmat.nz.")
  err == 30 && (status = "qrm_apply cannot be called if the Q matrix is discarded.")
  err == 31 && (status = "StarPU initialization error.")
  err == 32 && (status = "Matrix is rank deficient.")
  return status
end
