for (fname, lname, elty, subty) in (("sqrm_spmat_init_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spmat_init_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spmat_init_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spmat_init_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spmat_init!(spmat :: qrm_spmat{$elty})
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}},), spmat)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_spmat_init(::Type{$elty})
            spmat = qrm_spmat{$elty}()
            qrm_spmat_init!(spmat)
            return spmat
        end

        function qrm_spmat_init!(spmat :: qrm_spmat{$elty}, A :: SparseMatrixCSC{$elty,I}; sym :: Bool=false) where I <: Integer
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}},), spmat)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            spmat.irn, spmat.jcn, spmat.val = findnz(A)
            spmat.mat.m, spmat.mat.n = size(A)
            spmat.mat.nz  = nnz(A)
            spmat.mat.sym = sym
            spmat.mat.irn = pointer(spmat.irn)
            spmat.mat.jcn = pointer(spmat.jcn)
            spmat.mat.val = pointer(spmat.val)
            return nothing
        end

        function qrm_spmat_init(A :: SparseMatrixCSC{$elty,I}; sym :: Bool=false) where I <: Integer
            spmat = qrm_spmat{$elty}()
            qrm_spmat_init!(spmat, A, sym=sym)
            return spmat
        end

        @inline qrm_spmat_init!(spmat :: qrm_spmat{$elty}, A :: Symmetric{$elty, SparseMatrixCSC{$elty,I}}) where I <: Integer = qrm_spmat_init!(spmat, A.data, sym=true)
        @inline qrm_spmat_init!(spmat :: qrm_spmat{$elty}, A :: Hermitian{$elty, SparseMatrixCSC{$elty,I}}) where I <: Integer = qrm_spmat_init!(spmat, A.data, sym=true)

        @inline qrm_spmat_init(A :: Symmetric{$elty, SparseMatrixCSC{$elty,I}}) where I <: Integer = qrm_spmat_init(A.data, sym=true)
        @inline qrm_spmat_init(A :: Hermitian{$elty, SparseMatrixCSC{$elty,I}}) where I <: Integer = qrm_spmat_init(A.data, sym=true)
    end
end

for (fname, lname, elty, subty) in (("sqrm_spmat_destroy_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spmat_destroy_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spmat_destroy_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spmat_destroy_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spmat_destroy!(spmat :: qrm_spmat{$elty})
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}},), spmat)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_spfct_init_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spfct_init_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spfct_init_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spfct_init_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spfct_init!(spfct :: qrm_spfct{$elty}, spmat :: qrm_spmat{$elty})
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, Ref{c_spmat{$elty}}), spfct, spmat)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_spfct_init(spmat :: qrm_spmat{$elty})
            spfct = qrm_spfct{$elty}()
            qrm_spfct_init!(spfct, spmat)
            return spfct
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_spfct_destroy_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spfct_destroy_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spfct_destroy_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spfct_destroy_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spfct_destroy!(spfct :: qrm_spfct{$elty})
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}},), spfct)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_analyse_c", libsqrm, Float32   , Float32),
                                    ("dqrm_analyse_c", libdqrm, Float64   , Float64),
                                    ("cqrm_analyse_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_analyse_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_analyse!(spmat :: qrm_spmat{$elty}, spfct :: qrm_spfct{$elty}; transp :: Char='n')
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ref{c_spfct{$elty}}, UInt8), spmat, spfct, transp)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_analyse(spmat :: qrm_spmat{$elty}; transp :: Char='n')
            spfct = qrm_spfct_init(spmat)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ref{c_spfct{$elty}}, UInt8), spmat, spfct, transp)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return spfct
        end

        @inline qrm_analyse!(spmat :: Transpose{$elty,qrm_spmat{$elty}}, spfct :: qrm_spfct{$elty}) = qrm_analyse!(spmat.parent, spfct, transp='t')
        @inline qrm_analyse!(spmat :: Adjoint{$elty,qrm_spmat{$elty}}  , spfct :: qrm_spfct{$elty}) = qrm_analyse!(spmat.parent, spfct, transp='c')

        @inline qrm_analyse(spmat :: Transpose{$elty,qrm_spmat{$elty}}) = qrm_analyse(spmat.parent, transp='t')
        @inline qrm_analyse(spmat :: Adjoint{$elty,qrm_spmat{$elty}})   = qrm_analyse(spmat.parent, transp='c')
    end
end

