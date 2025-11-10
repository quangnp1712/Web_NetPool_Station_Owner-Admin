import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

class LandingPageSharedPref {
  static Future<void> setRoleName(String roleName) async {
    await SharedPreferencesHelper.preferences.setString("roleName", roleName);
  }

  static String getRoleName() {
    return SharedPreferencesHelper.preferences.getString("roleName") ?? "";
  }

  static Future<void> setUsernam(String username) async {
    await SharedPreferencesHelper.preferences.setString("username", username);
  }

  static String getUsername() {
    return SharedPreferencesHelper.preferences.getString("username") ?? "";
  }

  static Future<void> setActiveStation(String stationId) async {
    await SharedPreferencesHelper.preferences.setString("stationId", stationId);
  }

  static String getActiveStation() {
    return SharedPreferencesHelper.preferences.getString("stationId") ?? "";
  }
}
