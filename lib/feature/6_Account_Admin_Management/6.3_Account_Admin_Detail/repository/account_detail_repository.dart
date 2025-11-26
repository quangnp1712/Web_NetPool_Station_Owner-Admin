import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/api/admin_detail_api.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/model/admin_detail_model.dart';

abstract class IAdminDetailRepository {
  Future<Map<String, dynamic>> getDetailAdmin(String accountId);

  Future<Map<String, dynamic>> updateAdmin(
      AdminDetailModel adminDetailModel, String accountId);

  Future<Map<String, dynamic>> updateStatusAdmin(
      String accountId, String status);
}

class AdminDetailRepository extends AdminDetailApi
    implements IAdminDetailRepository {
  @override
  Future<Map<String, dynamic>> getDetailAdmin(String accountId) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();
      Uri uri = Uri.parse("$AdminDetailUrl/$accountId");
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

  @override
  Future<Map<String, dynamic>> updateAdmin(
      AdminDetailModel adminDetailModel, String accountId) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();
      Uri uri = Uri.parse("$AdminDetailUpdateUrl/$accountId");
      final client = http.Client();
      final response = await client
          .put(
            uri,
            headers: {
              "Access-Control-Allow-Origin": "*",
              'Content-Type': 'application/json',
              'Accept': '*/*',
              'Authorization': 'Bearer $jwtToken',
            },
            body: adminDetailModel.toJson(),
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateStatusAdmin(
      String accountId, String status) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();
      Uri uri = Uri.parse("$AdminDetailUpdateUrl/$accountId/$status");
      final client = http.Client();
      final response = await client.patch(
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
