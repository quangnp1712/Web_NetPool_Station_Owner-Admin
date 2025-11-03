import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/api/login_api.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/model/login_model.dart';
import 'package:http/http.dart' as http;

abstract class ILoginRepository {
  Future<Map<String, dynamic>> login(LoginModel loginModel);
}

class LoginRepository extends LoginApi implements ILoginRepository {
  @override
  Future<Map<String, dynamic>> login(LoginModel loginModel) async {
    try {
      Uri uri = Uri.parse(LoginUrl);
      final client = http.Client();
      final response = await client
          .post(
            uri,
            headers: {
              "Access-Control-Allow-Origin": "*",
              'Content-Type': 'application/json',
              'Accept': '*/*',
            },
            body: loginModel.toJson(),
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }
}
