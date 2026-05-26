// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/widgets.dart';

// Keep track of registered factories to avoid duplicate registration errors
final Set<String> _registeredViewIds = {};

Widget buildWebView(String url, String id) {
  final viewId = 'sketchfab-$id';
  
  if (!_registeredViewIds.contains(viewId)) {
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
    _registeredViewIds.add(viewId);
  }

  return HtmlElementView(viewType: viewId);
}
