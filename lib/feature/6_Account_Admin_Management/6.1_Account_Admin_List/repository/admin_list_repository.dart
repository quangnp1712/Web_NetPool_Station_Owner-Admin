import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/api/admin_list_api.dart';

abstract class IAdminListRepository {
  Future<Map<String, dynamic>> listWithSearch(
      String? search,
      String? statusCodes,
      String? roleIds,
      String? sorter,
      String? current,
      String? pageSize,
      String? stationId);
}

class AdminListRepository extends AdminListApi implements IAdminListRepository {
  @override
  Future<Map<String, dynamic>> listWithSearch(
      String? search,
      String? statusCodes,
      String? roleIds,
      String? sorter,
      String? current,
      String? pageSize,
      String? stationId) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse(
          "$AdminListUrl?search=$search&statusCodes=$statusCodes&roleIds=$roleIds&sorter=$sorter&current=$current&pageSize=$pageSize&stationId=$stationId");
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
