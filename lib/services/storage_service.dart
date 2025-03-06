import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String LAST_CITY_KEY = 'last_city';
  static const String THEME_MODE_KEY = 'is_dark_mode';
  static const String NOTIFICATION_INTERVAL_KEY = 'notification_interval';

  static final StorageService _instance = StorageService._internal();
  SharedPreferences? _prefs;
  bool _initialized = false;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<void> saveLastCity(String city) async {
    if (!_initialized) throw Exception('StorageService not initialized');
    await _prefs?.setString(LAST_CITY_KEY, city);
  }

  String? getLastCity() {
    if (!_initialized) return null;
    return _prefs?.getString(LAST_CITY_KEY);
  }

  Future<void> saveThemeMode(bool isDark) async {
    if (!_initialized) throw Exception('StorageService not initialized');
    await _prefs?.setBool(THEME_MODE_KEY, isDark);
  }

  bool getThemeMode() {
    if (!_initialized) return false;
    return _prefs?.getBool(THEME_MODE_KEY) ?? false;
  }

  Future<void> saveNotificationInterval(String interval) async {
    if (!_initialized) throw Exception('StorageService not initialized');
    await _prefs?.setString(NOTIFICATION_INTERVAL_KEY, interval);
  }

  String? getNotificationInterval() {
    if (!_initialized) return null;
    return _prefs?.getString(NOTIFICATION_INTERVAL_KEY);
  }
}
