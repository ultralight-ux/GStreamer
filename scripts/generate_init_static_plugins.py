#!/usr/bin/env python3

import argparse
import os
from string import Template

TEMPLATE = Template('''
#ifndef BUILDING_GST
#define BUILDING_GST 1
#endif

#ifndef GST_API_EXPORT
#if defined(_MSC_VER)
# define GST_API_EXPORT __declspec(dllexport) extern
#else
# if defined(__GNUC__) || (defined(__SUNPRO_C) && (__SUNPRO_C >= 0x590))
#  define GST_API_EXPORT extern __attribute__ ((visibility ("default")))
# else
#  define GST_API_EXPORT extern
# endif
#endif
#endif

#include <gst/gst.h>

$elements_declaration
$typefind_funcs_declaration
$device_providers_declaration
$dynamic_types_declaration
$plugins_declaration

GST_API void
gst_init_static_plugins (void)
{
  static gsize initialization_value = 0;
  if (g_once_init_enter (&initialization_value)) {
    $elements_registration
    $typefind_funcs_registration
    $device_providers_registration
    $dynamic_types_registration
    $plugins_registration

    g_once_init_leave (&initialization_value, 1);
  }
}
''')
# Retrieve the plugin name as it can be a plugin filename
def get_plugin_name(name):
    for p in plugins:
        if name in p:
            return p
    return ''

def process_features(features_list, plugins, feature_prefix):
    plugins_list = plugins
    feature_declaration = []
    feature_registration = []
    if features_list is not None:
        feature_plugins =  features_list.split(';')
        for plugin in feature_plugins:
            split = plugin.split(':')
            plugin_name = split[0].strip()
            if len(split) == 2:
                if (get_plugin_name(plugin_name)) != '':
                    plugins_list.remove(get_plugin_name(plugin_name))
                features = split[1].split(',')
                for feature in features:
                    feature = feature.replace("-", "_")
                    feature_declaration += ['%s_REGISTER_DECLARE(%s);' % (feature_prefix, feature)]
                    feature_registration += ['%s_REGISTER(%s, NULL);' % (feature_prefix, feature)]
    return (plugins_list, feature_declaration, feature_registration)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', dest="output", help="Output file")
    parser.add_argument('-p','--plugins', nargs='?', default='', dest="plugins", help="The list of plugins")
    parser.add_argument('-e', '--elements', nargs='?', default='', dest="elements", help="The list of plugin:elements")
    parser.add_argument('-t', '--type-finds', nargs='?', default='', dest="typefindfuncs", help="The list of plugin:typefinds")
    parser.add_argument('-d', '--devide-providers', nargs='?', default='', dest="deviceproviders", help="The list of plugin:deviceproviders")
    parser.add_argument('-T', '--dynamic-types', nargs='?', default='', dest="dynamictypes", help="The list of plugin:dynamictypes")
    options = parser.parse_args()
    if options.output is None:
        output_file = 'gstinitstaticplugins.c'
    else:
        output_file = options.output
    enable_staticelements_plugin = 0;
    elements_declaration = []
    elements_registration = []
    typefind_funcs_declaration = []
    typefind_funcs_registration = []
    device_providers_declaration = []
    device_providers_registration = []
    dynamic_types_declaration = []
    dynamic_types_registration = []
    plugins_declaration = []
    plugins_registration = []

    if options.plugins is None or options.plugins.isspace():
        plugins = []
    else:
        plugins = options.plugins.split(';')

    # process the features
    (plugins, elements_declaration, elements_registration) = process_features(options.elements, plugins, 'GST_ELEMENT')
    (plugins, typefind_funcs_declaration, typefind_funcs_registration) = process_features(options.typefindfuncs, plugins, 'GST_TYPE_FIND')
    (plugins, device_providers_declaration, device_providers_registration) = process_features(options.deviceproviders, plugins, 'GST_DEVICE_PROVIDER')
    (plugins, dynamic_types_declaration, dynamic_types_registration) = process_features(options.dynamictypes, plugins, 'GST_DYNAMIC_TYPE')

    # Enable plugin or elements according to the ';' separated list.
    for plugin in plugins:
        split = plugin.split(':')
        plugin_name = split[0]
        if plugin_name == '':
          continue
        filename = os.path.basename(plugin)
        if filename.startswith('libgst') and filename.endswith('.a'):
            plugin_name = filename[len('libgst'):-len('.a')]
        plugins_registration += ['GST_PLUGIN_STATIC_REGISTER(%s);' % (plugin_name)]
        plugins_declaration += ['GST_PLUGIN_STATIC_DECLARE(%s);' % (plugin_name)]

    with open(output_file.strip(), "w") as f:
        static_elements_plugin = ''
        f.write(TEMPLATE.substitute({
            'elements_declaration': '\n'.join(elements_declaration),
            'elements_registration': '\n    '.join(elements_registration),
            'typefind_funcs_declaration': '\n'.join(typefind_funcs_declaration),
            'typefind_funcs_registration': '\n    '.join(typefind_funcs_registration),
            'device_providers_declaration': '\n'.join(device_providers_declaration),
            'device_providers_registration': '\n    '.join(device_providers_registration),
            'dynamic_types_declaration': '\n'.join(dynamic_types_declaration),
            'dynamic_types_registration': '\n    '.join(dynamic_types_registration),
            'plugins_declaration': '\n'.join(plugins_declaration),
            'plugins_registration': '\n    '.join(plugins_registration),
            }))
