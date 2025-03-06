import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  bool get isInitialized => _initialized;

  SharedPreferences get prefs {
    if (!_initialized) {
      throw StateError(
        'PreferencesService must be initialized before use. Call init() first.',
      );
    }
    return _prefs;
  }

  // Add convenience methods
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
}
