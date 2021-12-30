project('FFmpeg', 'c', version : '4.4.0')

ffmpeg_path = get_option('installpath')
ffmpeg_include_path = ffmpeg_path / 'include'

dir_base = meson.current_source_dir()
ffmpeg_lib_path = join_paths(join_paths(dir_base, ffmpeg_path), 'lib')

ffmpeg_inc = [
  include_directories(
    ffmpeg_include_path
  )
]

if host_machine.system() == 'windows'
  libavcodec_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_path, '-llibavcodec', '-llibswresample'],
    include_directories : ffmpeg_inc,
    version : '58.134.100')

  libavformat_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_path, '-llibavformat', '-lSecur32', '-lMfplat', '-lMfuuid'],
    include_directories : ffmpeg_inc,
    version : '58.76.100')

  libavfilter_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_path, '-llibavfilter', '-llibswscale'],
    include_directories : ffmpeg_inc,
    version : '7.110.100')

  libavutil_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_path, '-llibavutil', '-lBcrypt'],
    include_directories : ffmpeg_inc,
    version : '56.70.100')
else

  if host_machine.system() == 'darwin'
    libavcodec_dep = declare_dependency(
      link_args : ['-L' + ffmpeg_lib_path, '-lavcodec', '-lswresample', '-liconv'],
      include_directories : ffmpeg_inc,
      version : '58.134.100')
  else
    libavcodec_dep = declare_dependency(
      link_args : ['-L' + ffmpeg_lib_path, '-lavcodec', '-lswresample'],
      include_directories : ffmpeg_inc,
      version : '58.134.100')
  endif

  libavformat_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_path, '-lavformat'],
    include_directories : ffmpeg_inc,
    version : '58.76.100')

  libavfilter_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_path, '-lavfilter', '-lswscale'],
    include_directories : ffmpeg_inc,
    version : '7.110.100')

  libavutil_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_path, '-lavutil'],
    include_directories : ffmpeg_inc,
    version : '56.70.100')
endif

meson.override_dependency('libavcodec', libavcodec_dep)

meson.override_dependency('libavformat', libavformat_dep)

meson.override_dependency('libavfilter', libavfilter_dep)

meson.override_dependency('libavutil', libavutil_dep)
