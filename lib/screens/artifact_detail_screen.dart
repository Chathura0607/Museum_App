import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact.dart';
import '../generated/app_localizations.dart';
import '../data/favorites_manager.dart';
import 'feedback_screen.dart';
import 'model_viewer_screen.dart';
import 'model_viewer_web.dart' if (dart.library.io) 'model_viewer_stub.dart';

class ArtifactDetailScreen extends StatefulWidget {
  final Artifact artifact;
  const ArtifactDetailScreen({super.key, required this.artifact});

  @override
  State<ArtifactDetailScreen> createState() => _ArtifactDetailScreenState();
}

class _ArtifactDetailScreenState extends State<ArtifactDetailScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setErrorHandler((msg) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _tts.stop();
    super.dispose();
  }

  String _getDisplayName(AppLocalizations l10n) {
    final isSinhala = l10n.localeName == 'si';
    if (isSinhala && (widget.artifact.nameSi?.isNotEmpty ?? false)) {
      return widget.artifact.nameSi!;
    }
    return widget.artifact.name;
  }

  String _getDisplayText(AppLocalizations l10n) {
    final isSinhala = l10n.localeName == 'si';
    if (isSinhala) {
      if (widget.artifact.detailsSi != null && widget.artifact.detailsSi!.isNotEmpty) {
        return widget.artifact.detailsSi!;
      }
      if (widget.artifact.descriptionSi != null && widget.artifact.descriptionSi!.isNotEmpty) {
        return widget.artifact.descriptionSi!;
      }
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
          if (voices is List && !voices.any((v) => v['locale']?.toString().contains(locale) ?? false)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio narration unavailable for this browser voice.')),
              );
            }
            return;
          }
        }
        await _tts.setLanguage(locale == 'si' ? 'si-LK' : 'en-US');
        await _tts.setSpeechRate(0.48);
        if (mounted) setState(() => _isSpeaking = true);
        await _tts.speak('${_getDisplayName(l10n)}. ${_getDisplayText(l10n)}');
      } catch (e) {
        if (mounted) setState(() => _isSpeaking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF2C1810),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesManager.instance.favoriteIdsNotifier,
                builder: (context, favorites, _) {
                  final isFav = favorites.contains(widget.artifact.id);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () {
                          FavoritesManager.instance.toggleFavorite(widget.artifact.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                isFav ? l10n.removeFromFavorites : l10n.addToFavorites,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'artifact-${widget.artifact.id}',
                    child: Image.network(
                      widget.artifact.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: const Color(0xFF2C1810),
                        child: const Icon(Icons.museum_rounded, size: 80, color: Color(0xFFC9A84C)),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Audio Button Row
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
                                  _getDisplayName(l10n).toUpperCase(),
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        height: 1.1,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    widget.artifact.period,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFC9A84C),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _toggleSpeech(l10n),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: _isSpeaking ? const Color(0xFFC9A84C) : const Color(0xFF2C1810),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC9A84C).withValues(alpha: _isSpeaking ? 0.4 : 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                                  color: _isSpeaking ? const Color(0xFF2C1810) : const Color(0xFFC9A84C),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isSpeaking ? l10n.stop : l10n.listen,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                    color: _isSpeaking ? const Color(0xFF2C1810) : const Color(0xFFC9A84C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildInfoChip(Icons.museum_rounded, widget.artifact.section),
                          if (widget.artifact.location?.isNotEmpty ?? false) ...[
                            const SizedBox(width: 8),
                            _buildInfoChip(Icons.location_on_rounded, widget.artifact.location!),
                          ],
                          if (widget.artifact.year?.isNotEmpty ?? false) ...[
                            const SizedBox(width: 8),
                            _buildInfoChip(Icons.calendar_today_rounded, widget.artifact.year!),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Description
                    Text(
                      l10n.aboutArtifact.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getDisplayText(l10n),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
                    ),
                    // 3D Experience Button
                    if (widget.artifact.modelUrl?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2C1810), Color(0xFF4A2B1E)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2C1810).withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => ModelViewerScreen(artifact: widget.artifact),
                            ),
                          ),
                          icon: const Icon(Icons.view_in_ar_rounded, size: 24, color: Color(0xFFC9A84C)),
                          label: Text(
                            l10n.view3D.toUpperCase(),
                            style: const TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFC9A84C),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                    // Guide Video Button
                    if (widget.artifact.videoUrl?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 40),
                      Text(
                        'GUIDE VIDEO',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => VideoPlayerPage(url: widget.artifact.videoUrl!)),
                        ),
                        child: Container(
                          height: 190,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: NetworkImage(widget.artifact.imageUrl),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.play_circle_fill_rounded, size: 68, color: Color(0xFFC9A84C)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    // Related Exhibits Section
                    _buildRelatedSection(l10n),
                    const SizedBox(height: 36),
                    // Feedback CTA
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => FeedbackScreen(artifact: widget.artifact)),
                        ),
                        icon: const Icon(Icons.rate_review_rounded, color: Color(0xFFC9A84C)),
                        label: Text(
                          l10n.feedbackTitle.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
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

  Widget _buildRelatedSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.relatedExhibits.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('artifacts')
              .where('section', isEqualTo: widget.artifact.section)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final items = snapshot.data!.docs
                .map((d) => Artifact.fromFirestore(d))
                .where((a) => a.id != widget.artifact.id)
                .toList();

            if (items.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSi = l10n.localeName == 'si';
                  final title = isSi && (item.nameSi?.isNotEmpty ?? false) ? item.nameSi! : item.name;

                  return GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ArtifactDetailScreen(artifact: item)),
                    ),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.brown.withValues(alpha: 0.15)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(color: Colors.grey.shade300),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.brown.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFC9A84C)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
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
  WebViewController? controller;
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Video'),
        backgroundColor: const Color(0xFF2C1810),
      ),
      body: kIsWeb
          ? buildWebView(widget.url, 'video-${widget.url.hashCode}')
          : WebViewWidget(controller: controller!),
    );
  }
}
