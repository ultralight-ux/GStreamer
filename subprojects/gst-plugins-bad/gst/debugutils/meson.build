debugutilsbad_sources = [
  'debugutilsbad.c',
  'fpsdisplaysink.c',
  'gstchecksumsink.c',
  'gstchopmydata.c',
  'gstclockselect.c',
  'gstcompare.c',
  'gstdebugspy.c',
  'gsterrorignore.c',
  'gstfakeaudiosink.c',
  'gstfakevideosink.c',
  'gsttestsrcbin.c',
  'gstvideocodectestsink.c',
  'gstwatchdog.c',
]

gstdebugutilsbad = library('gstdebugutilsbad',
  debugutilsbad_sources,
  c_args : gst_plugins_bad_args,
  include_directories : [configinc],
  dependencies : [gstbase_dep, gstvideo_dep, gstnet_dep, gstaudio_dep, gio_dep],
  install : true,
  install_dir : plugins_install_dir,
)
pkgconfig.generate(gstdebugutilsbad, install_dir : plugins_pkgconfig_install_dir)
plugins += [gstdebugutilsbad]
