import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';

class StationDetailSharedPref {
  static Future<void> setStationId(String stationId) async {
    await SharedPreferencesHelper.preferences.setString("stationId", stationId);
  }

  static String getStationId() {
    return SharedPreferencesHelper.preferences.getString("stationId") ?? "";
  }

  static Future<void> clearStationId() async {
    await SharedPreferencesHelper.preferences.remove("stationId");
  }
}
