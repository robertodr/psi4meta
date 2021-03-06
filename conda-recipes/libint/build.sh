#MAX_AM_ERI=6
#MAX_AM_ERI=7
#MAX_AM_ERI=8

if [ "${PSI_BUILD_ISA}" == "sse41" ]; then
    ISA="-msse4.1"
elif [ "${PSI_BUILD_ISA}" == "avx2" ]; then
    ISA="-march=native"
fi


if [ "$(uname)" == "Darwin" ]; then

    # configure
    ${PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_C_FLAGS="${ISA}" \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_CXX_FLAGS="-stdlib=libc++ ${ISA}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DMAX_AM_ERI=${MAX_AM_ERI} \
        -DBUILD_SHARED_LIBS=ON \
        -DMERGE_LIBDERIV_INCLUDEDIR=ON \
        -DENABLE_XHOST=OFF
fi

if [ "$(uname)" == "Linux" ]; then

    # load Intel compilers
    set +x
    source /theoryfs2/common/software/intel2016/bin/compilervars.sh intel64
    set -x

    # link against older libc for generic linux
    TLIBC=/theoryfs2/ds/cdsgroup/psi4-compile/nightly/glibc2.12
    LIBC_INTERJECT="${TLIBC}/lib64/libc.so.6"

    # build multi-instruction-set library
    OPTS="-msse2 -axCORE-AVX2,AVX"

    # configure
    ${PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=icc \
        -DCMAKE_CXX_COMPILER=icpc \
        -DCMAKE_C_FLAGS="${OPTS}" \
        -DCMAKE_CXX_FLAGS="${OPTS}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DMAX_AM_ERI=${MAX_AM_ERI} \
        -DBUILD_SHARED_LIBS=ON \
        -DMERGE_LIBDERIV_INCLUDEDIR=ON \
        -DENABLE_XHOST=OFF \
        -DENABLE_GENERIC=ON \
        -DLIBC_INTERJECT="${LIBC_INTERJECT}"
fi

# build
cd build
make -j${CPU_COUNT}
#make VERBOSE=1

# install
make install

# test
# no independent tests


# <<<  Notes  >>>

# * Recipe won't build if conda path has double slash. Error:
#
#   CMake Error at cmake_install.cmake:31 (file):
#     file called with network path DESTINATION.  This does not make sense when
#     using DESTDIR.  Specify local absolute path or remove DESTDIR environment
#     variable.
#
#     DESTINATION=
#
#     //anaconda/envs/_build/bin

