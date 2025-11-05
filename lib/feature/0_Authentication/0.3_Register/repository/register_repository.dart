import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/api/register_api.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/model/register_model.dart';

//! Register - station owner !//
abstract class IRegisterRepository {
  Future<Map<String, dynamic>> register(RegisterModel registerModel);
}

class RegisterRepository extends RegisterApi implements IRegisterRepository {
  @override
  Future<Map<String, dynamic>> register(RegisterModel registerModel) async {
    try {
      Uri uri = Uri.parse(RegisterUrl);
      final client = http.Client();
      final response = await client
          .post(
            uri,
            headers: {
              "Access-Control-Allow-Origin": "*",
              'Content-Type': 'application/json',
              'Accept': '*/*',
            },
            body: registerModel.toJson(),
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }
}
