import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../generated/app_localizations.dart';
import '../main.dart';
import '../models/artifact.dart';
import '../data/favorites_manager.dart';
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
  bool _showFavoritesOnly = false;
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
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SETTINGS / සැකසුම්',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFFC9A84C),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'LANGUAGE / භාෂාව',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('English')),
                    selected: !_isSinhala,
                    selectedColor: const Color(0xFFC9A84C),
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
                    selectedColor: const Color(0xFFC9A84C),
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
            const Text(
              'APPEARANCE / පෙනුම',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: const Color(0xFFC9A84C),
              ),
              title: Text(
                isDark ? 'Dark Velvet Mode' : 'Golden Light Mode',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(isDark ? 'සඳ එළිය (අඳුරු)' : 'හිරු එළිය (දීප්තිමත්)'),
              trailing: Switch(
                value: isDark,
                activeThumbColor: const Color(0xFFC9A84C),
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
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              elevation: 6,
              backgroundColor: const Color(0xFF2C1810),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssistantScreen()),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFFC9A84C)),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFC9A84C),
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined),
              activeIcon: const Icon(Icons.explore),
              label: l10n.exhibits,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_scanner_outlined),
              activeIcon: const Icon(Icons.qr_code_scanner),
              label: l10n.scanQR,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: l10n.map,
            ),
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
                  hintText: l10n.searchHint,
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.museum_rounded, size: 24, color: Color(0xFFC9A84C)),
                  const SizedBox(width: 12),
                  Text(
                    l10n.appTitle.toUpperCase(),
                    style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ],
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(
                _showFavoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _showFavoritesOnly ? Colors.redAccent : const Color(0xFFC9A84C),
              ),
              tooltip: l10n.favorites,
              onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
            ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
          if (!_isSearching)
            IconButton(icon: const Icon(Icons.settings_outlined), onPressed: _showSettings),
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _isSearching = true),
                ),
          if (!_isSearching)
            IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          _buildNotificationBanner(),
          Expanded(
            child: ValueListenableBuilder<Set<String>>(
              valueListenable: FavoritesManager.instance.favoriteIdsNotifier,
              builder: (context, favoriteIds, _) {
                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('artifacts').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text(l10n.noArtifacts));
                    }

                    final allArtifacts = snapshot.data!.docs
                        .map((doc) => Artifact.fromFirestore(doc))
                        .toList();

                    final sections = allArtifacts.map((a) => a.section).toSet().toList();
                    sections.sort();

                    if (selectedSection == null || !sections.contains(selectedSection)) {
                      selectedSection = sections.isNotEmpty ? sections[0] : null;
                    }

                    List<Artifact> filteredList = allArtifacts;

                    if (_showFavoritesOnly) {
                      filteredList = filteredList.where((a) => favoriteIds.contains(a.id)).toList();
                    } else if (_isSearching && _searchQuery.isNotEmpty) {
                      filteredList = filteredList.where((a) {
                        final name = a.name.toLowerCase();
                        final nameSi = (a.nameSi ?? '').toLowerCase();
                        final desc = a.description.toLowerCase();
                        final descSi = (a.descriptionSi ?? '').toLowerCase();
                        return name.contains(_searchQuery) ||
                            nameSi.contains(_searchQuery) ||
                            desc.contains(_searchQuery) ||
                            descSi.contains(_searchQuery);
                      }).toList();
                    } else {
                      filteredList = filteredList.where((a) => a.section == selectedSection).toList();
                    }

                    return Column(
                      children: [
                        if (!_isSearching && !_showFavoritesOnly && sections.isNotEmpty)
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
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: ChoiceChip(
                                    label: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(section),
                                    ),
                                    selected: isSelected,
                                    onSelected: (val) => setState(() => selectedSection = section),
                                    selectedColor: const Color(0xFFC9A84C),
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.white,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF2C1810)
                                          : (isDark ? Colors.white70 : Colors.black87),
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.transparent
                                            : (isDark ? Colors.white10 : Colors.brown.shade100),
                                      ),
                                    ),
                                    showCheckmark: false,
                                    elevation: isSelected ? 6 : 0,
                                  ),
                                );
                              },
                            ),
                          ),
                        if (_showFavoritesOnly)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.favorites.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: Color(0xFFC9A84C),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => setState(() => _showFavoritesOnly = false),
                                  child: const Text('SHOW ALL'),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: filteredList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _showFavoritesOnly
                                            ? Icons.favorite_border_rounded
                                            : Icons.search_off_rounded,
                                        size: 72,
                                        color: Colors.grey.withValues(alpha: 0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _showFavoritesOnly ? l10n.noFavorites : l10n.noResults,
                                        style: TextStyle(
                                          color: Colors.grey.withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final crossAxisCount = constraints.maxWidth > 900
                                        ? 3
                                        : (constraints.maxWidth > 600 ? 2 : 1);

                                    return GridView.builder(
                                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 24,
                                        mainAxisSpacing: 24,
                                        childAspectRatio: 0.85,
                                      ),
                                      itemCount: filteredList.length,
                                      itemBuilder: (context, index) => _buildArtifactCard(
                                        filteredList[index],
                                        favoriteIds.contains(filteredList[index].id),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
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
      stream: _firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final String currentId = doc.id;

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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFC9A84C),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: Color(0xFF2C1810)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                      Text(
                        data['message'] ?? '',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2C1810)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildArtifactCard(Artifact artifact, bool isFavorite) {
    final l10n = AppLocalizations.of(context);
    final isSinhala = l10n.localeName == 'si';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = isSinhala && (artifact.nameSi != null) ? artifact.nameSi! : artifact.name;
    final description =
        isSinhala && (artifact.descriptionSi != null) ? artifact.descriptionSi! : artifact.description;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.brown.shade100.withValues(alpha: 0.3),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ArtifactDetailScreen(artifact: artifact)),
          ),
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
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.museum_rounded, size: 50),
                        ),
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
                              Colors.black.withValues(alpha: 0.75),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (artifact.modelUrl != null && artifact.modelUrl!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9A84C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '3D',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  color: Color(0xFF2C1810),
                                ),
                              ),
                            ),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black45,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: Icon(
                                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isFavorite ? Colors.redAccent : Colors.white,
                              ),
                              onPressed: () {
                                FavoritesManager.instance.toggleFavorite(artifact.id);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 16,
                      child: Text(
                        name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
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
                              color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
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
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: const Color(0xFFC9A84C).withValues(alpha: 0.7),
                          ),
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
