import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

class AdminDetailSharedPref {
  static Future<void> setAccountId(String accountId) async {
    await SharedPreferencesHelper.preferences
        .setString("adminDetail_accountId", accountId);
  }

  static String getAccountId() {
    return SharedPreferencesHelper.preferences
            .getString("adminDetail_accountId") ??
        "";
  }

  static Future<void> clearAccountId() async {
    await SharedPreferencesHelper.preferences.remove("adminDetail_accountId");
  }
}
