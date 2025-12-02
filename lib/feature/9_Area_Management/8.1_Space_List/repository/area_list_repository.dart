import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/api/area_list_api.dart';

abstract class IAreaListRepository {
  Future<Map<String, dynamic>> getArea(
    String? search,
    String? stationId,
    String? spaceId,
    String? statusCodes,
    String? current,
    String? pageSize,
  );
}

class AreaListRepository extends AreaListApi implements IAreaListRepository {
  @override
  Future<Map<String, dynamic>> getArea(
    String? search,
    String? stationId,
    String? spaceId,
    String? statusCodes,
    String? current,
    String? pageSize,
  ) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse(
          "$AreaListUrl?search=$search&stationId=$stationId&spaceId=$spaceId&statusCodes=$statusCodes&current=$current&pageSize=$pageSize");
      final client = http.Client();
      final response = await client.get(
        uri,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authorization': 'Bearer $jwtToken',
        },
      ).timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }
}
