import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../generated/app_localizations.dart';
import '../main.dart';
import '../models/artifact.dart';
import 'artifact_detail_screen.dart';
import 'map_screen.dart';
import 'qr_scanner_screen.dart';
import 'assistant_screen.dart';
import 'model_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedSection;
  int _currentIndex = 0;
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isSinhala = false;
  final TextEditingController _searchController = TextEditingController();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() => _isSinhala = !_isSinhala);
    MuseumApp.setLocale(context, _isSinhala ? const Locale('si') : const Locale('en'));
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit ArtSphere?'),
        content: const Text('Are you sure you want to log out of your session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMuseumScreen(l10n),
          QrScannerScreen(l10n: l10n),
          MapScreen(l10n: l10n),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        elevation: 4,
        backgroundColor: const Color(0xFF2C1810),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssistantScreen())),
        child: const Icon(Icons.auto_awesome, color: Color(0xFFC9A84C)),
      ) : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF2C1810),
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_outlined), activeIcon: Icon(Icons.qr_code_scanner), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          ],
        ),
      ),
    );
  }

  Widget _buildMuseumScreen(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Color(0xFFC9A84C)),
                decoration: const InputDecoration(hintText: 'Search artifacts...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              )
            : const Text('ArtSphere', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w900)),
        actions: [
          if (!_isSearching) IconButton(icon: const Icon(Icons.translate), onPressed: _toggleLanguage),
          _isSearching 
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _isSearching = false; _searchQuery = ''; _searchController.clear(); }))
            : IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _isSearching = true)),
          if (!_isSearching) IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          _buildNotificationBanner(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('artifacts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No artifacts found. Try restoring defaults.'));
                
                final allDocs = snapshot.data!.docs;
                final sections = allDocs.map((doc) => doc['section'].toString()).toSet().toList();
                sections.sort();
                
                if (selectedSection == null || !sections.contains(selectedSection)) {
                  selectedSection = sections.isNotEmpty ? sections[0] : null;
                }

                return Column(
                  children: [
                    if (!_isSearching && sections.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        height: 75,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            final section = sections[index];
                            final isSelected = section == selectedSection;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text(section),
                                selected: isSelected,
                                onSelected: (val) => setState(() => selectedSection = section),
                                selectedColor: const Color(0xFF2C1810),
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(color: isSelected ? const Color(0xFFC9A84C) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200)),
                                showCheckmark: false,
                              ),
                            );
                          },
                        ),
                      ),
                    Expanded(
                      child: _isSearching ? _buildSearchResults(allDocs, l10n) : _buildSectionArtifacts(allDocs, l10n),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('notifications').orderBy('timestamp', descending: true).limit(1).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFC9A84C).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.campaign_rounded, color: Color(0xFF2C1810)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C1810))),
                    Text(data['message'] ?? '', style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.7))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(List<QueryDocumentSnapshot> docs, AppLocalizations l10n) {
    final filtered = docs.where((doc) {
      final name = doc['name'].toString().toLowerCase();
      final desc = doc['description'].toString().toLowerCase();
      return name.contains(_searchQuery) || desc.contains(_searchQuery);
    }).toList();
    if (filtered.isEmpty) return const Center(child: Text('No matching treasures found.'));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildArtifactCard(_docToArtifact(filtered[index])),
    );
  }

  Widget _buildSectionArtifacts(List<QueryDocumentSnapshot> docs, AppLocalizations l10n) {
    final sectionDocs = docs.where((doc) => doc['section'] == selectedSection).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sectionDocs.length,
      itemBuilder: (context, index) => _buildArtifactCard(_docToArtifact(sectionDocs[index])),
    );
  }

  Artifact _docToArtifact(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Artifact(
      id: doc.id,
      name: data['name'] ?? '',
      period: data['period'] ?? '',
      year: data['year']?.toString(),
      section: data['section'] ?? '',
      location: data['location']?.toString(),
      description: data['description'] ?? '',
      details: data['details'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      modelUrl: data['modelUrl']?.toString(),
      videoUrl: data['videoUrl']?.toString(),
      audioUrl: data['audioUrl']?.toString(),
    );
  }

  Widget _buildArtifactCard(Artifact artifact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtifactDetailScreen(artifact: artifact))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'artifact-${artifact.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      artifact.imageUrl,
                      height: 240, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(height: 240, color: Colors.grey.shade200, child: const Icon(Icons.broken_image_rounded)),
                    ),
                  ),
                ),
                if (artifact.modelUrl != null && artifact.modelUrl!.isNotEmpty)
                  Positioned(
                    top: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                      child: const Row(
                        children: [
                          Icon(Icons.view_in_ar_rounded, size: 18, color: Color(0xFF2C1810)),
                          SizedBox(width: 6),
                          Text('3D', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2C1810))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(artifact.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5))),
                      Text(artifact.period, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A84C))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(artifact.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
