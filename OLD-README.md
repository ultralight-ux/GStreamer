# gst-build

GStreamer [meson](http://mesonbuild.com/) based repositories aggregrator.

Check out this module and run meson on it, and it will git clone the other
GStreamer modules as [meson subprojects](http://mesonbuild.com/Subprojects.html)
and build everything in one go. Once that is done you can switch into an
development environment which allows you to easily develop and test the latest
version of GStreamer without the need to install anything or touch an existing
GStreamer system installation.

## Getting started

### Install git and python 3.5+

If you're on Linux, you probably already have these. On macOS, you can use the
[official Python installer](https://www.python.org/downloads/mac-osx/).

You can find [instructions for Windows below](#windows-prerequisites-setup).

### Install meson and ninja

Meson 0.52 or newer is required.

For cross-compilation Meson 0.54 or newer is required.

On Linux and macOS you can get meson through your package manager or using:

  $ pip3 install --user meson

This will install meson into `~/.local/bin` which may or may not be included
automatically in your PATH by default.

You should get `ninja` using your package manager or download the [official
release](https://github.com/ninja-build/ninja/releases) and put the `ninja`
binary in your PATH.

You can find [instructions for Windows below](#windows-prerequisites-setup).

### Build GStreamer and its modules

You can get all GStreamer built running:

```
meson builddir
ninja -C builddir
```

This will automatically create the `build` directory and build everything
inside it.

NOTE: On Windows, you *must* run this from [inside the Visual Studio command
prompt](#running-meson-on-windows) of the appropriate architecture and version.

### External dependencies

All mandatory dependencies of GStreamer are included as [meson subprojects](https://mesonbuild.com/Subprojects.html):
libintl, zlib, libffi, glib. Some optional dependencies are also included as
subprojects, such as ffmpeg, x264, json-glib, graphene, openh264, orc, etc.

Mandatory dependencies will be automatically built if meson cannot find them on
your system using pkg-config. The same is true for optional dependencies that
are included as subprojects. You can find a full list by looking at the
`subprojects` directory.

Plugins that need optional dependencies that aren't included can only be built
if they are provided by the system. Instructions on how to build some common
ones such as Qt5/QML are listed below. If you do not know how to provide an
optional dependency needed by a plugin, you should use [Cerbero](https://gitlab.freedesktop.org/gstreamer/cerbero/#description)
which handles this for you automatically.

Plugins will be automatically enabled if possible, but you can ensure that
a particular plugin (especially if it has external dependencies) is built by
enabling the gstreamer repository that ships it and the plugin inside it. For
example, to enable the Qt5 plugin in the gst-plugins-good repository, you need
to run meson as follows:

```
meson -Dgood=enabled -Dgst-plugins-good:qt5=enabled builddir
```

This will cause Meson to error out if the plugin could not be enabled. You can
also flip the default and disable all plugins except those explicitly enabled
like so:

```
meson -Dauto_features=disabled -Dgstreamer:tools=enabled -Dbad=enabled -Dgst-plugins-bad:openh264=enabled
```

This will disable all optional features and then enable the `openh264` plugin
and the tools that ship with the core gstreamer repository: `gst-inspect-1.0`,
`gst-launch-1.0`, etc. As usual, you can change these values on a builddir that
has already been setup with `meson configure -Doption=value`.

### Building the Qt5 QML plugin

If `qmake` is not in `PATH` and pkgconfig files are not available, you can
point the `QMAKE` env var to the Qt5 installation of your choosing before
running `meson` as shown above.

The plugin will be automatically enabled if possible, but you can ensure that
it is built by passing `-Dgood=enabled -Dgst-plugins-good:qt5=enabled` to `meson`.

### Building the Intel MSDK plugin

On Linux, you need to have development files for `libmfx` installed. On
Windows, if you have the [Intel Media SDK](https://software.intel.com/en-us/media-sdk),
it will set the `INTELMEDIASDKROOT` environment variable, which will be used by
the build files to find `libmfx`.

The plugin will be automatically enabled if possible, but you can ensure it by
passing `-Dbad=enabled -Dgst-plugins-bad:msdk=enabled` to `meson`.

### Static build

Since *1.18.0* when doing a static build using `--default-library=static`, a
shared library `gstreamer-full-1.0` will be produced and includes all enabled
GStreamer plugins and libraries. A list of libraries that needs to be exposed in
`gstreamer-full-1.0` ABI can be set using `gst-full-libraries` option. glib-2.0,
gobject-2.0 and gstreamer-1.0 are always included.

```
meson --default-library=static -Dgst-full-libraries=app,video builddir
```

GStreamer *1.18* requires applications using gstreamer-full-1.0 to initialize
static plugins by calling `gst_init_static_plugins()` after `gst_init()`. That
function is defined in `gst/gstinitstaticplugins.h` header file.

Since *1.20.0* `gst_init_static_plugins()` is called automatically by
`gst_init()` and applications must not call it manually any more. The header
file has been removed from public API.

One can use the `gst-full-version-script` option to pass a
[version script](https://www.gnu.org/software/gnulib/manual/html_node/LD-Version-Scripts.html)
to the linker. This can be used to control the exact symbols that are exported by
the gstreamer-full library, allowing the linker to garbage collect unused code
and so reduce the total library size. A default script `gstreamer-full-default.map`
declares only glib/gstreamer symbols as public.

One can use the `gst-full-plugins` option to pass a list of plugins to be registered
in the gstreamer-full library. The default value is '*' which means that all the plugins selected
during the build process will be registered statically. An empty value will prevent any plugins to
be registered.

One can select a specific set of features with `gst-full-elements`, `gst-full-typefind-functions`, `gst-full-device-providers` or `gst-full-dynamic-types` to select specific feature from a plugin.
When a feature has been listed in one of those options, the other features from its plugin will no longer be automatically included, even if the plugin is listed in `gst-full-plugins`.

The user must insure that all selected plugins and features (element, typefind, etc.) have been
enabled during the build configuration.

To register features, the syntax is the following:
plugins are separated by ';' and features from a plugin starts after ':' and are ',' separated.

As an example:
 * `-Dgst-full-plugins=coreelements;playback;typefindfunctions;alsa;pbtypes`: enable only `coreelements`, `playback`, `typefindfunctions`, `alsa`, `pbtypes` plugins.
 * `-Dgst-full-elements=coreelements:filesrc,fakesink,identity;alsa:alsasrc`: enable only `filesrc`, `identity` and `fakesink` elements from `coreelements` and `alsasrc` element from `alsa` plugin.
 * `-Dgst-full-typefind-functions=typefindfunctions:wav,flv`: enable only typefind func `wav` and `flv` from `typefindfunctions`
 * `-Dgst-full-device-providers=alsa:alsadeviceprovider`: enable `alsadeviceprovider` from `alsa`.
 * `-Dgst-full-dynamic-types=pbtypes:video_multiview_flagset`:  enable `video_multiview_flagset` from `pbtypes

All features from the `playback` plugin will be enabled and the other plugins will be restricted to the specific features requested.

All the selected features will be registered into a dedicated `NULL` plugin name.

This will cause the features/plugins that are not registered to not be included in the final gstreamer-full library.

This is an experimental feature, backward uncompatible changes could still be
made in the future.

# Development environment

## Development environment target

gst-build also contains a special `devenv` target that lets you enter an
development environment where you will be able to work on GStreamer
easily. You can get into that environment running:

```
ninja -C builddir devenv
```

If your operating system handles symlinks, built modules source code will be
available at the root of `gst-build/` for example GStreamer core will be in
`gstreamer/`. Otherwise they will be present in `subprojects/`. You can simply
hack in there and to rebuild you just need to rerun `ninja -C builddir`.

NOTE: In the development environment, a fully usable prefix is also configured
in `gst-build/prefix` where you can install any extra dependency/project.

An external script can be run in development environment with:

```
./gst-env.py external_script.sh
```

## Update git subprojects

We added a special `update` target to update subprojects (it uses `git pull
--rebase` meaning you should always make sure the branches you work on are
following the right upstream branch, you can set it with `git branch
--set-upstream-to origin/master` if you are working on `gst-build` master
branch).

Update all GStreamer modules and rebuild:

```
ninja -C builddir update
```

Update all GStreamer modules without rebuilding:

```
ninja -C builddir git-update
```

## Custom subprojects

We also added a meson option, `custom_subprojects`, that allows the user
to provide a comma-separated list of subprojects that should be built
alongside the default ones.

To use it:

```
cd subprojects
git clone my_subproject
cd ../build
rm -rf * && meson .. -Dcustom_subprojects=my_subproject
ninja
```

## Run tests

You can easily run the test of all the components:

```
meson test -C build
```

To list all available tests:

```
meson test -C builddir --list
```

To run all the tests of a specific component:

```
meson test -C builddir --suite gst-plugins-base
```

Or to run a specific test file:

```
meson test -C builddir --suite gstreamer gst_gstbuffer
```

Run a specific test from a specific test file:

```
GST_CHECKS=test_subbuffer meson test -C builddir --suite gstreamer gst_gstbuffer
```

## Optional Installation

`gst-build` has been created primarily for [development usage](#development-environment-target),
but you can also install everything that is built into a predetermined prefix like so:

```
meson --prefix=/path/to/install/prefix builddir
ninja -C builddir
meson install -C builddir
```

Note that the installed files have `RPATH` stripped, so you will need to set
`LD_LIBRARY_PATH`, `DYLD_LIBRARY_PATH`, or `PATH` as appropriate for your
platform for things to work.

## Checkout another branch using worktrees

If you need to have several versions of GStreamer coexisting (eg. `master` and `1.16`),
you can use the `gst-worktree.py` script provided by `gst-build`. It allows you
to create a new `gst-build` environment with new checkout of all the GStreamer modules as
[git worktrees](https://git-scm.com/docs/git-worktree).

For example to get a fresh checkout of `gst-1.16` from a `gst-build` repository
that is checked out at master, you can run:

```
./gst-worktree.py add gst-build-1.16 origin/1.16
```

This will create a new ``gst-build-1.16`` directory pointing to the given branch `1.16`
for all the subprojects (gstreamer, gst-plugins-base, etc.)


## Add information about GStreamer development environment in your prompt line

### Bash prompt

We automatically handle `bash` and set `$PS1` accordingly.

If the automatic `$PS1` override is not desired (maybe you have a fancy custom prompt), set the `$GST_BUILD_DISABLE_PS1_OVERRIDE` environment variable to `TRUE` and use `$GST_ENV` when setting the custom prompt, for example with a snippet like the following:

```bash
...
if [[ -n "${GST_ENV-}" ]];
then
  PS1+="[ ${GST_ENV} ]"
fi
...
```

### Using powerline

In your powerline theme configuration file (by default in
`{POWERLINE INSTALLATION DIR}/config_files/themes/shell/default.json`)
you should add a new environment segment as follow:

```
{
  "function": "powerline.segments.common.env.environment",
  "args": { "variable": "GST_ENV" },
  "priority": 50
},
```

## Windows Prerequisites Setup

On Windows, some of the components may require special care.

### Git for Windows

Use the [Git for Windows](https://gitforwindows.org/) installer. It will
install a `bash` prompt with basic shell utils and up-to-date git binaries.

During installation, when prompted about `PATH`, you should select the
following option:

![Select "Git from the command line and also from 3rd-party software"](/data/images/git-installer-PATH.png)

### Python 3.5+ on Windows

Use the [official Python installer](https://www.python.org/downloads/windows/).
You must ensure that Python is installed into `PATH`:

![Enable Add Python to PATH, then click Customize Installation](/data/images/py-installer-page1.png)

You may also want to customize the installation and install it into
a system-wide location such as `C:\PythonXY`, but this is not required.

### Ninja on Windows

The easiest way to install Ninja on Windows is with `pip3`, which will download
the compiled binary and place it into the `Scripts` directory inside your
Python installation:

```
pip3 install ninja
```

You can also download the [official release](https://github.com/ninja-build/ninja/releases)
and place it into `PATH`.

### Meson on Windows

**IMPORTANT**: Do not use the Meson MSI installer since it is experimental and known to not
work with `gst-build`.

You can use `pip3` to install Meson, same as Ninja above:

```
pip3 install meson
```

Note that Meson is written entirely in Python, so you can also run it as-is
from the [git repository](https://github.com/mesonbuild/meson/) if you want to
use the latest master branch for some reason.

**ARM64 native only**: You might need
[native upstream ARM64 support fix](https://github.com/mesonbuild/meson/pull/7432)
which is expected to be a part of Meson 0.55.1.
If your Meson package version which was installed via `pip3` is lower than 0.55.1,
then you need to use [the latest master branch](https://github.com/mesonbuild/meson/).

### Running Meson on Windows

At present, to build with Visual Studio, you need to run Meson from inside the
VS 2019 command prompt. Press `Start`, and search for `VS 2019`, and click on
`x64 Native Tools Command Prompt for VS 2019`, or a prompt named similar to
that:

![x64 Native Tools Command Prompt for VS 2019](/data/images/vs-2019-dev-prompt.png)

**ARM64 native only**: Since Visual Studio might not install dedicated command
prompt for native ARM64 build, you might need to run `vcvarsx86_arm64.bat` on CMD.
Please refer to [this document](https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=vs-2019#developer_command_file_locations)

### Setup a mingw/wine based development environment on linux

#### Install wine and mingw

##### On fedora x64

``` sh
sudo dnf install mingw64-gcc mingw64-gcc-c++ mingw64-pkg-config mingw64-winpthreads wine
```

FIXME: Figure out what needs to be installed on other distros

#### Get meson from git

This simplifies the process and allows us to use the cross files
defined in meson itself.

``` sh
git clone https://github.com/mesonbuild/meson.git
```

#### Build and install

```
BUILDDIR=$PWD/winebuild/
export WINEPREFIX=$BUILDDIR/wine-prefix/ && mkdir -p $WINEPREFIX
# Setting the prefix is mandatory as it is used to setup symlinks during uninstalled development
meson/meson.py $BUILDDIR --cross-file meson/cross/linux-mingw-w64-64bit.txt -Dgst-plugins-bad:vulkan=disabled -Dorc:gtk_doc=disabled --prefix=$BUILDDIR/wininstall/ -Djson-glib:gtk_doc=disabled
meson/meson.py install -C $BUILDDIR/
```

> __NOTE__: You should use `meson install -C $BUILDDIR`  each time you make a change
> instead of the usual `ninja -C build` as the environment is not uninstalled.

#### The development environment

You can get into the development environment the usual way:

```
ninja -C $BUILDDIR/ devenv
```

Alternatively, if you'd rather not start a shell in your workflow, you
can mutate the current environment into a suitable state like so:

```
gst-env.py --only-environment
```

This will print output suitable for an sh-compatible `eval` function,
just like `ssh-agent -s`.

After setting up [binfmt] to use wine for windows binaries,
you can run GStreamer tools under wine by running:

```
gst-launch-1.0.exe videotestsrc ! glimagesink
```

[binfmt]: http://man7.org/linux/man-pages/man5/binfmt.d.5.html
