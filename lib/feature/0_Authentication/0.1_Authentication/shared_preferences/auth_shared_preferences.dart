import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

class AuthenticationPref {
  static Future<void> setAccountID(int accountId) async {
    await SharedPreferencesHelper.preferences.setInt("accountId", accountId);
  }

  static int getAcountId() {
    return SharedPreferencesHelper.preferences.getInt("accountId") ?? 0;
  }

  static Future<void> setAccessToken(String token) async {
    await SharedPreferencesHelper.preferences.setString("accessToken", token);
  }

  static String getAccessToken() {
    return SharedPreferencesHelper.preferences.getString("accessToken") ?? "";
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
}
