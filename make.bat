@echo off
SETLOCAL

SET BUILD_DIR=build-win-msvc-2019

IF NOT EXIST %BUILD_DIR% MKDIR %BUILD_DIR%

CALL :NORMALIZEPATH "./%BUILD_DIR%"
SET BUILD_PATH=%RETVAL%

CALL :NORMALIZEPATH "./%BUILD_DIR%/out"
SET INSTALL_PATH=%RETVAL%

CALL :NORMALIZEPATH "./data"
SET DATA_DIR=%RETVAL%

CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

meson --prefix=%INSTALL_PATH% --default-library=static --buildtype=minsize --wrap-mode=nodownload -Dintrospection=disabled -Dglib:default_library=shared -Dglib:tests=false -Dgst-plugins-good:cairo=disabled -Dgst-plugins-base:gl=disabled -Dgst-plugins-bad:gl=disabled -Dgst-plugins-good:soup=disabled -Dgst-plugins-good:tests=disabled -Dgst-plugins-good:dv=disabled -Dgst-plugins-bad:openh264=disabled -Dgst-plugins-bad:openjpeg=disabled -Dgst-plugins-bad:tests=disabled -Dgst-plugins-base:pango=disabled -DFFmpeg:libfreetype=disabled -Dcairo:freetype=disabled -Dlibsoup:tests=false -Dugly=disabled -Dpython=disabled -Ddevtools=disabled -Dgst-examples=disabled -Dtls=disabled -Dqt5=disabled -Dtests=disabled -Dexamples=disabled -Dc_args="-DG_INTL_STATIC_COMPILATION -DFFI_STATIC_BUILD -DORC_STATIC_COMPILATION -DPSL_STATIC -DLIBXML_STATIC -DOPJ_STATIC -DPCRE_STATIC" -Dcpp_args="-DG_INTL_STATIC_COMPILATION -DFFI_STATIC_BUILD -DORC_STATIC_COMPILATION -DPSL_STATIC -DLIBXML_STATIC -DOPJ_STATIC -DPCRE_STATIC" %BUILD_DIR%
cd %BUILD_DIR%
ninja

:: == Have to do this to avoid install error. ==
XCOPY /Q /Y "%DATA_DIR%\intl.lib" "%BUILD_PATH%\subprojects\proxy-libintl\"

ninja install

:: ========== FUNCTIONS ==========
EXIT /B

:NORMALIZEPATH
  SET RETVAL=%~f1
  EXIT /B
