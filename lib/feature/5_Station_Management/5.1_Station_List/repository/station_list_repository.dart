import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/api/station_list_api.dart';

abstract class IStationListRepository {
  Future<Map<String, dynamic>> listWithSearch(
    String? search,
    String? province,
    String? commune,
    String? district,
    String? statusCodes,
    String? current,
    String? pageSize,
  );
}

class StationListRepository extends StationListApi
    implements IStationListRepository {
  @override
  Future<Map<String, dynamic>> listWithSearch(
    String? search,
    String? province,
    String? commune,
    String? district,
    String? statusCodes,
    String? current,
    String? pageSize,
  ) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse(
          "$StationListUrl?search=$search&province=$province&commune=$commune&district=$district&statusCodes=$statusCodes&current=$current&pageSize=$pageSize");
      final client = http.Client();
      final response = await client.get(
        uri,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authorization': 'Bearer $jwtToken',
        },
      ).timeout(const Duration(seconds: 140));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }
}
