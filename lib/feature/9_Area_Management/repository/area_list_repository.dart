import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/api/area_list_api.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_model.dart';

abstract class IAreaListRepository {
  Future<Map<String, dynamic>> getArea(
    String? search,
    String? stationId,
    String? spaceId,
    String? statusCodes,
    String? current,
    String? pageSize,
  );
  Future<Map<String, dynamic>> getDetailArea(String areaId);
  Future<Map<String, dynamic>> createArea(AreaModel areaModel);
  Future<Map<String, dynamic>> updateArea(
    String? areaId,
    AreaModel areaModel,
  );
  Future<Map<String, dynamic>> changeStatusArea(
    String? areaId,
    String? status,
  );
}

class AreaListRepository extends AreaListApi implements IAreaListRepository {
  @override
  Future<Map<String, dynamic>> getArea(
    String? search,
    String? stationId,
    String? spaceId,
    String? statusCodes,
    String? current,
    String? pageSize,
  ) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse(
          "$pubAreaUrl?search=$search&stationId=$stationId&spaceId=$spaceId&statusCodes=$statusCodes&current=$current&pageSize=$pageSize");
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

//! getDetailArea
  Future<Map<String, dynamic>> getDetailArea(String areaId) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse("$pubAreaUrl/$areaId");
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

//! createArea
  @override
  Future<Map<String, dynamic>> createArea(AreaModel areaModel) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse(apiAreaUrl);

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
            body: areaModel.toJson(),
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }

//! updateArea
  @override
  Future<Map<String, dynamic>> updateArea(
    String? areaId,
    AreaModel areaModel,
  ) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse("$apiAreaUrl/$areaId");
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
            body: areaModel.toJson(),
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }

//! changeStatusArea
  @override
  Future<Map<String, dynamic>> changeStatusArea(
    String? areaId,
    String? status,
  ) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();

      Uri uri = Uri.parse("$apiAreaUrl/$areaId/$status");

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
