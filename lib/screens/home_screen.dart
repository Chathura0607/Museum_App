import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
  String selectedSection = 'Roman Empire';
  int _currentIndex = 0;
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isSinhala = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> sectionKeys = [
    'Roman Empire',
    'Ancient Sri Lanka',
  ];

  FirebaseFirestore get _firestore =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() => _isSinhala = !_isSinhala);
    MuseumApp.setLocale(
      context,
      _isSinhala ? const Locale('si') : const Locale('en'),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<String> _getSectionLabels(AppLocalizations l10n) => sectionKeys;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: _currentIndex == 0
          ? _buildMuseumScreen(l10n)
          : _currentIndex == 1
          ? QrScannerScreen(l10n: l10n)
          : MapScreen(l10n: l10n),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.brown[700],
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AssistantScreen(),
          ),
        ),
        child: const Icon(Icons.headset_mic, color: Colors.white, size: 20),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.brown[700],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.museum),
            label: 'Exhibits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }

  Widget _buildMuseumScreen(AppLocalizations l10n) {
    final sectionLabels = _getSectionLabels(l10n);
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value.toLowerCase());
          },
        )
            : Text(
          '🏛️ ${l10n.appTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          if (!_isSearching)
            TextButton(
              onPressed: _toggleLanguage,
              child: Text(
                _isSinhala ? 'EN' : 'සිං',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          _isSearching
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          )
              : IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() => _isSearching = true);
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_isSearching)
            Container(
              color: Colors.brown[50],
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: sectionKeys.length,
                itemBuilder: (context, index) {
                  final sectionKey = sectionKeys[index];
                  final sectionLabel = sectionLabels[index];
                  final isSelected = sectionKey == selectedSection;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSection = sectionKey),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.brown[700] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.brown[300]!),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sectionLabel,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.brown[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: _isSearching
                ? _buildSearchResults(l10n)
                : _buildSectionArtifacts(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('artifacts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final period = (data['period'] ?? '').toString().toLowerCase();
          final section = (data['section'] ?? '').toString().toLowerCase();
          final description = (data['description'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery) ||
              period.contains(_searchQuery) ||
              section.contains(_searchQuery) ||
              description.contains(_searchQuery);
        }).toList();

        if (_searchQuery.isEmpty) {
          return Center(
            child: Text(l10n.searchPrompt,
                style: const TextStyle(color: Colors.grey)),
          );
        }

        if (filtered.isEmpty) {
          return Center(
            child: Text(l10n.noResults,
                style: const TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final data = filtered[index].data() as Map<String, dynamic>;
            final artifact = Artifact(
              id: filtered[index].id,
              name: (data['name'] ?? data['Name'] ?? '').toString().trim(),
              period: (data['period'] ?? '').toString().trim(),
              section: data['section'] ?? '',
              description: data['description'] ?? '',
              details: data['details'] ?? '',
              imageUrl: data['imageUrl'] ?? '',
              modelUrl: data['modelUrl'],
              descriptionSi: data['description_si'],
              detailsSi: data['details_si'],
            );
            return _buildArtifactCard(artifact);
          },
        );
      },
    );
  }

  Widget _buildSectionArtifacts(AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot>(
      key: ValueKey(selectedSection),
      stream: _firestore
          .collection('artifacts')
          .where('section', isEqualTo: selectedSection.trim())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Text(l10n.noArtifacts));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final artifact = Artifact(
              id: docs[index].id,
              name: (data['name'] ?? data['Name'] ?? '').toString().trim(),
              period: (data['period'] ?? '').toString().trim(),
              section: data['section'] ?? '',
              description: data['description'] ?? '',
              details: data['details'] ?? '',
              imageUrl: data['imageUrl'] ?? '',
              modelUrl: data['modelUrl'],
              descriptionSi: data['description_si'],
              detailsSi: data['details_si'],
            );
            return _buildArtifactCard(artifact);
          },
        );
      },
    );
  }

  Widget _buildArtifactCard(Artifact artifact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtifactDetailScreen(artifact: artifact),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              artifact.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.brown[200],
                child: const Icon(Icons.image_not_supported,
                    size: 60, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          artifact.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (artifact.modelUrl != null)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ModelViewerScreen(artifact: artifact),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.brown[700],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.view_in_ar,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '3D View',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artifact.period,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.brown[200]!),
                    ),
                    child: Text(
                      artifact.section,
                      style: TextStyle(
                        color: Colors.brown[700],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artifact.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
