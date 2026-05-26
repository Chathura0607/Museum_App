import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/artifact.dart';
import '../generated/app_localizations.dart';
import 'feedback_screen.dart';
import 'model_viewer_screen.dart';

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
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String _getDisplayText(AppLocalizations l10n) {
    final isSinhala = l10n.localeName == 'si';
    if (isSinhala) {
      return (widget.artifact.detailsSi ?? widget.artifact.descriptionSi ?? '').isNotEmpty 
          ? (widget.artifact.detailsSi ?? widget.artifact.descriptionSi!) 
          : widget.artifact.details;
    }
    return widget.artifact.details.isNotEmpty ? widget.artifact.details : widget.artifact.description;
  }

  Future<void> _toggleSpeech(AppLocalizations l10n) async {
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      try {
        final locale = l10n.localeName;
        if (kIsWeb) {
          final voices = await _tts.getVoices;
          if (!voices.any((v) => v['locale'].toString().contains(locale))) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio not supported for this language.')));
            return;
          }
        }
        await _tts.setLanguage(locale == 'si' ? 'si-LK' : 'en-US');
        await _tts.setSpeechRate(0.5);
        if (mounted) setState(() => _isSpeaking = true);
        await _tts.speak('${widget.artifact.name}. ${_getDisplayText(l10n)}');
      } catch (e) {
        if (mounted) setState(() => _isSpeaking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF2C1810),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Hero(
                tag: 'artifact-${widget.artifact.id}',
                child: Image.network(
                  widget.artifact.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.brown.shade100, child: const Icon(Icons.broken_image, size: 80)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFCFAF7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(offset: Offset(-20 * (1 - value), 0), child: child),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.localeName == 'si' && widget.artifact.nameSi != null 
                                    ? widget.artifact.nameSi! 
                                    : widget.artifact.name, 
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)
                                ),
                                const SizedBox(height: 8),
                                Text(widget.artifact.period, style: const TextStyle(fontSize: 18, color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () => _toggleSpeech(l10n),
                          icon: Icon(_isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded, color: const Color(0xFFC9A84C)),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFF2C1810), padding: const EdgeInsets.all(12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildInfoChip(Icons.museum_rounded, widget.artifact.section),
                                if (widget.artifact.location?.isNotEmpty ?? false) ...[const SizedBox(width: 8), _buildInfoChip(Icons.location_on_rounded, widget.artifact.location!)],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(l10n.aboutArtifact, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 16),
                          Text(_getDisplayText(l10n), style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                    if (widget.artifact.modelUrl?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => ModelViewerScreen(artifact: widget.artifact),
                          ),
                        ),
                        icon: const Icon(Icons.view_in_ar_rounded),
                        label: const Text('EXPERIENCE IN 3D'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A84C),
                          foregroundColor: const Color(0xFF2C1810),
                        ),
                      ),
                    ],
                    if (widget.artifact.videoUrl?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 40),
                      const Text('Discovery Video', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => VideoPlayerPage(url: widget.artifact.videoUrl!))),
                        child: Container(
                          height: 180, width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(image: NetworkImage(widget.artifact.imageUrl), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)),
                          ),
                          child: const Center(child: Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => FeedbackScreen(artifact: widget.artifact))),
                      icon: const Icon(Icons.rate_review_rounded),
                      label: const Text('SHARE YOUR THOUGHTS'),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.brown.shade50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.brown),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String url;
  const VideoPlayerPage({super.key, required this.url});
  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)..loadRequest(Uri.parse(widget.url));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guide Video')),
      body: WebViewWidget(controller: controller),
    );
  }
}
