import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/api/account_list_api.dart';

abstract class IAccountListRepository {
  Future<Map<String, dynamic>> listWithSearch(
      String? search,
      String? statusCodes,
      String? roleIds,
      String? sorter,
      String? current,
      String? pageSize,
      String? stationId);
}

class AccountListRepository extends AccountListApi
    implements IAccountListRepository {
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
          "$AccountListUrl/?search=$search&statusCodes=$statusCodes&roleIds=$roleIds&sorter=$sorter&current=$current&pageSize=$pageSize&stationId=$stationId");
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
