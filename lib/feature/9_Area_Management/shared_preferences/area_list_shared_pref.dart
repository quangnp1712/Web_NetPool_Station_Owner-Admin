import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

class AdminListSharedPref {
  static Future<void> setPassword(String password) async {
    await SharedPreferencesHelper.preferences.setString("password", password);
  }

  static String getPassword() {
    return SharedPreferencesHelper.preferences.getString("password") ?? "";
  }
}