for (fname, lname, elty, subty) in (("sqrm_factorize_c", libsqrm, Float32   , Float32),
                                    ("dqrm_factorize_c", libdqrm, Float64   , Float64),
                                    ("cqrm_factorize_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_factorize_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_factorize!(spmat :: qrm_spmat{$elty}, spfct :: qrm_spfct{$elty}; transp :: Char='n')
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ref{c_spfct{$elty}}, UInt8), spmat, spfct, transp)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        @inline qrm_factorize!(spmat :: Transpose{$elty,qrm_spmat{$elty}}, spfct :: qrm_spfct{$elty}) = qrm_factorize!(spmat.parent, spfct, transp='t')
        @inline qrm_factorize!(spmat :: Adjoint{$elty,qrm_spmat{$elty}}  , spfct :: qrm_spfct{$elty}) = qrm_factorize!(spmat.parent, spfct, transp='c')
    end
end

for (fname, lname, elty, subty) in (("sqrm_solve_c", libsqrm, Float32   , Float32),
                                    ("dqrm_solve_c", libdqrm, Float64   , Float64),
                                    ("cqrm_solve_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_solve_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_solve!(spfct :: qrm_spfct{$elty}, b :: Vector{$elty}, x :: Vector{$elty}; transp :: Char='n')
            nrhs = 1
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, UInt8, Ptr{$elty}, Ptr{$elty}, Cint), spfct, transp, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_solve!(spfct :: qrm_spfct{$elty}, b :: Matrix{$elty}, x :: Matrix{$elty}; transp :: Char='n')
            nrhs = size(b, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, UInt8, Ptr{$elty}, Ptr{$elty}, Cint), spfct, transp, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_solve(spfct :: qrm_spfct{$elty}, b :: Vector{$elty}; transp :: Char='n')
            nrhs = 1
            x = zeros($elty, spfct.fct.n)
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, UInt8, Ptr{$elty}, Ptr{$elty}, Cint), spfct, transp, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        function qrm_solve(spfct :: qrm_spfct{$elty}, b :: Matrix{$elty}; transp :: Char='n')
            nrhs = size(b, 2)
            x = zeros($elty, spfct.fct.n, nrhs)
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, UInt8, Ptr{$elty}, Ptr{$elty}, Cint), spfct, transp, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        @inline qrm_solve!(spfct :: Transpose{$elty,qrm_spfct{$elty}}, b :: Vector{$elty}, x :: Vector{$elty}) = qrm_solve!(spfct.parent, b, x, transp='t')
        @inline qrm_solve!(spfct :: Transpose{$elty,qrm_spfct{$elty}}, b :: Matrix{$elty}, x :: Matrix{$elty}) = qrm_solve!(spfct.parent, b, x, transp='t')

        @inline qrm_solve(spfct :: Transpose{$elty,qrm_spfct{$elty}}, b :: Vector{$elty}) = qrm_solve(spfct.parent, b, transp='t')
        @inline qrm_solve(spfct :: Transpose{$elty,qrm_spfct{$elty}}, b :: Matrix{$elty}) = qrm_solve(spfct.parent, b, transp='t')

        @inline qrm_solve!(spfct :: Adjoint{$elty,qrm_spfct{$elty}}, b :: Vector{$elty}, x :: Vector{$elty}) = qrm_solve!(spfct.parent, b, x, transp='c')
        @inline qrm_solve!(spfct :: Adjoint{$elty,qrm_spfct{$elty}}, b :: Matrix{$elty}, x :: Matrix{$elty}) = qrm_solve!(spfct.parent, b, x, transp='c')

        @inline qrm_solve(spfct :: Adjoint{$elty,qrm_spfct{$elty}}, b :: Vector{$elty}) = qrm_solve(spfct.parent, b, transp='c')
        @inline qrm_solve(spfct :: Adjoint{$elty,qrm_spfct{$elty}}, b :: Matrix{$elty}) = qrm_solve(spfct.parent, b, transp='c')
    end
end

