import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../generated/app_localizations.dart';
import '../models/artifact.dart';
import 'artifact_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final AppLocalizations l10n;
  const MapScreen({super.key, required this.l10n});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedSection;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String _getSectionIcon(String section) {
    final s = section.toLowerCase();
    if (s.contains('egypt')) return '☥';
    if (s.contains('roman')) return '⚔️';
    if (s.contains('china')) return '🏮';
    if (s.contains('greece') || s.contains('greek')) return '🏛️';
    if (s.contains('viking')) return '🛡️';
    if (s.contains('sri lanka')) return '🪷';
    if (s.contains('modern')) return '🚀';
    return '🖼️';
  }

  Color _getSectionColor(String section) {
    final s = section.toLowerCase();
    if (s.contains('egypt')) return Colors.orange.shade800;
    if (s.contains('roman')) return Colors.red.shade800;
    if (s.contains('china')) return Colors.deepOrange.shade700;
    if (s.contains('greece') || s.contains('greek')) return Colors.blue.shade800;
    if (s.contains('viking')) return Colors.blueGrey.shade800;
    if (s.contains('sri lanka')) return Colors.teal.shade800;
    if (s.contains('modern')) return Colors.indigo.shade700;
    return const Color(0xFF2C1810);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFCFAF7),
      appBar: AppBar(
        title: Text(widget.l10n.museumMap, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('artifacts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(widget.l10n.noArtifacts));
          }

          final allArtifacts = snapshot.data!.docs
              .map((doc) => Artifact.fromFirestore(doc))
              .toList();

          final sections = allArtifacts.map((a) => a.section).toSet().toList();
          sections.sort();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover the Galleries',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Navigate historical wings, time periods, and featured exhibits.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == sections.length) return _buildEndOfPath();
                      return _buildRoomCard(sections[index], allArtifacts);
                    },
                    childCount: sections.length + 1,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEndOfPath() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 48),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFC9A84C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.meeting_room_rounded, color: Color(0xFFC9A84C), size: 32),
          SizedBox(height: 12),
          Text(
            'GRAND EXHIBITION CORRIDOR',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 2,
              color: Color(0xFFC9A84C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(String section, List<Artifact> allArtifacts) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedSection == section;
    final color = _getSectionColor(section);
    final roomArtifacts = allArtifacts.where((a) => a.section == section).toList();
    final isSi = widget.l10n.localeName == 'si';

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedSection = isSelected ? null : section),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? const Color(0xFFC9A84C) : (isDark ? Colors.white10 : Colors.brown.shade50),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFFC9A84C).withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(_getSectionIcon(section), style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${roomArtifacts.length} Historical Artifacts',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFC9A84C),
                ),
              ],
            ),
          ),
        ),
        if (isSelected)
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.brown.shade50),
              ),
              child: Column(
                children: roomArtifacts.asMap().entries.map((entry) {
                  final artifact = entry.value;
                  final isLast = entry.key == roomArtifacts.length - 1;
                  final displayName = isSi && (artifact.nameSi?.isNotEmpty ?? false)
                      ? artifact.nameSi!
                      : artifact.name;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            artifact.imageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 44,
                              height: 44,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.museum_rounded, size: 20),
                            ),
                          ),
                        ),
                        title: Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        subtitle: Text(
                          artifact.period,
                          style: const TextStyle(fontSize: 11, color: Color(0xFFC9A84C), fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFC9A84C)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ArtifactDetailScreen(artifact: artifact)),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          indent: 72,
                          endIndent: 20,
                          height: 1,
                          color: isDark ? Colors.white10 : Colors.brown.shade50,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
