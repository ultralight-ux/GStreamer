# GStreamer Build Instructions

## Setting up your build environment

### Setting up on Windows

1. Install Visual Studio 2019 (Free Community Edition works fine). Remember to select the C++ packages.
2. Install Chocolatey (https://chocolatey.org).
3. Run the following from command line: 

```
choco install cmake meson ninja python3
```

### Setting up on macOS

1. Install Xcode Command Line Tools (or the full Xcode package).
2. Download the macOS 10.13 Platform SDK from https://github.com/phracker/MacOSX-SDKs/releases and
   extract it to `/Library/Developer/CommandLineTools/SDKs/MacOSX10.13.sdk`.
3. Install Homebrew (https://brew.sh/)
4. Run the following from the Terminal to setup the needed homebrew packages:

```
brew install cmake meson ninja pcre bison python3
```

You may need to export the bison path to your bash_profile to make it the first entry in PATH since macOS already provides its own copy of bison.

You can do this by adding the following line to your .bash_profile:

```
export PATH="/usr/local/opt/bison/bin:$PATH"
```


### Setting up on Linux 

To get everything on Linux, just type the following:
 
```
sudo apt install cmake meson ninja-build pcre bison
```

## Building from source

### Build FFmpeg first

You'll first need a built copy of FFmpeg to enable the libav plugin in GStreamer.

Once you've built FFmpeg for your platform, copy the built output (the contents of the `out` dir) to `deps/ffmpeg` (relative to this folder).

You can change the path to your built copy of FFmpeg by passing `-DFFMPEG_INSTALL_PATH="your/ffmpeg/path/here"` to CMake on the command line.
 
### Building on Windows

At present, to build with Visual Studio, you need to run cmake from inside the
VS 2019 command prompt. Press `Start`, and search for `VS 2019`, and click on
`x64 Native Tools Command Prompt for VS 2019`, or a prompt named similar to
that.

Then, from the `x64 Native Tools Command Prompt for VS 2019`, change directories to this folder and run the following:

```
mkdir build
cd build
cmake .. -GNinja
ninja
ninja install
```

### Building on macOS and Linux

To build for macOS/Linux:

```
mkdir build
cd build
cmake .. -GNinja
ninja
ninja install
```

## Build products

Build products will be in `<build_dir>/out`.