for (fname, lname, elty, subty) in (("sqrm_apply_c", libsqrm, Float32   , Float32),
                                    ("dqrm_apply_c", libdqrm, Float64   , Float64),
                                    ("cqrm_apply_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_apply_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_apply!(spfct :: qrm_spfct{$elty}, b :: Vector{$elty}; transp :: Char='n')
            nrhs = 1
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, UInt8, Ptr{$elty}, Cint), spfct, transp, b, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_apply!(spfct :: qrm_spfct{$elty}, b :: Matrix{$elty}; transp :: Char='n')
            nrhs = size(b, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, UInt8, Ptr{$elty}, Cint), spfct, transp, b, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_apply(spfct :: qrm_spfct{$elty}, b :: Vector{$elty}; transp :: Char='n')
            nrhs = 1
            z = copy(b)
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, UInt8, Ptr{$elty}, Cint), spfct, transp, z, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return z
        end

        function qrm_apply(spfct :: qrm_spfct{$elty}, b :: Matrix{$elty}; transp :: Char='n')
            nrhs = size(b, 2)
            z = copy(b)
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, UInt8, Ptr{$elty}, Cint), spfct, transp, z, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return z
        end

        @inline qrm_apply!(spfct :: Transpose{$elty,qrm_spfct{$elty}}, b :: Vector{$elty}) = qrm_apply!(spfct.parent, b, transp='t')
        @inline qrm_apply!(spfct :: Transpose{$elty,qrm_spfct{$elty}}, b :: Matrix{$elty}) = qrm_apply!(spfct.parent, b, transp='t')

        @inline qrm_apply(spfct :: Transpose{$elty,qrm_spfct{$elty}}, b :: Vector{$elty}) = qrm_apply(spfct.parent, b, transp='t')
        @inline qrm_apply(spfct :: Transpose{$elty,qrm_spfct{$elty}}, b :: Matrix{$elty}) = qrm_apply(spfct.parent, b, transp='t')

        @inline qrm_apply!(spfct :: Adjoint{$elty,qrm_spfct{$elty}}, b :: Vector{$elty}) = qrm_apply!(spfct.parent, b, transp='c')
        @inline qrm_apply!(spfct :: Adjoint{$elty,qrm_spfct{$elty}}, b :: Matrix{$elty}) = qrm_apply!(spfct.parent, b, transp='c')

        @inline qrm_apply(spfct :: Adjoint{$elty,qrm_spfct{$elty}}, b :: Vector{$elty}) = qrm_apply(spfct.parent, b, transp='c')
        @inline qrm_apply(spfct :: Adjoint{$elty,qrm_spfct{$elty}}, b :: Matrix{$elty}) = qrm_apply(spfct.parent, b, transp='c')
    end
end

