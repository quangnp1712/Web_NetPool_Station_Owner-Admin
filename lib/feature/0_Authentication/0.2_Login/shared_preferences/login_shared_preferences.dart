import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

class LoginPref {
  static Future<void> setPassword(String password) async {
    await SharedPreferencesHelper.preferences.setString("password", password);
  }

  static String getPassword() {
    return SharedPreferencesHelper.preferences.getString("password") ?? "";
  }

  static Future<void> setEmail(String email) async {
    await SharedPreferencesHelper.preferences.setString("email", email);
  }

  static String getEmail() {
    return SharedPreferencesHelper.preferences.getString("email") ?? "";
  }
}
