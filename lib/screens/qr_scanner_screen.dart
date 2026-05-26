import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
      final db = FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: 'default');
      final doc = await db.collection('artifacts').doc(code).get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        final artifact = Artifact(
          id: doc.id,
          name: (data['name'] ?? data['Name'] ?? '').toString().trim(),
          period: (data['period'] ?? '').toString().trim(),
          section: (data['section'] ?? '').toString().trim(),
          description: (data['description'] ?? '').toString().trim(),
          details: (data['details'] ?? '').toString().trim(),
          imageUrl: (data['imageUrl'] ?? '').toString().trim(),
          modelUrl: data['modelUrl']?.toString().trim(),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
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
        ],
      ),
    );
  }
}