import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/feature/Common/role/api/role_api.dart';

abstract class IRoleRepository {
  Future<Map<String, dynamic>> roles();
}

class RoleRepository extends RoleApi implements IRoleRepository {
  @override
  Future<Map<String, dynamic>> roles() async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse(RoleUrl);
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
