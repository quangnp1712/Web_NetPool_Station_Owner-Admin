import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/api/authentication_api.dart';
import 'package:http/http.dart' as http;

abstract class IAuthenticationRepository {
  Future<Map<String, dynamic>> listStationStationOwner(int accountId);
}

class AuthenticationRepository extends AuthenticationApi
    implements IAuthenticationRepository {
  @override
  Future<Map<String, dynamic>> listStationStationOwner(int accountId) async {
    try {
      Uri uri = Uri.parse("$FindDetailUrl/$accountId");
      final client = http.Client();
      final response = await client.get(
        uri,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }
}
