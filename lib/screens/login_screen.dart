import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _login() {
    final ticket = _ticketController.text.trim();
    final id = _idController.text.trim().toUpperCase();
    if (ticket.isEmpty) {
      setState(() => _error = 'Please enter your ticket number');
      return;
    }
    final oldNIC = RegExp(r'^\d{9}[VX]$');
    final newNIC = RegExp(r'^\d{12}$');
    if (!oldNIC.hasMatch(id) && !newNIC.hasMatch(id)) {
      setState(() => _error = 'Invalid NIC. Use 9 digits + V/X or 12 digits');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1208),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC9A84C), width: 2),
                    color: const Color(0xFF2C1810),
                  ),
                  child: Image.asset('assets/images/app_icon.png',
                    width: 80, height: 80,
                    errorBuilder: (c, e, s) => const Icon(Icons.museum, size: 80, color: Color(0xFFC9A84C)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('ArtSphere Guide',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                      color: Color(0xFFC9A84C), letterSpacing: 1.2)),
                const SizedBox(height: 8),
                const Text('Your Museum Experience Awaits',
                  style: TextStyle(fontSize: 14, color: Colors.white54)),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C1810),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF8B6914), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ticket Number',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                            color: Color(0xFFC9A84C))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ticketController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. TKT-2024-001',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.confirmation_number, color: Color(0xFFC9A84C)),
                          filled: true,
                          fillColor: const Color(0xFF1C1208),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF8B6914))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF8B6914))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('National ID Number (NIC)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                            color: Color(0xFFC9A84C))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _idController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. 123456789V or 200012345678',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.badge, color: Color(0xFFC9A84C)),
                          filled: true,
                          fillColor: const Color(0xFF1C1208),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF8B6914))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF8B6914))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 2)),
                          errorText: _error,
                          errorStyle: const TextStyle(color: Colors.redAccent),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC9A84C),
                            foregroundColor: const Color(0xFF1C1208),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Color(0xFF1C1208))
                              : const Text('Enter Museum',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Ticket available at the museum entrance',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
