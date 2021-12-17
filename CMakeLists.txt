cmake_minimum_required(VERSION 3.15.0)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

include(common)

project(GStreamer C CXX)

include(Deps.cmake)

# Define which plugins to disable in GStreamer
set(DISABLED_PLUGINS
    cairo:freetype
    devtools
    examples
    FFmpeg:libfreetype
    ges
    gst-examples
    gst-plugins-bad:gl
    gst-plugins-bad:glib-asserts
    gst-plugins-bad:glib-checks
    gst-plugins-bad:gobject-cast-checks
    gst-plugins-bad:mediafoundation
    gst-plugins-bad:openh264
    gst-plugins-bad:openjpeg
    gst-plugins-bad:tests
    gst-plugins-bad:wasapi2
    gst-plugins-base:glib-asserts
    gst-plugins-base:glib-checks
    gst-plugins-base:gobject-cast-checks
    gst-plugins-base:pango
    gst-plugins-good:cairo
    gst-plugins-good:dv
    gst-plugins-good:glib-asserts
    gst-plugins-good:glib-checks
    gst-plugins-good:gobject-cast-checks
    gst-plugins-good:soup
    gst-plugins-good:tests
    gstreamer:extra-checks
    gstreamer:glib-asserts
    gstreamer:glib-checks
    introspection
    python
    qt5
    tests
    tls
    ugly
)

if (NOT CMAKE_SYSTEM_NAME MATCHES "Linux")
    list(APPEND DISABLED_PLUGINS gst-plugins-bad:tinyalsa)
endif ()

set(C_ARGS -DFFI_STATIC_BUILD -DG_INTL_STATIC_COMPILATION -DLIBXML_STATIC -DOPJ_STATIC -DORC_STATIC_COMPILATION -DPCRE_STATIC -DPSL_STATIC ${UL_GSTREAMER_C_FLAGS})

set(LINK_ARGS ${UL_GSTREAMER_LINK_FLAGS})

set(MESON_FLAGS
    --default-library=static
    --force-fallback-for=glib,libffi
    -Ddebug=false
    -Dglib:default_library=shared
    -Dglib:tests=false
    -Dgst-full-version-script=""
    -Dgstreamer:gst_debug=false
    -Dlibsoup:tests=false
    -Doptimization=s
    ${UL_GSTREAMER_MESON_FLAGS}
)

if (NOT CMAKE_SYSTEM_NAME MATCHES "Darwin")
    list(APPEND MESON_FLAGS --wrap-mode=nodownload)
    list(APPEND DISABLED_PLUGINS gst-plugins-base:gl)
endif ()

set(GSTREAMER_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE PATH "Location of 'GStreamer'")
set(GSTREAMER_BUILD_DIR "${CMAKE_BINARY_DIR}/gstreamer")
set(GSTREAMER_INSTALL_DIR "${GSTREAMER_BUILD_DIR}/out")

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(GSTREAMER_LIBNAME "libgstreamer-full-1.0.so")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(GSTREAMER_LIBNAME "libgstreamer-full-1.0.dylib")
elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
    set(GSTREAMER_LIBNAME "gstreamer-full-1.0.dll")
else ()
    message(FATAL_ERROR "Unhandled target OS: '${CMAKE_SYSTEM_NAME}'")
endif ()

