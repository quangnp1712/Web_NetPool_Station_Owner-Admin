import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/api/station_detail_api.dart';

abstract class IStationDetailRepository {
  Future<Map<String, dynamic>> findDetailStation(String stationId);
}

class StationDetailRepository extends StationDetailApi
    implements IStationDetailRepository {
  @override
  Future<Map<String, dynamic>> findDetailStation(String stationId) async {
    try {
      Uri uri = Uri.parse("$StationDetailUrl/$stationId");
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
