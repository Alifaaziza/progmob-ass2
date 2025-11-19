import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final PrefsService instance = PrefsService._internal();
  PrefsService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // LOGIN
  bool get isLoggedIn => _prefs.getBool('logged_in') ?? false;
  Future<void> setLoggedIn(bool value) async =>
      await _prefs.setBool('logged_in', value);

  // USERNAME
  String get username => _prefs.getString('username') ?? '';
  Future<void> setUsername(String value) async =>
      await _prefs.setString('username', value);

  // PASSWORD 
  String get password => _prefs.getString('password') ?? '';
  Future<void> setPassword(String value) async =>
      await _prefs.setString('password', value);

  // LAST APP OPEN 
  DateTime get lastAppOpen {
    final ts = _prefs.getInt('last_app_open') ?? 0;
    return ts == 0 ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(ts);
  }

  Future<void> setLastAppOpen(DateTime value) async =>
      await _prefs.setInt('last_app_open', value.millisecondsSinceEpoch);

  // SORT PREFERENCE 
  String get sortPreference =>
      _prefs.getString('sort_preference') ?? 'updated_desc';

  Future<void> setSortPreference(String value) async =>
      await _prefs.setString('sort_preference', value);

  // DARK MODE 
  bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;

  Future<void> setDarkMode(bool value) async =>
      await _prefs.setBool('dark_mode', value);

  // CLEAR 
  Future<void> clear() async {
    await _prefs.clear();
  }
}
