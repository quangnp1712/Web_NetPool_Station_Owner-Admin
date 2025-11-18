import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

class AuthenticationPref {
  static Future<void> setAccountID(int accountId) async {
    await SharedPreferencesHelper.preferences.setInt("accountId", accountId);
  }

  static int getAcountId() {
    return SharedPreferencesHelper.preferences.getInt("accountId") ?? 0;
  }

  static Future<void> setUsername(String username) async {
    await SharedPreferencesHelper.preferences.setString("username", username);
  }

  static String getUsername() {
    return SharedPreferencesHelper.preferences.getString("username") ?? "";
  }

  static Future<void> setAccessToken(String token) async {
    await SharedPreferencesHelper.preferences.setString("accessToken", token);
  }

  static String getAccessToken() {
    return SharedPreferencesHelper.preferences.getString("accessToken") ?? "";
  }

  static Future<void> setRoleCode(String role) async {
    await SharedPreferencesHelper.preferences.setString("role", role);
  }

  static String getRoleCode() {
    return SharedPreferencesHelper.preferences.getString("role") ?? "";
  }

  static Future<void> setAccessExpiredAt(String accessExpiredAt) async {
    await SharedPreferencesHelper.preferences
        .setString("accessExpiredAt", accessExpiredAt);
  }

  static String getAccessExpiredAt() {
    return SharedPreferencesHelper.preferences.getString("accessExpiredAt") ??
        "";
  }

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

  static Future<void> setStationsJson(List<String> stations) async {
    await SharedPreferencesHelper.preferences
        .setStringList("stations", stations);
  }

  static List<String> getStationsJson() {
    return SharedPreferencesHelper.preferences.getStringList("stations") ?? [];
  }
}
