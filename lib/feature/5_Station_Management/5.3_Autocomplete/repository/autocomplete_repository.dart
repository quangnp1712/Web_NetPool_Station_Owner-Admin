import 'package:http/http.dart' as http;
import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';
import 'package:web_netpool_station_owner_admin/core/network/exceptions/exception_handlers.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/api/autocomplete_api.dart';

abstract class IAutocompleteRepository {
  Future<Map<String, dynamic>> autocomplete(String? address);
}

class AutocompleteRepository extends AutocompleteApi
    implements IAutocompleteRepository {
  @override
  Future<Map<String, dynamic>> autocomplete(String? address) async {
    try {
      Uri uri = Uri.parse("$AutocompleteUrl?address=$address");
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
