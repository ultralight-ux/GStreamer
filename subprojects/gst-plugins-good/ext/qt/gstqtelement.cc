/*
 * GStreamer
 * Copyright (C) 2015 Matthew Waters <matthew@centricular.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "gstqtelements.h"
#include "qtitem.h"
#include <QtQml/QQmlApplicationEngine>

void
qt5_element_init (GstPlugin * plugin)
{
  static gsize res = FALSE;
  if (g_once_init_enter (&res)) {
    /* this means the plugin must be loaded before the qml engine is loaded */
    qmlRegisterType<QtGLVideoItem> ("org.freedesktop.gstreamer.GLVideoItem", 1, 0, "GstGLVideoItem");
    g_once_init_leave (&res, TRUE);
  }
}
