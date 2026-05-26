import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
  String? _selectedRoom;
  List<Artifact> _roomArtifacts = [];
  bool _loading = false;

  final List<_RoomData> rooms = [
    _RoomData(
      name: 'Roman Empire',
      color: Color(0xFFFFEBEE),
      borderColor: Color(0xFFC62828),
      icon: '⚔️',
      section: 'Roman Empire',
    ),
    _RoomData(
      name: 'Ancient Sri Lanka',
      color: Color(0xFFE8F5E9),
      borderColor: Color(0xFF2E7D32),
      icon: '🏛️',
      section: 'Ancient Sri Lanka',
    ),
  ];

  FirebaseFirestore get _firestore =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');

  Future<void> _loadArtifacts(String section) async {
    setState(() {
      _loading = true;
      _selectedRoom = section;
      _roomArtifacts = [];
    });
    try {
      final snapshot = await _firestore
          .collection('artifacts')
          .where('section', isEqualTo: section)
          .get();
      final artifacts = snapshot.docs.map((doc) {
        final data = doc.data();
        return Artifact(
          id: doc.id,
          name: (data['name'] ?? data['Name'] ?? '').toString().trim(),
          period: (data['period'] ?? '').toString().trim(),
          section: (data['section'] ?? '').toString().trim(),
          description: (data['description'] ?? '').toString().trim(),
          details: (data['details'] ?? '').toString().trim(),
          imageUrl: (data['imageUrl'] ?? '').toString().trim(),
          modelUrl: data['modelUrl']?.toString().trim(),
        );
      }).toList();
      setState(() {
        _roomArtifacts = artifacts;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🗺️ Museum Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tap a room to see artifacts',
              style: TextStyle(
                color: Colors.brown[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.brown[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🚪 ENTRANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...rooms.map((room) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRoom(room),
                )),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.brown[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🚪 EXIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.brown),
            ),
          if (_roomArtifacts.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _roomArtifacts.length,
                itemBuilder: (context, index) =>
                    _buildArtifactTile(_roomArtifacts[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoom(_RoomData room) {
    final isSelected = _selectedRoom == room.section;
    return GestureDetector(
      onTap: () => _loadArtifacts(room.section),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: room.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? room.borderColor
                : room.borderColor.withOpacity(0.5),
            width: isSelected ? 3 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(room.icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              room.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: room.borderColor,
              ),
            ),
            const SizedBox(height: 4),
            Icon(Icons.location_on, color: room.borderColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildArtifactTile(Artifact artifact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            artifact.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 56,
              height: 56,
              color: Colors.brown[200],
              child: const Icon(Icons.image_not_supported,
                  color: Colors.white, size: 24),
            ),
          ),
        ),
        title: Text(
          artifact.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(artifact.period),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtifactDetailScreen(artifact: artifact),
          ),
        ),
      ),
    );
  }
}

class _RoomData {
  final String name;
  final Color color;
  final Color borderColor;
  final String icon;
  final String section;

  _RoomData({
    required this.name,
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.section,
  });
}