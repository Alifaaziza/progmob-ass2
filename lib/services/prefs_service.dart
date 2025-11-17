import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final PrefsService instance = PrefsService._internal();
  PrefsService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------- LOGIN STATUS ----------
  bool get isLoggedIn => _prefs.getBool('logged_in') ?? false;

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('logged_in', value);
  }

  // ---------- USERNAME ----------
  String get username => _prefs.getString('username') ?? '';

  Future<void> setUsername(String name) async {
    await _prefs.setString('username', name);
  }

  // ---------- PASSWORD (baru!) ----------
  String get password => _prefs.getString('password') ?? '';

  Future<void> setPassword(String pass) async {
    await _prefs.setString('password', pass);
  }

  // ---------- CLEAR LOGIN ----------
  Future<void> clear() async {
    await _prefs.clear();
  }
}
