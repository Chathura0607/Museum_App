// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/widgets.dart';

Widget buildWebView(String url, String id) {
  final viewId = 'sketchfab-$id';
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
        (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      return iframe;
    },
  );
  return HtmlElementView(viewType: viewId);
}