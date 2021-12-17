#!/bin/bash

patchelf --set-rpath '$ORIGIN' libgio-2.0.so
patchelf --set-rpath '$ORIGIN' libglib-2.0.so
patchelf --set-rpath '$ORIGIN' libgmodule-2.0.so
patchelf --set-rpath '$ORIGIN' libgobject-2.0.so
patchelf --set-rpath '$ORIGIN' libgstreamer-full-1.0.so
patchelf --set-rpath '$ORIGIN' libgthread-2.0.so