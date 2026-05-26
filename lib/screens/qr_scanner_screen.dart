import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../generated/app_localizations.dart';
import '../models/artifact.dart';
import 'artifact_detail_screen.dart';
import 'model_viewer_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final AppLocalizations l10n;
  const QrScannerScreen({super.key, required this.l10n});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _scanned = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null) return;
    final code = barcode.rawValue;
    if (code == null) return;

    setState(() {
      _scanned = true;
      _loading = true;
    });
    _controller?.stop();

    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection('artifacts').doc(code).get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        final artifact = Artifact(
          id: doc.id,
          name: (data['name'] ?? '').toString(),
          period: (data['period'] ?? '').toString(),
          section: (data['section'] ?? '').toString(),
          description: (data['description'] ?? '').toString(),
          details: (data['details'] ?? '').toString(),
          imageUrl: (data['imageUrl'] ?? '').toString(),
          modelUrl: data['modelUrl']?.toString(),
        );

        setState(() => _loading = false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => artifact.modelUrl != null &&
                artifact.modelUrl!.isNotEmpty
                ? ModelViewerScreen(artifact: artifact)
                : ArtifactDetailScreen(artifact: artifact),
          ),
        ).then((_) {
          _controller?.start();
          setState(() => _scanned = false);
        });
      } else {
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artifact not found: $code'),
            backgroundColor: Colors.red,
          ),
        );
        _controller?.start();
        setState(() => _scanned = false);
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _controller?.start();
      setState(() => _scanned = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.l10n.scanTitle),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      'Loading artifact...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.l10n.scanPrompt,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          if (kIsWeb)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt, size: 64, color: Color(0xFF2C1810)),
                      const SizedBox(height: 16),
                      const Text(
                        'Scanner on Web',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Browsers often block camera access on localhost. You can manually enter an artifact ID for testing:',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter ID (e.g. artifact_001)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (val) {
                          if (val.isNotEmpty) {
                            _onDetect(BarcodeCapture(barcodes: [Barcode(rawValue: val)]));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
