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
import 'notifications_screen.dart';
import 'dart:async';

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
  
  // Notification banner logic
  String? _lastNotifId;
  bool _showBanner = false;
  Timer? _hideTimer;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SETTINGS / සැකසුම්', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC9A84C))),
            const SizedBox(height: 24),
            const Text('LANGUAGE / භාෂාව', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('English')),
                    selected: !_isSinhala,
                    onSelected: (val) {
                      setState(() => _isSinhala = false);
                      MuseumApp.setLocale(context, const Locale('en'));
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('සිංහල')),
                    selected: _isSinhala,
                    onSelected: (val) {
                      setState(() => _isSinhala = true);
                      MuseumApp.setLocale(context, const Locale('si'));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('APPEARANCE / පෙනුම', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: const Color(0xFFC9A84C)),
              title: Text(isDark ? 'Dark Mode' : 'Light Mode', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(isDark ? 'සඳ එළිය (අඳුරු)' : 'හිරු එළිය (දීප්තිමත්)'),
              trailing: Switch(
                value: isDark,
                onChanged: (val) {
                  MuseumApp.setThemeMode(context, val ? ThemeMode.dark : ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFFC9A84C)),
                decoration: InputDecoration(
                  hintText: 'Search artifacts...', 
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.white70), 
                  border: InputBorder.none
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.museum_rounded, size: 24, color: Color(0xFFC9A84C)),
                  const SizedBox(width: 12),
                  const Text('ARTSPHERE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
        actions: [
          if (!_isSearching) IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          if (!_isSearching) IconButton(icon: const Icon(Icons.settings_outlined), onPressed: _showSettings),
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
                        height: 85,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            final section = sections[index];
                            final isSelected = section == selectedSection;
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(20 * (1 - value), 0),
                                  child: child,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ChoiceChip(
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(section),
                                  ),
                                  selected: isSelected,
                                  onSelected: (val) => setState(() => selectedSection = section),
                                  selectedColor: isDark ? const Color(0xFFC9A84C) : const Color(0xFF2C1810),
                                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected 
                                      ? (isDark ? const Color(0xFF2C1810) : const Color(0xFFC9A84C)) 
                                      : (isDark ? Colors.white70 : Colors.black87), 
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20), 
                                    side: BorderSide(color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.brown.shade50))
                                  ),
                                  showCheckmark: false,
                                  elevation: isSelected ? 8 : 0,
                                  shadowColor: (isDark ? const Color(0xFFC9A84C) : const Color(0xFF2C1810)).withOpacity(0.3),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                            final filteredDocs = _isSearching 
                                ? allDocs.where((doc) {
                                    final name = doc['name'].toString().toLowerCase();
                                    final desc = doc['description'].toString().toLowerCase();
                                    return name.contains(_searchQuery) || desc.contains(_searchQuery);
                                  }).toList()
                                : allDocs.where((doc) => doc['section'] == selectedSection).toList();

                            if (filteredDocs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
                                    const SizedBox(height: 16),
                                    Text('NO TREASURES FOUND', style: TextStyle(color: Colors.grey.withOpacity(0.5), fontWeight: FontWeight.w900, letterSpacing: 2)),
                                  ],
                                ),
                              );
                            }

                            return GridView.builder(
                              key: ValueKey('${selectedSection}_$_isSearching'),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) => TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 500 + (index * 100)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) => Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 50 * (1 - value)),
                                    child: child,
                                  ),
                                ),
                                child: _buildArtifactCard(_docToArtifact(filteredDocs[index])),
                              ),
                            );
                          },
                        ),
                      ),
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
        
        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final String currentId = doc.id;

        // Logic to trigger 30s timer when a NEW notification arrives
        if (_lastNotifId != currentId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _lastNotifId = currentId;
              _showBanner = true;
            });
            _hideTimer?.cancel();
            _hideTimer = Timer(const Duration(seconds: 30), () {
              if (mounted) setState(() => _showBanner = false);
            });
          });
        }

        if (!_showBanner) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFC9A84C),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
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
                      Text(data['message'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF2C1810)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF2C1810)),
                  onPressed: () => setState(() => _showBanner = false),
                )
              ],
            ),
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
      itemBuilder: (context, index) => TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 400 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        ),
        child: _buildArtifactCard(_docToArtifact(filtered[index])),
      ),
    );
  }

  Widget _buildSectionArtifacts(List<QueryDocumentSnapshot> docs, AppLocalizations l10n) {
    final sectionDocs = docs.where((doc) => doc['section'] == selectedSection).toList();
    return ListView.builder(
      key: ValueKey(selectedSection), // Key ensures animation restarts on section change
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sectionDocs.length,
      itemBuilder: (context, index) => TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 400 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        ),
        child: _buildArtifactCard(_docToArtifact(sectionDocs[index])),
      ),
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
      descriptionSi: data['descriptionSi']?.toString(),
      detailsSi: data['detailsSi']?.toString(),
      nameSi: data['nameSi']?.toString(),
    );
  }

  Widget _buildArtifactCard(Artifact artifact) {
    final l10n = AppLocalizations.of(context);
    final isSinhala = l10n.localeName == 'si';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = isSinhala && (artifact.nameSi != null) ? artifact.nameSi! : artifact.name;
    final description = isSinhala && (artifact.descriptionSi != null) ? artifact.descriptionSi! : artifact.description;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.brown.shade100.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtifactDetailScreen(artifact: artifact))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'artifact-${artifact.id}',
                      child: Image.network(
                        artifact.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image_rounded)),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    if (artifact.modelUrl != null && artifact.modelUrl!.isNotEmpty)
                      Positioned(
                        top: 16, right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9A84C),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.view_in_ar_rounded, size: 16, color: Color(0xFF2C1810)),
                              SizedBox(width: 6),
                              Text('3D', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C1810))),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 16, left: 20, right: 16,
                      child: Text(
                        name.toUpperCase(), 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 20, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9A84C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              artifact.period, 
                              style: const TextStyle(
                                fontWeight: FontWeight.w800, 
                                color: Color(0xFFC9A84C),
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description, 
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis, 
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4, fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.arrow_forward_rounded, size: 18, color: const Color(0xFFC9A84C).withOpacity(0.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
