import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/city_controller/city_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/city_controller/station_create_api.dart';

abstract class ICityRepository {
  Future<Map<String, dynamic>> getProvinces();
  Future<Map<String, dynamic>> getDistricts(int provinceCode);
  Future<Map<String, dynamic>> getCommunes(int districtCode);
}

class CityRepository extends CityApi implements ICityRepository {
  @override
  Future<Map<String, dynamic>> getProvinces() async {
    try {
      Uri uri = Uri.parse("$cityUrl/p/");
      final client = http.Client();
      final response = await client
          .get(
            uri,
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDistricts(int provinceCode) async {
    try {
      Uri uri = Uri.parse("$cityUrl/p/$provinceCode?depth=2");
      final client = http.Client();
      final response = await client
          .get(
            uri,
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getCommunes(int districtCode) async {
    try {
      Uri uri = Uri.parse("$cityUrl/d/$districtCode?depth=2");
      final client = http.Client();
      final response = await client
          .get(
            uri,
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }
}
