import 'package:flutter/material.dart';
import 'services/prefs_service.dart';
import 'services/database_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

// CONTROLLER GLOBAL UNTUK TEMA
ValueNotifier<bool> themeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = PrefsService.instance;
  await prefs.init();

  // masukan pilihan dark mode dari prefs ke notifier
  themeNotifier.value = prefs.isDarkMode;

  final database = DatabaseService();
  await database.database;

  runApp(SimpleNotesApp());
}

class SimpleNotesApp extends StatelessWidget {
  SimpleNotesApp({super.key});
  final prefs = PrefsService.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Simple Notes Login",
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // ---- LIGHT MODE ----
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD2B48C),
            ),
          ),

          // ---- DARK MODE ----
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.brown,
              brightness: Brightness.dark,
            ),
          ),

          initialRoute: prefs.isLoggedIn ? '/home' : '/login',
          routes: {
            '/login': (_) => const LoginPage(),
            '/home': (_) => const HomePage(),
          },
        );
      },
    );
  }
}
