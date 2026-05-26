import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/artifact.dart';
import '../generated/app_localizations.dart';

class ArtifactDetailScreen extends StatefulWidget {
  final Artifact artifact;
  const ArtifactDetailScreen({super.key, required this.artifact});

  @override
  State<ArtifactDetailScreen> createState() => _ArtifactDetailScreenState();
}

class _ArtifactDetailScreenState extends State<ArtifactDetailScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String _getDisplayText(AppLocalizations l10n) {
    final isSinhala = l10n.localeName == 'si';
    if (isSinhala) {
      final siDetails = widget.artifact.detailsSi ?? '';
      final siDesc = widget.artifact.descriptionSi ?? '';
      if (siDetails.isNotEmpty) return siDetails;
      if (siDesc.isNotEmpty) return siDesc;
    }
    return widget.artifact.details.isNotEmpty
        ? widget.artifact.details
        : widget.artifact.description;
  }

  Future<void> _toggleSpeech(AppLocalizations l10n) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      final locale = l10n.localeName;
      final text =
          '${widget.artifact.name}. ${widget.artifact.period}. '
          '${_getDisplayText(l10n)}';
      await _tts.setLanguage(locale == 'si' ? 'si-LK' : 'en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.speak(text);
      setState(() => _isSpeaking = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.artifact.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
              background: Image.network(
                widget.artifact.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.brown[200],
                  child: const Icon(Icons.image_not_supported,
                      size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      widget.artifact.period,
                      style: TextStyle(
                        color: Colors.amber[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      widget.artifact.section,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.aboutArtifact,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _toggleSpeech(l10n),
                        icon: Icon(
                          _isSpeaking ? Icons.stop : Icons.volume_up,
                          size: 20,
                        ),
                        label: Text(_isSpeaking ? l10n.stop : l10n.listen),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSpeaking
                              ? Colors.red[700]
                              : Colors.brown[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getDisplayText(l10n),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
