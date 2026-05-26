import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/artifact.dart';
import 'edit_artifact_screen.dart';
import '../../data/seed_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isSeeding = false;

  Future<void> _handleRestoreData() async {
    setState(() => _isSeeding = true);
    try {
      await seedFirestore();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Repository Sync Successful.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync Error: $e')));
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF2C1810),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.none,
            selectedIconTheme: const IconThemeData(color: Color(0xFFC9A84C), size: 32),
            unselectedIconTheme: const IconThemeData(color: Colors.white24, size: 24),
            leading: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A84C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.museum_rounded, color: Color(0xFF2C1810), size: 24),
                ),
                const SizedBox(height: 60),
              ],
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Assets')),
              NavigationRailDestination(icon: Icon(Icons.message_rounded), label: Text('Reviews')),
              NavigationRailDestination(icon: Icon(Icons.group_rounded), label: Text('Guests')),
              NavigationRailDestination(icon: Icon(Icons.confirmation_number_rounded), label: Text('Passes')),
              NavigationRailDestination(icon: Icon(Icons.notification_important_rounded), label: Text('Alerts')),
            ],
            trailing: Expanded(child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 20), child: IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white24), onPressed: () => Navigator.pop(context))))),
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [_buildArtifactList(), _buildFeedbackList(), _buildAttendanceList(), _buildTicketManagement(), _buildNotificationCenter()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditArtifactScreen())),
            backgroundColor: const Color(0xFF2C1810),
            child: const Icon(Icons.add_rounded, color: Color(0xFFC9A84C)),
          )
        : null,
    );
  }

  Widget _buildTopBar() {
    String title = ['Artifact Repository', 'Visitor Feedback', 'Guest Attendance', 'Pass Management', 'Broadcast Center'][_selectedIndex];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2C1810))),
          if (_selectedIndex == 0)
            _isSeeding 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : TextButton.icon(onPressed: _handleRestoreData, icon: const Icon(Icons.sync_rounded), label: const Text('SYNC DEFAULTS'), style: TextButton.styleFrom(foregroundColor: Colors.brown)),
        ],
      ),
    );
  }

  Widget _buildArtifactList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('artifacts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(32),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, childAspectRatio: 0.8, crossAxisSpacing: 24, mainAxisSpacing: 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Image.network(data['imageUrl'] ?? '', width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade100))),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(data['section'] ?? '', style: TextStyle(color: Colors.brown.shade300, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditArtifactScreen(artifact: _docToArtifact(docs[index])))), child: const Text('EDIT', style: TextStyle(fontSize: 11)))),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), onPressed: () => _deleteArtifact(context, docs[index].id)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedbackList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('feedback').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(32),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(data['artifactName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 8), Row(children: List.generate(5, (i) => Icon(i < (data['rating'] ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFC9A84C), size: 18))), const SizedBox(height: 8), Text(data['comment'] ?? '', style: const TextStyle(fontStyle: FontStyle.italic))]),
                trailing: IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: Colors.grey), onPressed: () => FirebaseFirestore.instance.collection('feedback').doc(docs[index].id).delete()),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return ListView.builder(
          padding: const EdgeInsets.all(32),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final date = (data['timestamp'] as Timestamp?)?.toDate();
            return Card(child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFFCFAF7), child: Icon(Icons.person_rounded, color: Colors.brown)), title: Text('Pass: ${data['ticketNumber']}'), subtitle: Text('ID: ${data['nic']}'), trailing: Text(date != null ? DateFormat('HH:mm').format(date) : '--:--', style: const TextStyle(fontWeight: FontWeight.bold))));
          },
        );
      },
    );
  }

  Widget _buildTicketManagement() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return ListView.builder(
          padding: const EdgeInsets.all(32),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final bool isBlocked = data['isBlocked'] ?? false;
            return Card(
              color: isBlocked ? Colors.red.shade50 : Colors.white,
              child: ListTile(
                title: Text(doc.id, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('Usage: ${List.from(data['usedBy'] ?? []).length} / 4 Devices'),
                trailing: Switch(value: !isBlocked, activeTrackColor: Colors.green, onChanged: (v) => FirebaseFirestore.instance.collection('tickets').doc(doc.id).update({'isBlocked': !v})),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationCenter() {
    final title = TextEditingController();
    final msg = TextEditingController();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.brown.shade50)),
            child: Column(
              children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Alert Headline')),
                const SizedBox(height: 16),
                TextField(controller: msg, maxLines: 3, decoration: const InputDecoration(labelText: 'Detailed Message')),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: () async { 
                  if (title.text.isEmpty) return; 
                  await FirebaseFirestore.instance.collection('notifications').add({'title': title.text, 'message': msg.text, 'timestamp': FieldValue.serverTimestamp()}); 
                  title.clear(); msg.clear(); 
                }, child: const Text('DISPATCH BROADCAST')),
              ],
            ),
          ),
          const SizedBox(height: 48),
          const Text('Sent History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C1810))),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('notifications').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['timestamp'] as Timestamp?)?.toDate();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['message'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (date != null) Text(DateFormat('MMM dd').format(date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(width: 8),
                          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20), onPressed: () => FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete()),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Artifact _docToArtifact(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Artifact(id: doc.id, name: data['name'] ?? '', period: data['period'] ?? '', section: data['section'] ?? '', description: data['description'] ?? '', details: data['details'] ?? '', imageUrl: data['imageUrl'] ?? '', modelUrl: data['modelUrl']);
  }

  Future<void> _deleteArtifact(BuildContext context, String id) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Archive Artifact?'), content: const Text('This action is irreversible.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCEL')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('ARCHIVE', style: TextStyle(color: Colors.red)))]));
    if (ok == true) await FirebaseFirestore.instance.collection('artifacts').doc(id).delete();
  }
}
