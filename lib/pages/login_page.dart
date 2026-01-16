import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _hide = true;

  String? usernameError; // pesan error username
  String? passwordError; // pesan error password

  // ----------- VALIDASI USERNAME -----------
  void validateUsername(String value) {
    if (value.isEmpty) {
      usernameError = "Username tidak boleh kosong";
    } else if (!value.contains(RegExp(r'[A-Z]'))) {
      usernameError = "Harus ada minimal 1 huruf besar";
    } else {
      usernameError = null;
    }
    setState(() {});
  }

  // ----------- LOGIN -----------
  void _login() async {
    // Pastikan validasi tidak error
    validateUsername(_username.text);

    if (usernameError != null) {
      return; // Stop login kalau ada error
    }

    final prefs = PrefsService.instance;
    await prefs.setUsername(_username.text.trim());

    await prefs.setLoggedIn(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6CC),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Nickname",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C4033),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= USERNAME FIELD =================
              TextField(
                controller: _username,
                onChanged: validateUsername,
                decoration: InputDecoration(
                  labelText: "Username",
                  filled: true,
                  fillColor: const Color(0xFFFFF5E4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  errorText: usernameError,
                ),
              ),

              const SizedBox(height: 8),

          
              // ================= LOGIN BUTTON =================
              Center(
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB29470),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "save",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
