import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

//! Register - station owner !//
class RegisterSharedPref {
  static Future<void> setEmail(String email) async {
    await SharedPreferencesHelper.preferences.setString("email", email);
  }

  static String getEmail() {
    return SharedPreferencesHelper.preferences.getString("email") ?? "";
  }

  static Future<void> clearEmail() async {
    // Dùng remove() để xóa một key
    await SharedPreferencesHelper.preferences.remove("email");
  }
}
