import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.2_Staion_Create/api/station_create_api.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.2_Staion_Create/model/station_create_model.dart';

abstract class IStationCreateRepository {
  Future<Map<String, dynamic>> createStation(
      StationCreateModel StationCreateModel);
}

class StationCreateRepository extends StationCreateApi
    implements IStationCreateRepository {
  @override
  Future<Map<String, dynamic>> createStation(
      StationCreateModel StationCreateModel) async {
    try {
      final String jwtToken = AuthenticationPref.getAccessToken().toString();
      Uri uri = Uri.parse(StationCreateUrl);
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
            body: StationCreateModel.toJson(),
          )
          .timeout(const Duration(seconds: 180));
      return processResponse(response);
    } catch (e) {
      return ExceptionHandlers().getExceptionString(e);
    }
  }
}
