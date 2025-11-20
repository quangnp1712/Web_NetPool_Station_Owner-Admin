import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/api/landing_api.dart';

abstract class ILandingRepository {
  Future<Map<String, dynamic>> logout();
}

class LandingRepository extends LandingApi implements ILandingRepository {
  @override
  Future<Map<String, dynamic>> logout() async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse(LogoutUrl);
      final client = http.Client();
      final response = await client.post(
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
