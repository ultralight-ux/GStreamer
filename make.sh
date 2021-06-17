#!/bin/bash

BUILD_DIR=build
INSTALL_DIR=build/out
CUR_DIR=$(pwd)

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

mkdir -p $INSTALL_DIR
INSTALL_PATH=$(cd $INSTALL_DIR; pwd)
cd $CUR_DIR

meson --prefix=$INSTALL_PATH --default-library=static -Ddebug=false -Doptimization=s -Dintrospection=disabled -Dglib:default_library=shared -Dglib:tests=false -Dgst-plugins-good:cairo=disabled -Dgst-plugins-good:soup=disabled -Dgst-plugins-good:tests=disabled -Dgst-plugins-good:dv=disabled -Dgst-plugins-bad:openh264=disabled -Dgst-plugins-bad:openjpeg=disabled -Dgst-plugins-bad:tests=disabled -Dgst-plugins-base:pango=disabled -DFFmpeg:libfreetype=disabled -Dcairo:freetype=disabled -Dlibsoup:tests=false -Dugly=disabled -Dpython=disabled -Ddevtools=disabled -Dgst-examples=disabled -Dtls=disabled -Dqt5=disabled -Dtests=disabled -Dexamples=disabled -Dc_args="-DG_INTL_STATIC_COMPILATION -DFFI_STATIC_BUILD -DORC_STATIC_COMPILATION -DPSL_STATIC -DLIBXML_STATIC -DOPJ_STATIC -DPCRE_STATIC" -Dcpp_args="-DG_INTL_STATIC_COMPILATION -DFFI_STATIC_BUILD -DORC_STATIC_COMPILATION -DPSL_STATIC -DLIBXML_STATIC -DOPJ_STATIC -DPCRE_STATIC" -Dgst-full-version-script="" $BUILD_DIR
cd $BUILD_DIR
ninja
ninja install
cd $CUR_DIR
