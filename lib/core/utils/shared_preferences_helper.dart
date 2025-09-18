import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _preferences;
  static SharedPreferencesHelper? _instance;

  // Private constructor
  SharedPreferencesHelper._();

  // Singleton instance
  static SharedPreferencesHelper get instance {
    _instance ??= SharedPreferencesHelper._();
    return _instance!;
  }

  // Initialize SharedPreferences
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Getter for SharedPreferences instance
  static SharedPreferences get preferences {
    return _preferences!;
  }
}