# err is a Cvoid and not a Cint
for (fname, lname, elty, subty) in (("sqrm_spmat_mv_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spmat_mv_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spmat_mv_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spmat_mv_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spmat_mv!(spmat :: qrm_spmat{$elty}, alpha :: $elty, x :: Vector{$elty}, beta :: $elty, y :: Vector{$elty}; transp :: Char='n')
            nrhs = 1
            err = ccall(($fname, $lname), Cvoid, (Ref{c_spmat{$elty}}, UInt8, $elty, Ptr{$elty}, $elty, Ptr{$elty}, Cint), spmat, transp, alpha, x, beta, y, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_spmat_mv!(spmat :: qrm_spmat{$elty}, alpha :: $elty, x :: Matrix{$elty}, beta :: $elty, y :: Matrix{$elty}; transp :: Char='n')
            nrhs = size(y, 2)
            err = ccall(($fname, $lname), Cvoid, (Ref{c_spmat{$elty}}, UInt8, $elty, Ptr{$elty}, $elty, Ptr{$elty}, Cint), spmat, transp, alpha, x, beta, y, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        @inline qrm_spmat_mv!(spmat :: Transpose{$elty,qrm_spmat{$elty}}, alpha :: $elty, x :: Vector{$elty}, beta :: $elty, y :: Vector{$elty}) = qrm_matmul(spmat.parent, alpha, x, beta, y, transp='t')
        @inline qrm_spmat_mv!(spmat :: Transpose{$elty,qrm_spmat{$elty}}, alpha :: $elty, x :: Matrix{$elty}, beta :: $elty, y :: Matrix{$elty}) = qrm_matmul(spmat.parent, alpha, x, beta, y, transp='t')

        @inline qrm_spmat_mv!(spmat :: Adjoint{$elty,qrm_spmat{$elty}}, alpha :: $elty, x :: Vector{$elty}, beta :: $elty, y :: Vector{$elty}) = qrm_matmul(spmat.parent, alpha, x, beta, y, transp='c')
        @inline qrm_spmat_mv!(spmat :: Adjoint{$elty,qrm_spmat{$elty}}, alpha :: $elty, x :: Matrix{$elty}, beta :: $elty, y :: Matrix{$elty}) = qrm_matmul(spmat.parent, alpha, x, beta, y, transp='c')
    end
end

for (fname, lname, elty, subty) in (("sqrm_spmat_nrm_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spmat_nrm_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spmat_nrm_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spmat_nrm_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spmat_nrm(spmat :: qrm_spmat{$elty}; ntype :: Char='f')
            nrm = Ref{$subty}(0)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, UInt8, Ref{$subty}), spmat, ntype, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nrm[]
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_vecnrm_c", libsqrm, Float32   , Float32),
                                    ("dqrm_vecnrm_c", libdqrm, Float64   , Float64),
                                    ("cqrm_vecnrm_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_vecnrm_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_vecnrm(x :: Vector{$elty}; ntype :: Char='2')
            n = length(x)
            nrhs = 1
            nrm = Ref{$subty}(0)
            err = ccall(($fname, $lname), Cint, (Ptr{$elty}, Cint, Cint, UInt8, Ref{$subty}), x, n, nrhs, ntype, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nrm[]
        end

        function qrm_vecnrm(x :: Matrix{$elty}; ntype :: Char='2')
            n, nrhs = size(x)
            nrm = zeros($subty, nrhs)
            err = ccall(($fname, $lname), Cint, (Ptr{$elty}, Cint, Cint, UInt8, Ptr{$subty}), x, n, nrhs, ntype, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nrm
        end

        function qrm_vecnrm!(x :: Matrix{$elty}, nrm :: Vector{$subty}; ntype :: Char='2')
            n, nrhs = size(x)
            err = ccall(($fname, $lname), Cint, (Ptr{$elty}, Cint, Cint, UInt8, Ptr{$subty}), x, n, nrhs, ntype, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_spbackslash_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spbackslash_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spbackslash_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spbackslash_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spbackslash!(spmat :: qrm_spmat{$elty}, b :: Vector{$elty}, x :: Vector{$elty})
            nrhs = 1
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_spbackslash!(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty}, x :: Matrix{$elty})
            nrhs = size(b, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end


        function qrm_spbackslash(spmat :: qrm_spmat{$elty}, b :: Vector{$elty})
            nrhs = 1
            x = zeros($elty, spmat.mat.n)
            bcopy = (spmat.mat.m ≥ spmat.mat.n) ? copy(b) : b
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, bcopy, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        function qrm_spbackslash(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty})
            nrhs = size(b, 2)
            x = zeros($elty, spmat.mat.n, nrhs)
            bcopy = (spmat.mat.m ≥ spmat.mat.n) ? copy(b) : b
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, bcopy, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        @inline (\)(spmat :: qrm_spmat{$elty}, b :: Vector{$elty}) = qrm_spbackslash(spmat, b)
        @inline (\)(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty}) = qrm_spbackslash(spmat, b)
    end
end

for (fname, lname, elty, subty) in (("sqrm_spfct_backslash_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spfct_backslash_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spfct_backslash_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spfct_backslash_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spbackslash!(spfct :: qrm_spfct{$elty}, b :: Vector{$elty}, x :: Vector{$elty})
            nrhs = 1
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spfct, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_spbackslash!(spfct :: qrm_spfct{$elty}, b :: Matrix{$elty}, x :: Matrix{$elty})
            nrhs = size(b, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spfct, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end


        function qrm_spbackslash(spfct :: qrm_spfct{$elty}, b :: Vector{$elty})
            nrhs = 1
            x = zeros($elty, spfct.fct.n)
            bcopy = (spfct.fct.m ≥ spfct.fct.n) ? copy(b) : b
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spfct, bcopy, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        function qrm_spbackslash(spfct :: qrm_spfct{$elty}, b :: Matrix{$elty})
            nrhs = size(b, 2)
            x = zeros($elty, spfct.fct.n, nrhs)
            bcopy = (spfct.fct.m ≥ spfct.fct.n) ? copy(b) : b
            err = ccall(($fname, $lname), Cint, (Ref{c_spfct{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spfct, bcopy, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        @inline (\)(spfct :: qrm_spfct{$elty}, b :: Vector{$elty}) = qrm_spbackslash(spfct, b)
        @inline (\)(spfct :: qrm_spfct{$elty}, b :: Matrix{$elty}) = qrm_spbackslash(spfct, b)
    end
end

for (fname, lname, elty, subty) in (("sqrm_spposv_c", libsqrm, Float32   , Float32),
                                    ("dqrm_spposv_c", libdqrm, Float64   , Float64),
                                    ("cqrm_spposv_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_spposv_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_spposv!(spmat :: qrm_spmat{$elty}, b :: Vector{$elty}, x :: Vector{$elty})
            nrhs = 1
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end
        
        function qrm_spposv!(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty}, x :: Matrix{$elty})
            nrhs = size(b, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_spposv(spmat :: qrm_spmat{$elty}, b :: Vector{$elty})
            nrhs = 1
            x = zeros($elty, spmat.mat.n)
            bcopy = copy(b)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, bcopy, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        function qrm_spposv(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty})
            nrhs = size(b, 2)
            x = zeros($elty, spmat.mat.n, nrhs)
            bcopy = copy(b)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, bcopy, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_least_squares_c", libsqrm, Float32   , Float32),
                                    ("dqrm_least_squares_c", libdqrm, Float64   , Float64),
                                    ("cqrm_least_squares_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_least_squares_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_least_squares!(spmat :: qrm_spmat{$elty}, b :: Vector{$elty}, x :: Vector{$elty})
            nrhs = 1
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_least_squares!(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty}, x :: Matrix{$elty})
            nrhs = size(b, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_least_squares(spmat :: qrm_spmat{$elty}, b :: Vector{$elty})
            nrhs = 1
            x = zeros($elty, spmat.mat.n)
            bcopy = copy(b)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, bcopy, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        function qrm_least_squares(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty})
            nrhs = size(b, 2)
            x = zeros($elty, spmat.mat.n, nrhs)
            bcopy = copy(b)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, bcopy, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_min_norm_c", libsqrm, Float32   , Float32),
                                    ("dqrm_min_norm_c", libdqrm, Float64   , Float64),
                                    ("cqrm_min_norm_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_min_norm_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_min_norm!(spmat :: qrm_spmat{$elty}, b :: Vector{$elty}, x :: Vector{$elty})
            nrhs = 1
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_min_norm!(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty}, x :: Matrix{$elty})
            nrhs = size(b, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end

        function qrm_min_norm(spmat :: qrm_spmat{$elty}, b :: Vector{$elty})
            nrhs = 1
            x = zeros($elty, spmat.mat.n)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end

        function qrm_min_norm(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty})
            nrhs = size(b, 2)
            x = zeros($elty, spmat.mat.n, nrhs)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint), spmat, b, x, nrhs)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return x
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_residual_norm_c", libsqrm, Float32   , Float32),
                                    ("dqrm_residual_norm_c", libdqrm, Float64   , Float64),
                                    ("cqrm_residual_norm_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_residual_norm_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_residual_norm(spmat :: qrm_spmat{$elty}, b :: Vector{$elty}, x :: Vector{$elty})
            nrhs = 1
            nrm = Ref{$subty}(0)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint, Ref{$subty}), spmat, b, x, nrhs, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nrm[]
        end

        function qrm_residual_norm(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty}, x :: Matrix{$elty})
            nrhs = size(x, 2)
            nrm = zeros($subty, nrhs)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint, Ptr{$subty}), spmat, b, x, nrhs, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nrm
        end

        function qrm_residual_norm!(spmat :: qrm_spmat{$elty}, b :: Matrix{$elty}, x :: Matrix{$elty}, nrm :: Vector{$elty})
            nrhs = size(x, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Ptr{$elty}, Cint, Ptr{$subty}), spmat, b, x, nrhs, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end
    end
end

for (fname, lname, elty, subty) in (("sqrm_residual_orth_c", libsqrm, Float32   , Float32),
                                    ("dqrm_residual_orth_c", libdqrm, Float64   , Float64),
                                    ("cqrm_residual_orth_c", libcqrm, ComplexF32, Float32),
                                    ("zqrm_residual_orth_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_residual_orth(spmat :: qrm_spmat{$elty}, r :: Vector{$elty})
            nrhs = 1
            nrm = Ref{$subty}(0)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Cint, Ref{$subty}), spmat, r, nrhs, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nrm[]
        end

        function qrm_residual_orth(spmat :: qrm_spmat{$elty}, r :: Matrix{$elty})
            nrhs = size(r, 2)
            nrm = zeros($subty, nrhs)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Cint, Ptr{$subty}), spmat, r, nrhs, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nrm
        end

        function qrm_residual_orth!(spmat :: qrm_spmat{$elty}, r :: Matrix{$elty}, nrm :: Vector{$elty})
            nrhs = size(r, 2)
            err = ccall(($fname, $lname), Cint, (Ref{c_spmat{$elty}}, Ptr{$elty}, Cint, Ptr{$subty}), spmat, r, nrhs, nrm)
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end
    end
end

function qrm_set(str :: String, val :: Number)
    if (str ∈ GICNTL) || (str ∈ PICNTL)
        err = ccall(("qrm_glob_set_i4_c", libqrm_common), Cint, (Cstring, Cint), str, val)
    elseif str ∈ RCNTL
        err = ccall(("qrm_glob_set_r4_c", libqrm_common), Cint, (Cstring, Cfloat), str, val)
    else
        err = Int32(23)
    end
    (err ≠ 0) && throw(ErrorException(error_handling(err)))
    return nothing
end

for (finame, frname, lname, elty, subty) in (("sqrm_spfct_set_i4_c", "sqrm_spfct_set_r4_c", libsqrm, Float32   , Float32),
                                             ("dqrm_spfct_set_i4_c", "dqrm_spfct_set_r4_c", libdqrm, Float64   , Float64),
                                             ("cqrm_spfct_set_i4_c", "cqrm_spfct_set_r4_c", libcqrm, ComplexF32, Float32),
                                             ("zqrm_spfct_set_i4_c", "zqrm_spfct_set_r4_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_set(spfct :: qrm_spfct{$elty}, str :: String, val :: Number)
            if str ∈ PICNTL
                err = ccall(($finame, $lname), Cint, (Ref{c_spfct{$elty}}, Cstring, Cint), spfct, str, val)
            elseif str ∈ RCNTL
                err = ccall(($frname, $lname), Cint, (Ref{c_spfct{$elty}}, Cstring, Cfloat), spfct, str, val)
            else
                err = Int32(23)
            end
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return nothing
        end
    end
end

function qrm_get(str :: String)
    if (str ∈ GICNTL) || (str ∈ PICNTL)
        val = Ref{Clonglong}(0)
        err = ccall(("qrm_glob_get_i8_c", libqrm_common), Cint, (Cstring, Ref{Clonglong}), str, val)
    elseif str ∈ RCNTL
        val = Ref{Float32}(0)
        err = ccall(("qrm_glob_get_r4_c", libqrm_common), Cint, (Cstring, Ref{Cfloat}), str, val)
    else
        err = Int32(23)
    end
    (err ≠ 0) && throw(ErrorException(error_handling(err)))
    return val[]
end

for (finame, frname, lname, elty, subty) in (("sqrm_spfct_get_i8_c", "sqrm_spfct_get_r4_c", libsqrm, Float32   , Float32),
                                             ("dqrm_spfct_get_i8_c", "dqrm_spfct_get_r4_c", libdqrm, Float64   , Float64),
                                             ("cqrm_spfct_get_i8_c", "cqrm_spfct_get_r4_c", libcqrm, ComplexF32, Float32),
                                             ("zqrm_spfct_get_i8_c", "zqrm_spfct_get_r4_c", libzqrm, ComplexF64, Float64))
    @eval begin
        function qrm_get(spfct :: qrm_spfct{$elty}, str :: String)
            if (str ∈ PICNTL) || (str ∈ STATS)
                val = Ref{Clonglong}(0)
                err = ccall(($finame, $lname), Cint, (Ref{c_spfct{$elty}}, Cstring, Ref{Clonglong}), spfct, str, val)
            elseif str ∈ RCNTL
                val = Ref{Float32}(0)
                err = ccall(($frname, $lname), Cint, (Ref{c_spfct{$elty}}, Cstring, Ref{Cfloat}), spfct, str, val)
            else
                err = Int32(23)
            end
            (err ≠ 0) && throw(ErrorException(error_handling(err)))
            return val[]
        end
    end
end

function qrm_init(ncpu :: Integer=1, ngpu :: Integer=0)
    err = ccall(("qrm_init_c", libqrm_common), Cint, (Cint, Cint), ncpu, ngpu)
    (err ≠ 0) && throw(ErrorException(error_handling(err)))
    return nothing
end

function qrm_finalize()
    ccall(("qrm_finalize_c", libqrm_common), Cvoid, ())
    return nothing
end

function qrm_update!(spmat :: qrm_spmat{T}, A :: SparseMatrixCSC{T,I}) where {T, I <: Integer}
    spmat.val .= A.nzval
    return nothing
end