function(JOIN VALUES GLUE OUTPUT)
  string (REGEX REPLACE "([^\\]|^);" "\\1${GLUE}" _TMP_STR "${VALUES}")
  string (REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}") #fixes escaping
  set (${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)
endfunction()

set(MESON_ARGS meson --prefix="${GSTREAMER_INSTALL_DIR}" -DFFmpeg:installpath="${FFMPEG_DIR}" ${MESON_FLAGS})

JOIN("${C_ARGS}" " " C_ARGS_STR)

list(APPEND MESON_ARGS -Dc_args="${C_ARGS_STR}" -Dcpp_args="${C_ARGS_STR}")

if (LINK_ARGS)
    JOIN("${LINK_ARGS}" " " LINK_ARGS_STR)

    list(APPEND MESON_ARGS -Dc_link_args="${LINK_ARGS_STR}" -Dcpp_link_args="${LINK_ARGS_STR}")
endif ()

foreach(plugin ${DISABLED_PLUGINS})
    list(APPEND MESON_ARGS -D${plugin}=disabled)
endforeach()

# Platform-specific args should be defined in platform toolchain
if (UL_GSTREAMER_ARGS)
    list(APPEND MESON_ARGS ${UL_GSTREAMER_ARGS})
endif ()

list(APPEND MESON_ARGS ${GSTREAMER_BUILD_DIR})

add_custom_command(OUTPUT "${GSTREAMER_BUILD_DIR}/build.ninja"
                    COMMAND ${MESON_ARGS}
                    WORKING_DIRECTORY "${GSTREAMER_DIR}"
                    COMMENT "Configuring GStreamer."
                    )

add_custom_command(OUTPUT "${GSTREAMER_BUILD_DIR}/${GSTREAMER_LIBNAME}"
                    COMMAND ninja
                    DEPENDS "${GSTREAMER_BUILD_DIR}/build.ninja"
                    WORKING_DIRECTORY "${GSTREAMER_BUILD_DIR}"
                    COMMENT "Building GStreamer.")

if (CMAKE_SYSTEM_NAME MATCHES "Windows")       
    # We need to copy intl.lib over on Windows to avoid an install error  
    file(TO_NATIVE_PATH "${GSTREAMER_DIR}/data/intl.lib" INTL_LIB_PATH)           
    file(TO_NATIVE_PATH "${GSTREAMER_BUILD_DIR}/subprojects/proxy-libintl/" INTL_LIB_DEST)
    add_custom_command(OUTPUT "${GSTREAMER_BUILD_DIR}/copy_files.stamp"
                        COMMAND XCOPY /Q /Y "${INTL_LIB_PATH}" "${INTL_LIB_DEST}"
                        COMMAND ${CMAKE_COMMAND} -E touch copy_files.stamp
                        DEPENDS "${GSTREAMER_BUILD_DIR}/${GSTREAMER_LIBNAME}"
                        WORKING_DIRECTORY "${GSTREAMER_BUILD_DIR}"
                        COMMENT "Copying files."
                        VERBATIM) 
else()
    # Dummy build step
    add_custom_command(OUTPUT "${GSTREAMER_BUILD_DIR}/copy_files.stamp"
                        COMMAND ${CMAKE_COMMAND} -E touch copy_files.stamp
                        DEPENDS "${GSTREAMER_BUILD_DIR}/${GSTREAMER_LIBNAME}"
                        WORKING_DIRECTORY "${GSTREAMER_BUILD_DIR}"
                        COMMENT "Copying files.") 
endif()                                      

add_custom_command(OUTPUT "${GSTREAMER_INSTALL_DIR}/include/gstreamer-1.0/gst/gst.h"
                    COMMAND ninja install
                    DEPENDS "${GSTREAMER_BUILD_DIR}/copy_files.stamp"
                    WORKING_DIRECTORY "${GSTREAMER_BUILD_DIR}"
                    COMMENT "Installing GStreamer.")

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    # We need to update the rpath for our dynamic libraries
    set(INSTALL_LIBPATH "${GSTREAMER_INSTALL_DIR}/lib/x86_64-linux-gnu")
    
    add_custom_command(OUTPUT "${INSTALL_LIBPATH}/update_rpath.stamp"
                        COMMAND ${GSTREAMER_DIR}/update_rpath_linux.sh
                        COMMAND ${CMAKE_COMMAND} -E touch update_rpath.stamp
                        DEPENDS "${GSTREAMER_INSTALL_DIR}/include/gstreamer-1.0/gst/gst.h"
                        WORKING_DIRECTORY "${INSTALL_LIBPATH}"
                        COMMENT "Updating RPath.")

    add_custom_target(GStreamer ALL DEPENDS "${INSTALL_LIBPATH}/update_rpath.stamp")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/include" DESTINATION ".")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/bin" DESTINATION ".")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/lib/x86_64-linux-gnu" DESTINATION "./lib" FILES_MATCHING PATTERN "*.so")
    INSTALL(FILES "${GSTREAMER_INSTALL_DIR}/lib/x86_64-linux-gnu/glib-2.0/include/glibconfig.h" DESTINATION "include/")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    # We need to update the rpath for our dynamic libraries
    set(INSTALL_LIBPATH "${GSTREAMER_INSTALL_DIR}/lib")
    
    add_custom_command(OUTPUT "${INSTALL_LIBPATH}/update_rpath.stamp"
                        COMMAND ${GSTREAMER_DIR}/update_rpath_macos.sh
                        COMMAND ${CMAKE_COMMAND} -E touch update_rpath.stamp
                        DEPENDS "${GSTREAMER_INSTALL_DIR}/include/gstreamer-1.0/gst/gst.h"
                        WORKING_DIRECTORY "${INSTALL_LIBPATH}"
                        COMMENT "Updating RPath.")

    add_custom_target(GStreamer ALL DEPENDS "${INSTALL_LIBPATH}/update_rpath.stamp")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/include" DESTINATION ".")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/bin" DESTINATION ".")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/lib" DESTINATION "." FILES_MATCHING PATTERN "*.dylib")
    INSTALL(FILES "${GSTREAMER_INSTALL_DIR}/lib/glib-2.0/include/glibconfig.h" DESTINATION "include/")
elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
    add_custom_target(GStreamer ALL DEPENDS "${GSTREAMER_INSTALL_DIR}/include/gstreamer-1.0/gst/gst.h")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/include" DESTINATION ".")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/bin" DESTINATION ".")
    INSTALL(DIRECTORY "${GSTREAMER_INSTALL_DIR}/lib" DESTINATION "." FILES_MATCHING PATTERN "*.lib" PATTERN "*.dll")
    INSTALL(FILES "${GSTREAMER_INSTALL_DIR}/lib/glib-2.0/include/glibconfig.h" DESTINATION "include/")
endif ()

add_dependencies(GStreamer FFmpegBin)

include(CreateSDK.cmake)