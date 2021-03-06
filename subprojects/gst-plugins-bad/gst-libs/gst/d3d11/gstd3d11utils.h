/* GStreamer
 * Copyright (C) 2020 Seungha Yang <seungha@centricular.com>
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

#ifndef __GST_D3D11_UTILS_H__
#define __GST_D3D11_UTILS_H__

#include <gst/gst.h>
#include <gst/d3d11/gstd3d11_fwd.h>

G_BEGIN_DECLS

GST_D3D11_API
gboolean        gst_d3d11_handle_set_context        (GstElement * element,
                                                     GstContext * context,
                                                     gint adapter,
                                                     GstD3D11Device ** device);

GST_D3D11_API
gboolean        gst_d3d11_handle_context_query      (GstElement * element,
                                                     GstQuery * query,
                                                     GstD3D11Device * device);

GST_D3D11_API
gboolean        gst_d3d11_ensure_element_data       (GstElement * element,
                                                     gint adapter,
                                                     GstD3D11Device ** device);

#ifndef GST_DISABLE_GST_DEBUG
GST_D3D11_API
gboolean       _gst_d3d11_result_dbg                (HRESULT hr,
                                                     GstD3D11Device * device,
                                                     GstDebugCategory * cat,
                                                     const gchar * file,
                                                     const gchar * function,
                                                     gint line);
#endif

GST_D3D11_API
gboolean       _gst_d3d11_result                    (HRESULT hr,
                                                     GstD3D11Device * device,
                                                     const gchar * file,
                                                     const gchar * function,
                                                     gint line);
/**
 * gst_d3d11_result:
 * @result: HRESULT D3D11 API return code
 * @device: (nullable): Associated #GstD3D11Device
 *
 * Returns: %TRUE if D3D11 API call result is SUCCESS
 *
 * Since: 1.20
 */
#ifndef GST_DISABLE_GST_DEBUG
#define gst_d3d11_result(result,device) \
    _gst_d3d11_result_dbg (result, device, GST_CAT_DEFAULT, __FILE__, GST_FUNCTION, __LINE__)
#else
#define gst_d3d11_result(result,device) \
    _gst_d3d11_result (result, device, __FILE__, GST_FUNCTION, __LINE__)
#endif

G_END_DECLS

#endif /* __GST_D3D11_UTILS_H__ */
