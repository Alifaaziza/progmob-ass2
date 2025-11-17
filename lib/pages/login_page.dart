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

  String? usernameError;   // pesan error username
  String? passwordError;   // pesan error password

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

  // ----------- VALIDASI PASSWORD -----------
  void validatePassword(String value) {
    if (value.isEmpty) {
      passwordError = "Password tidak boleh kosong";
    } else if (value.length < 6) {
      passwordError = "Minimal 6 karakter";
    } else {
      passwordError = null;
    }
    setState(() {});
  }

  // ----------- LOGIN -----------
  void _login() async {
    // Pastikan validasi tidak error
    validateUsername(_username.text);
    validatePassword(_password.text);

    if (usernameError != null || passwordError != null) {
      return; // Stop login kalau ada error
    }

    final prefs = PrefsService.instance;
    await prefs.setUsername(_username.text.trim());
    await prefs.setPassword(_password.text.trim());
    await prefs.setLoggedIn(true);

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
                color: Colors.brown.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Login",
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

              // ================= PASSWORD FIELD =================
              TextField(
                controller: _password,
                obscureText: _hide,
                onChanged: validatePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: const Color(0xFFFFF5E4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_hide
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _hide = !_hide),
                  ),
                  errorText: passwordError,
                ),
              ),

              const SizedBox(height: 24),

              // ================= LOGIN BUTTON =================
              Center(
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB29470),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
