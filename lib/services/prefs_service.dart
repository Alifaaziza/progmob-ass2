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

  // ---------- PASSWORD ----------
  String get password => _prefs.getString('password') ?? '';

  Future<void> setPassword(String pass) async {
    await _prefs.setString('password', pass);
  }

  // ---------- DATA TERAKHIR ----------

  // Last app open time
  DateTime get lastAppOpen {
    final timestamp = _prefs.getInt('last_app_open') ?? 0;
    return timestamp == 0
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> setLastAppOpen(DateTime value) async {
    await _prefs.setInt('last_app_open', value.millisecondsSinceEpoch);
  }

  // Last sync time (bisa untuk future feature)
  DateTime get lastSyncTime {
    final timestamp = _prefs.getInt('last_sync_time') ?? 0;
    return timestamp == 0
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> setLastSyncTime(DateTime value) async {
    await _prefs.setInt('last_sync_time', value.millisecondsSinceEpoch);
  }

  // Sort preference
  String get sortPreference =>
      _prefs.getString('sort_preference') ?? 'updated_desc';

  Future<void> setSortPreference(String value) async {
    await _prefs.setString('sort_preference', value);
  }

  // ---------- CLEAR LOGIN ----------
  Future<void> clear() async {
    await _prefs.clear();
  }
}
