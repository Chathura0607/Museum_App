import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  bool _isLoading = false;
  String? _ticketError;
  String? _nicError;

  final _ticketRegex = RegExp(r'^TKT-\d{4}-\d{3}$');
  final _oldNICRegex = RegExp(r'^\d{9}[VX]$');
  final _newNICRegex = RegExp(r'^\d{12}$');

  @override
  void initState() {
    super.initState();
    _ticketController.addListener(_validateTicket);
    _idController.addListener(_validateNIC);
  }

  void _validateTicket() {
    final val = _ticketController.text.trim().toUpperCase();
    if (val.isEmpty) setState(() => _ticketError = null);
    else if (!_ticketRegex.hasMatch(val)) setState(() => _ticketError = 'Required: TKT-2025-001');
    else setState(() => _ticketError = null);
  }

  void _validateNIC() {
    final val = _idController.text.trim().toUpperCase();
    if (val.isEmpty) setState(() => _nicError = null);
    else if (!_oldNICRegex.hasMatch(val) && !_newNICRegex.hasMatch(val)) setState(() => _nicError = 'Invalid NIC format');
    else setState(() => _nicError = null);
  }

  Future<void> _login() async {
    final ticketId = _ticketController.text.trim().toUpperCase();
    final nic = _idController.text.trim().toUpperCase();
    if (_ticketError != null || _nicError != null || ticketId.isEmpty || nic.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final ticketRef = FirebaseFirestore.instance.collection('tickets').doc(ticketId);
      final ticketDoc = await ticketRef.get();
      if (ticketDoc.exists) {
        final data = ticketDoc.data()!;
        if (data['isBlocked'] ?? false) throw 'Ticket blocked. Visit Information Desk.';
        final List users = List.from(data['usedBy'] ?? []);
        if (!users.contains(nic)) {
          if (users.length >= 4) { await ticketRef.update({'isBlocked': true}); throw 'User limit reached. Ticket BLOCKED.'; }
          users.add(nic); await ticketRef.update({'usedBy': users});
        }
      } else { await ticketRef.set({'usedBy': [nic], 'isBlocked': false, 'createdAt': FieldValue.serverTimestamp()}); }
      await FirebaseFirestore.instance.collection('attendance').add({'ticketNumber': ticketId, 'nic': nic, 'timestamp': FieldValue.serverTimestamp()});
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (mounted) showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Access Restricted'), content: Text(e.toString()), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('UNDERSTOOD'))]));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1554907984-15263bfd63bd?q=80&w=1920&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2C1810).withOpacity(0.4),
                    const Color(0xFF2C1810).withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC9A84C), width: 1.5),
                        boxShadow: [BoxShadow(color: const Color(0xFFC9A84C).withOpacity(0.1), blurRadius: 40)],
                      ),
                      child: const Icon(Icons.museum_rounded, size: 50, color: Color(0xFFC9A84C)),
                    ),
                    const SizedBox(height: 24),
                    const Text('ARTSPHERE', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 8)),
                    const Text('YOUR PERSONAL CURATOR', style: TextStyle(fontSize: 10, color: Color(0xFFC9A84C), letterSpacing: 4, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _ticketController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'TICKET PASS ID',
                              labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
                              errorText: _ticketError,
                              prefixIcon: const Icon(Icons.confirmation_num_rounded, color: Color(0xFFC9A84C)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _idController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'NIC NUMBER',
                              labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
                              errorText: _nicError,
                              prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFFC9A84C)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9A84C),
                              foregroundColor: const Color(0xFF2C1810),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            child: _isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2C1810))) 
                              : const Text('BEGIN JOURNEY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextButton(
                      onPressed: _showAdminLogin,
                      child: Text('CURATOR PORTAL', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.bold)),
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

  void _showAdminLogin() {
    final passwordController = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Staff Secure Login'), content: TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(hintText: 'Passcode')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('BACK')), TextButton(onPressed: () { if (passwordController.text == 'admin123') { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())); } }, child: const Text('ACCESS'))]));
  }
}
