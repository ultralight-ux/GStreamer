#!/bin/bash

INSTALL_LIB_PATH=$(pwd)
libs='libgio-2.0.0.dylib libgobject-2.0.0.dylib libgthread-2.0.0.dylib libgmodule-2.0.0.dylib libglib-2.0.0.dylib libgstreamer-full-1.0.dylib'
                                      
for lib in $libs
do
  install_name_tool -id @rpath/$lib $lib
  for dep in $libs
  do
    install_name_tool -change $INSTALL_LIB_PATH/$dep @rpath/$dep $lib
  done
done