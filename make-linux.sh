#!/bin/bash

BUILD_DIR=build
INSTALL_DIR=build/out
CUR_DIR=$(pwd)

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

mkdir -p $INSTALL_DIR
INSTALL_PATH=$(cd $INSTALL_DIR; pwd)
INSTALL_LIB_PATH=$INSTALL_PATH/lib/x86_64-linux-gnu
cd $CUR_DIR

meson --prefix=$INSTALL_PATH --default-library=static -Ddebug=false -Doptimization=s -Dintrospection=disabled -Dglib:default_library=shared -Dglib:tests=false -Dgst-plugins-good:cairo=disabled -Dgst-plugins-good:soup=disabled -Dgst-plugins-good:tests=disabled -Dgst-plugins-good:dv=disabled -Dgst-plugins-bad:openh264=disabled -Dgst-plugins-bad:openjpeg=disabled -Dgst-plugins-bad:tests=disabled -Dgst-plugins-base:pango=disabled -DFFmpeg:libfreetype=disabled -Dcairo:freetype=disabled -Dlibsoup:tests=false -Dugly=disabled -Dpython=disabled -Ddevtools=disabled -Dgst-examples=disabled -Dtls=disabled -Dqt5=disabled -Dtests=disabled -Dexamples=disabled -Dc_args="-DG_INTL_STATIC_COMPILATION -DFFI_STATIC_BUILD -DORC_STATIC_COMPILATION -DPSL_STATIC -DLIBXML_STATIC -DOPJ_STATIC -DPCRE_STATIC -fPIC" -Dcpp_args="-DG_INTL_STATIC_COMPILATION -DFFI_STATIC_BUILD -DORC_STATIC_COMPILATION -DPSL_STATIC -DLIBXML_STATIC -DOPJ_STATIC -DPCRE_STATIC -fPIC" -Dasm_args="-fPIC" -Dgst-full-version-script="" $BUILD_DIR
cd $BUILD_DIR
ninja
ninja install
cd $INSTALL_LIB_PATH
patchelf --set-rpath '$ORIGIN' libgio-2.0.so
patchelf --set-rpath '$ORIGIN' libglib-2.0.so
patchelf --set-rpath '$ORIGIN' libgmodule-2.0.so
patchelf --set-rpath '$ORIGIN' libgobject-2.0.so
patchelf --set-rpath '$ORIGIN' libgstreamer-full-1.0.so
patchelf --set-rpath '$ORIGIN' libgthread-2.0.so
cd $CUR_DIR
