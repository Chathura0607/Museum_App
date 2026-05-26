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
    if (s.contains('viking')) return '🛡️';
    if (s.contains('sri lanka')) return '🏛️';
    return '🖼️';
  }

  Color _getSectionColor(String section) {
    final s = section.toLowerCase();
    if (s.contains('egypt')) return Colors.orange.shade700;
    if (s.contains('roman')) return Colors.red.shade700;
    if (s.contains('china')) return Colors.redAccent.shade700;
    if (s.contains('viking')) return Colors.blueGrey.shade700;
    if (s.contains('sri lanka')) return Colors.green.shade700;
    return Colors.brown.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        title: const Text('Museum Map', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('artifacts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final allDocs = snapshot.data!.docs;
          final sections = allDocs.map((doc) => doc['section'].toString()).toSet().toList();
          sections.sort();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discover the Galleries', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text('Navigate through our historic wings and time periods.', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == sections.length) return _buildEndOfPath();
                      return _buildRoomCard(sections[index], allDocs);
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
      decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.brown.shade100)),
      child: Column(
        children: [
          const Icon(Icons.meeting_room_rounded, color: Colors.brown),
          const SizedBox(height: 12),
          Text('END OF EXPLORATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5, color: Colors.brown.shade700)),
        ],
      ),
    );
  }

  Widget _buildRoomCard(String section, List<QueryDocumentSnapshot> allDocs) {
    final isSelected = _selectedSection == section;
    final color = _getSectionColor(section);
    final roomArtifacts = allDocs.where((doc) => doc['section'] == section).toList();

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedSection = isSelected ? null : section),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: isSelected ? color.withOpacity(0.1) : Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: Text(_getSectionIcon(section), style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('${roomArtifacts.length} Historical Artifacts', style: TextStyle(color: Colors.black45, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(isSelected ? Icons.unfold_less_rounded : Icons.unfold_more_rounded, color: Colors.black26),
              ],
            ),
          ),
        ),
        if (isSelected)
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.brown.shade50)),
              child: Column(
                children: roomArtifacts.asMap().entries.map((entry) {
                  final data = entry.value.data() as Map<String, dynamic>;
                  final isLast = entry.key == roomArtifacts.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtifactDetailScreen(artifact: _docToArtifact(entry.value)))),
                      ),
                      if (!isLast) Divider(indent: 50, endIndent: 20, height: 1, color: Colors.brown.shade50),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Artifact _docToArtifact(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Artifact(
      id: doc.id,
      name: data['name'] ?? '',
      period: data['period'] ?? '',
      section: data['section'] ?? '',
      description: data['description'] ?? '',
      details: data['details'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      modelUrl: data['modelUrl'],
    );
  }
}
