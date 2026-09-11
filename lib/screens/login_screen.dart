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

  final _ticketRegex = RegExp(r'^TKT-\d{4}-\d{2}-\d{2}-\d{3}$');
  final _oldNICRegex = RegExp(r'^\d{9}[VX]$');
  final _newNICRegex = RegExp(r'^\d{12}$');

  @override
  void initState() {
    super.initState();
    _ticketController.addListener(_validateTicket);
    _idController.addListener(_validateNIC);
  }

  @override
  void dispose() {
    _ticketController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _validateTicket() {
    final val = _ticketController.text.trim().toUpperCase();
    if (val.isEmpty) {
      setState(() => _ticketError = null);
    } else if (!_ticketRegex.hasMatch(val)) {
      setState(() => _ticketError = 'Required: TKT-YYYY-MM-DD-001');
    } else {
      setState(() => _ticketError = null);
    }
  }

  void _validateNIC() {
    final val = _idController.text.trim().toUpperCase();
    if (val.isEmpty) {
      setState(() => _nicError = null);
    } else if (!_oldNICRegex.hasMatch(val) && !_newNICRegex.hasMatch(val)) {
      setState(() => _nicError = 'Invalid NIC format (e.g. 199012345678 or 901234567V)');
    } else {
      setState(() => _nicError = null);
    }
  }

  Future<void> _login() async {
    final ticketId = _ticketController.text.trim().toUpperCase();
    final nic = _idController.text.trim().toUpperCase();
    
    if (ticketId.isEmpty || nic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both your Ticket Pass ID and National ID.'),
          backgroundColor: Color(0xFF2C1810),
        ),
      );
      return;
    }
    if (_ticketError != null || _nicError != null) return;
    
    setState(() => _isLoading = true);
    try {
      final ticketRef = FirebaseFirestore.instance.collection('tickets').doc(ticketId);
      final ticketDoc = await ticketRef.get();
      
      if (!ticketDoc.exists) {
        throw 'Unregistered Pass: Please visit the ticketing desk or scan a valid official museum pass.';
      }
      
      final data = ticketDoc.data() ?? {};
      if (data['isBlocked'] == true) {
        throw 'This ticket pass has been suspended. Please visit the Information Desk.';
      }
      
      final List users = List.from(data['usedBy'] ?? []);
      if (!users.contains(nic)) {
        if (users.length >= 4) {
          await ticketRef.update({'isBlocked': true});
          throw 'Maximum device allocation reached (4 devices). Pass has been locked.';
        }
        users.add(nic);
        await ticketRef.update({'usedBy': users});
      }
      
      await FirebaseFirestore.instance.collection('attendance').add({
        'ticketNumber': ticketId,
        'nic': nic,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.lock_clock_rounded, color: Color(0xFFC9A84C)),
                SizedBox(width: 10),
                Text('Access Check', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(e.toString(), style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('UNDERSTOOD', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAdminLogin() {
    final passwordController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFC9A84C), width: 1)),
          title: const Row(
            children: [
              Icon(Icons.shield_rounded, color: Color(0xFFC9A84C)),
              SizedBox(width: 12),
              Text('Curator Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter museum staff credentials to access administrative tools.', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Staff Passcode',
                  labelStyle: const TextStyle(color: Color(0xFFC9A84C)),
                  prefixIcon: const Icon(Icons.password_rounded, color: Color(0xFFC9A84C)),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white60),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC9A84C))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                passwordController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A84C),
                foregroundColor: const Color(0xFF2C1810),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final pass = passwordController.text.trim();
                // Verified Curator passcode check
                if (pass == 'admin123' || pass == 'curator2026') {
                  passwordController.dispose();
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboard()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid Curator Passcode.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('AUTHORIZE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
              errorBuilder: (c, e, s) => Container(color: const Color(0xFF1E120D)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2C1810).withValues(alpha: 0.5),
                    const Color(0xFF160B07).withValues(alpha: 0.96),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 900),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.scale(scale: 0.7 + (0.3 * value), child: child),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFC9A84C), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC9A84C).withValues(alpha: 0.2),
                              blurRadius: 40,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(Icons.museum_rounded, size: 52, color: Color(0xFFC9A84C)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'ARTSPHERE',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'YOUR PERSONAL MUSEUM CURATOR',
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(0xFFC9A84C).withValues(alpha: 0.9),
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _ticketController,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                labelText: 'TICKET PASS ID',
                                labelStyle: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1),
                                hintText: 'TKT-2026-09-11-001',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                                errorText: _ticketError,
                                prefixIcon: const Icon(Icons.confirmation_num_rounded, color: Color(0xFFC9A84C)),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC9A84C), width: 2)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _idController,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                labelText: 'NATIONAL ID (NIC)',
                                labelStyle: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1),
                                hintText: '199012345678 or 901234567V',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                                errorText: _nicError,
                                prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFFC9A84C)),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC9A84C), width: 2)),
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC9A84C),
                                  foregroundColor: const Color(0xFF2C1810),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 8,
                                  shadowColor: const Color(0xFFC9A84C).withValues(alpha: 0.4),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C1810)),
                                      )
                                    : const Text(
                                        'BEGIN JOURNEY',
                                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 15),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextButton.icon(
                      onPressed: _showAdminLogin,
                      icon: Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.white.withValues(alpha: 0.5)),
                      label: Text(
                        'CURATOR PORTAL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
