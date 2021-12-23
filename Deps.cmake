include(ExternalProject)

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ARCHITECTURE "x64")
else ()
    set(ARCHITECTURE "x86")
endif ()

get_filename_component(FFMPEG_DIR "${CMAKE_CURRENT_LIST_DIR}/deps/ffmpeg" REALPATH)

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(PLATFORM "linux")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(PLATFORM "mac")
elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
    set(PLATFORM "win")
endif ()

set(FFMPEG_REV "888688c6")

if (${ALLINONE_BUILD})
  message("Using local deps from all-in-one build.")
  get_filename_component(FFMPEG_DIR "${CMAKE_INSTALL_PREFIX}" REALPATH)
  add_custom_target(FFmpegBin)
elseif(${USE_LOCAL_DEPS})
  message("Using local deps.")
  add_custom_target(FFmpegBin)
else ()
  ExternalProject_Add(FFmpegBin
    URL https://ffmpeg-bin.sfo2.digitaloceanspaces.com/ffmpeg-bin-${FFMPEG_REV}-${PLATFORM}-${ARCHITECTURE}.7z
    SOURCE_DIR "${FFMPEG_DIR}"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND} -E echo_append #dummy command
    INSTALL_COMMAND ""
    INSTALL_DIR ${PROJECT_BINARY_DIR}/dummyInstall
  )
endif ()