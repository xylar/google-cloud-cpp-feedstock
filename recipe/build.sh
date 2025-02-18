#!/bin/bash

set -euo pipefail

mkdir build_cmake
pushd build_cmake

export OPENSSL_ROOT_DIR=$PREFIX
if [[ "${target_platform}" == osx* ]] && [[ "${abseil_cpp}" == "20210324.2" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CXX_STANDARD=14"
else
  export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CXX_STANDARD=17"
fi

# Overwrite location of protoc plugin to support cross-compilation
sed -ie "s;protoc-gen-grpc.*$;protoc-gen-grpc=${BUILD_PREFIX}/bin/grpc_cpp_plugin;g" ../cmake/CompileProtos.cmake
sed -ie "s;^set(CMAKE_CXX_STANDARD 11);;" ../CMakeLists.txt

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DOPENSSL_ROOT_DIR=$PREFIX \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc \
    -DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF \
    ..

ninja
popd
