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
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
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
    final code = barcode.rawValue?.trim();
    if (code == null || code.isEmpty) return;

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
        final artifact = Artifact.fromFirestore(doc);

        setState(() => _loading = false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => (artifact.modelUrl != null && artifact.modelUrl!.isNotEmpty)
                ? ModelViewerScreen(artifact: artifact)
                : ArtifactDetailScreen(artifact: artifact),
          ),
        ).then((_) {
          if (mounted) {
            _controller?.start();
            setState(() => _scanned = false);
          }
        });
      } else {
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exhibit pass / QR not recognized: $code'),
            backgroundColor: Colors.redAccent,
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
          content: Text('Error reading artifact data: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      _controller?.start();
      setState(() => _scanned = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.l10n.scanTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF2C1810),
        foregroundColor: const Color(0xFFC9A84C),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: const Color(0xFFC9A84C)),
            onPressed: () {
              _controller?.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
          ),
          // Viewfinder Overlay
          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC9A84C), width: 3),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC9A84C).withValues(alpha: 0.25),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12, left: 12,
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFC9A84C), width: 4), left: BorderSide(color: Color(0xFFC9A84C), width: 4)))),
                  ),
                  Positioned(
                    top: 12, right: 12,
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFC9A84C), width: 4), right: BorderSide(color: Color(0xFFC9A84C), width: 4)))),
                  ),
                  Positioned(
                    bottom: 12, left: 12,
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFC9A84C), width: 4), left: BorderSide(color: Color(0xFFC9A84C), width: 4)))),
                  ),
                  Positioned(
                    bottom: 12, right: 12,
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFC9A84C), width: 4), right: BorderSide(color: Color(0xFFC9A84C), width: 4)))),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFC9A84C)),
                    SizedBox(height: 16),
                    Text(
                      'Unveiling artifact records...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.4)),
                ),
                child: Text(
                  widget.l10n.scanPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          if (kIsWeb)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, size: 56, color: Color(0xFF2C1810)),
                      const SizedBox(height: 16),
                      const Text(
                        'Direct Exhibit Test',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter an artifact ID directly for quick simulation:',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'e.g. artifact_001, artifact_002',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
