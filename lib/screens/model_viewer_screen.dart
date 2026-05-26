import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/artifact.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'model_viewer_web.dart' if (dart.library.io) 'model_viewer_stub.dart';

class ModelViewerScreen extends StatefulWidget {
  final Artifact artifact;
  const ModelViewerScreen({super.key, required this.artifact});
  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (url) => setState(() => _isLoading = false),
        ))
        ..loadRequest(Uri.parse(widget.artifact.modelUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1208),
      appBar: AppBar(
        title: Text(widget.artifact.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C1810),
        foregroundColor: const Color(0xFFC9A84C),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF1C1208),
              child: kIsWeb
                  ? buildWebView(widget.artifact.modelUrl!, widget.artifact.id)
                  : Stack(
                      children: [
                        WebViewWidget(controller: _webViewController!),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFC9A84C)),
                          ),
                      ],
                    ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2C1810),
              border: Border(
                  top: BorderSide(color: Color(0xFFC9A84C), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.artifact.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC9A84C))),
                const SizedBox(height: 4),
                Text(widget.artifact.period,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(widget.artifact.description,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
