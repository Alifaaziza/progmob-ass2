import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/prefs_service.dart';
import 'services/database_service.dart';

import 'providers/home_provider.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';

ValueNotifier<bool> themeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = PrefsService.instance;
  await prefs.init();

  themeNotifier.value = prefs.isDarkMode;

  final database = DatabaseService();
  await database.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const SimpleNotesApp(),
    ),
  );
}

class SimpleNotesApp extends StatelessWidget {
  const SimpleNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = PrefsService.instance;

    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Simple Notes Login",
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

          /// LIGHT MODE
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD2B48C),
            ),
          ),

          /// DARK MODE
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
