project('FFmpeg', 'c', version : '4.4.0')

ffmpeg_dir = meson.current_source_dir() / '../../deps/ffmpeg'

ffmpeg_lib_dir = ffmpeg_dir / 'lib'

ffmpeg_inc = [
  include_directories(
    '../../deps/ffmpeg/include'
  )
]

if host_machine.system() == 'windows'
  libavcodec_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_dir, '-llibavcodec', '-llibswresample'],
    include_directories : ffmpeg_inc,
    version : '58.134.100')

  libavformat_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_dir, '-llibavformat', '-lSecur32', '-lMfplat', '-lMfuuid'],
    include_directories : ffmpeg_inc,
    version : '58.76.100')

  libavfilter_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_dir, '-llibavfilter', '-llibswscale'],
    include_directories : ffmpeg_inc,
    version : '7.110.100')

  libavutil_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_dir, '-llibavutil', '-lBcrypt'],
    include_directories : ffmpeg_inc,
    version : '56.70.100')
else
  libavcodec_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_dir, '-lavcodec', '-lswresample', '-liconv'],
    include_directories : ffmpeg_inc,
    version : '58.134.100')

  libavformat_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_dir, '-lavformat'],
    include_directories : ffmpeg_inc,
    version : '58.76.100')

  libavfilter_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_dir, '-lavfilter', '-lswscale'],
    include_directories : ffmpeg_inc,
    version : '7.110.100')

  libavutil_dep = declare_dependency(
    link_args : ['-L' + ffmpeg_lib_dir, '-lavutil'],
    include_directories : ffmpeg_inc,
    version : '56.70.100')
endif

meson.override_dependency('libavcodec', libavcodec_dep)

meson.override_dependency('libavformat', libavformat_dep)

meson.override_dependency('libavfilter', libavfilter_dep)

meson.override_dependency('libavutil', libavutil_dep)