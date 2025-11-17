import 'package:flutter/material.dart';
import 'services/prefs_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SharedPreferences
  final prefs = PrefsService.instance;
  await prefs.init();

  runApp(const SimpleNotesApp());
}

class SimpleNotesApp extends StatelessWidget {
  const SimpleNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = PrefsService.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Simple Notes Login",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD2B48C),
          primary: const Color(0xFFB29470),
          secondary: const Color(0xFFF5E6CC),
        ),
      ),
      initialRoute: prefs.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}
