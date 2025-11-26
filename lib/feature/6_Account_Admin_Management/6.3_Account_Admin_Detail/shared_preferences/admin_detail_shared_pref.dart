import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

class AdminDetailSharedPref {
  static Future<void> setAccountId(String accountId) async {
    await SharedPreferencesHelper.preferences.setString("accountId", accountId);
  }

  static String getAccountId() {
    return SharedPreferencesHelper.preferences.getString("accountId") ?? "";
  }
}
