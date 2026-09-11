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

  // Attendance Filters
  DateTime? _selectedDate;
  String _nicFilter = '';
  final TextEditingController _nicController = TextEditingController();

  @override
  void dispose() {
    _nicController.dispose();
    super.dispose();
  }

  Future<void> _handleRestoreData() async {
    setState(() => _isSeeding = true);
    try {
      await seedFirestore();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exhibit Repository Synchronized with rich Bilingual Data.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  void _showQrDialog(BuildContext context, Artifact artifact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'QR Code • ${artifact.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C1810)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(artifact.id)}',
                    width: 180,
                    height: 180,
                    errorBuilder: (c, e, s) => Container(
                      width: 180,
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.qr_code, size: 60)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan ID: ${artifact.id}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2C1810), letterSpacing: 1),
                  ),
                  Text(
                    artifact.section,
                    style: TextStyle(color: Colors.brown.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE', style: TextStyle(color: Color(0xFF2C1810), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCreatePassDialog() {
    final ticketNumber = 'TKT-${DateFormat('yyyy-MM-dd').format(DateTime.now())}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9, 12)}';
    final controller = TextEditingController(text: ticketNumber);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Issue New Ticket Pass', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Generate an authentic pass for visitor entry with device allocation quota:', style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Ticket ID Code', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A84C), foregroundColor: const Color(0xFF2C1810)),
            onPressed: () async {
              final id = controller.text.trim().toUpperCase();
              if (id.isEmpty) return;
              await FirebaseFirestore.instance.collection('tickets').doc(id).set({
                'usedBy': [],
                'isBlocked': false,
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pass $id activated successfully.')));
              }
            },
            child: const Text('ACTIVATE PASS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
            selectedIconTheme: const IconThemeData(color: Color(0xFFC9A84C), size: 30),
            unselectedIconTheme: const IconThemeData(color: Colors.white30, size: 24),
            leading: Column(
              children: [
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A84C),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.museum_rounded, color: Color(0xFF2C1810), size: 26),
                ),
                const SizedBox(height: 48),
              ],
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Assets')),
              NavigationRailDestination(icon: Icon(Icons.rate_review_rounded), label: Text('Reviews')),
              NavigationRailDestination(icon: Icon(Icons.people_alt_rounded), label: Text('Guests')),
              NavigationRailDestination(icon: Icon(Icons.confirmation_number_rounded), label: Text('Passes')),
              NavigationRailDestination(icon: Icon(Icons.campaign_rounded), label: Text('Alerts')),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white54),
                    tooltip: 'Exit Portal',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _buildArtifactList(),
                      _buildFeedbackList(),
                      _buildAttendanceList(),
                      _buildTicketManagement(),
                      _buildNotificationCenter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditArtifactScreen()),
              ),
              backgroundColor: const Color(0xFF2C1810),
              icon: const Icon(Icons.add_rounded, color: Color(0xFFC9A84C)),
              label: const Text('NEW EXHIBIT', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
            )
          : (_selectedIndex == 3
              ? FloatingActionButton.extended(
                  onPressed: _showCreatePassDialog,
                  backgroundColor: const Color(0xFF2C1810),
                  icon: const Icon(Icons.add_card_rounded, color: Color(0xFFC9A84C)),
                  label: const Text('ISSUE PASS', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
                )
              : null),
    );
  }

  Widget _buildTopBar() {
    String title = [
      'Exhibits Repository',
      'Visitor Reviews & Insights',
      'Guest Attendance Log',
      'Pass & Ticket Desk',
      'Broadcast Alerts Center'
    ][_selectedIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2C1810)),
          ),
          if (_selectedIndex == 0)
            _isSeeding
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC9A84C)))
                : OutlinedButton.icon(
                    onPressed: _handleRestoreData,
                    icon: const Icon(Icons.sync_rounded, color: Color(0xFF2C1810)),
                    label: const Text('SYNC SEED DATA', style: TextStyle(color: Color(0xFF2C1810), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFC9A84C))),
                  ),
        ],
      ),
    );
  }

  Widget _buildArtifactList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('artifacts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)));
        final docs = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(28),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            childAspectRatio: 0.78,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final artifact = Artifact.fromFirestore(docs[index]);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          artifact.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.museum_rounded)),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF2C1810), size: 20),
                              tooltip: 'View QR Code',
                              onPressed: () => _showQrDialog(context, artifact),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artifact.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (artifact.nameSi != null && artifact.nameSi!.isNotEmpty)
                          Text(
                            artifact.nameSi!,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${artifact.period} • ${artifact.section}',
                          style: const TextStyle(color: Color(0xFFC9A84C), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EditArtifactScreen(artifact: artifact)),
                                ),
                                child: const Text('EDIT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                              onPressed: () => _deleteArtifact(context, artifact.id),
                            ),
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)));
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) return const Center(child: Text('No visitor reviews recorded yet.'));

        return ListView.builder(
          padding: const EdgeInsets.all(28),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final rating = (data['rating'] as num?)?.toInt() ?? 5;
            final tags = List<String>.from(data['tags'] ?? []);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                title: Text(data['artifactName'] ?? 'General Museum Review', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFC9A84C),
                          size: 20,
                        ),
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: tags.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero)).toList(),
                      ),
                    ],
                    if ((data['comment'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('"${data['comment']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.grey),
                  onPressed: () => FirebaseFirestore.instance.collection('feedback').doc(docs[index].id).delete(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    Query query = FirebaseFirestore.instance.collection('attendance').orderBy('timestamp', descending: true);

    if (_selectedDate != null) {
      final startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay)).where('timestamp', isLessThan: Timestamp.fromDate(endOfDay));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nicController,
                  decoration: InputDecoration(
                    hintText: 'Filter by Visitor NIC...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: _nicFilter.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _nicController.clear();
                              setState(() => _nicFilter = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _nicFilter = val.toUpperCase()),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate == null ? 'All Dates' : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
              ),
              if (_selectedDate != null)
                IconButton(icon: const Icon(Icons.history_toggle_off), onPressed: () => setState(() => _selectedDate = null)),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)));
              if (!snapshot.hasData) return const SizedBox();

              var docs = snapshot.data!.docs;
              if (_nicFilter.isNotEmpty) {
                docs = docs.where((doc) => (doc['nic'] ?? '').toString().toUpperCase().contains(_nicFilter)).toList();
              }

              if (docs.isEmpty) return const Center(child: Text('No visitor records found.'));

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final date = (data['timestamp'] as Timestamp?)?.toDate();
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFCFAF7),
                        child: Icon(Icons.person_rounded, color: Color(0xFF2C1810)),
                      ),
                      title: Text('Ticket: ${data['ticketNumber']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Guest NIC: ${data['nic']}'),
                      trailing: Text(
                        date != null ? DateFormat('MMM dd, HH:mm').format(date) : '--:--',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A84C)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketManagement() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)));
        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(28),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final bool isBlocked = data['isBlocked'] ?? false;
            final usedBy = List.from(data['usedBy'] ?? []);

            return Card(
              color: isBlocked ? Colors.red.shade50 : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(doc.id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                subtitle: Text('Devices Active: ${usedBy.length} / 4 Devices allocated ${isBlocked ? '(SUSPENDED)' : '(ACTIVE)'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: !isBlocked,
                      activeThumbColor: Colors.green,
                      onChanged: (v) => FirebaseFirestore.instance.collection('tickets').doc(doc.id).update({'isBlocked': !v}),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => FirebaseFirestore.instance.collection('tickets').doc(doc.id).delete(),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.brown.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dispatch Live Museum Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C1810))),
                const SizedBox(height: 16),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Alert Headline', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: msg, maxLines: 3, decoration: const InputDecoration(labelText: 'Detailed Broadcast Message', border: OutlineInputBorder())),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: const Color(0xFF2C1810),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: () async {
                    if (title.text.trim().isEmpty) return;
                    await FirebaseFirestore.instance.collection('notifications').add({
                      'title': title.text.trim(),
                      'message': msg.text.trim(),
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    title.clear();
                    msg.clear();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent.')));
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('DISPATCH BROADCAST', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          const Text('Broadcast History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C1810))),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('notifications').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['timestamp'] as Timestamp?)?.toDate();
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['message'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (date != null) Text(DateFormat('MMM dd, HH:mm').format(date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            onPressed: () => FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete(),
                          ),
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

  Future<void> _deleteArtifact(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Archive Artifact?'),
        content: const Text('Are you sure you want to permanently delete this exhibit from the active collection?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('ARCHIVE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseFirestore.instance.collection('artifacts').doc(id).delete();
    }
  }
}
