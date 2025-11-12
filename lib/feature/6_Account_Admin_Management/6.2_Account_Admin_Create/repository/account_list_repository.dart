import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/api/admin_create_api.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/model/admin_create_model.dart';

abstract class IAdminCreateRepository {
  Future<Map<String, dynamic>> createAdmin(
      AdminCreateModel adminCreateModel, String stationId);
}

class AdminCreateRepository extends AdminCreateApi
    implements IAdminCreateRepository {
  @override
  Future<Map<String, dynamic>> createAdmin(
      AdminCreateModel adminCreateModel, String stationId) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();
      Uri uri = Uri.parse(AdminCreateUrl);
      final client = http.Client();
      final response = await client
          .post(
            uri,
            headers: {
              "Access-Control-Allow-Origin": "*",
              'Content-Type': 'application/json',
              'Accept': '*/*',
              'Authorization': 'Bearer $jwtToken',
            },
            body: adminCreateModel.toJson(),
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }
}
