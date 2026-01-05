// ignore_for_file: non_constant_identifier_names

import 'package:web_netpool_station_owner_admin/core/network/api/api_endpoints.dart';

//! Station Detail !//
class StationDetailApi {
  //$ Station
  final String StationDetailPubUrl = "$domainUrl/v1/pub/stations";
  final String StationDetailApiUrl = "$domainUrl/v1/api/stations";

//$ Station Space
  final String stationSpaceUrl = "$domainUrl/v1/pub/station-spaces";

  //$ Platform Space
  final String viewSpaceUrl = "$domainUrl/v1/pub/spaces";

  //$ Area
  final String pubAreaUrl = "$domainUrl/v1/pub/areas";

  //$  Resouce
  final String pubResouceUrl = "$domainUrl/v1/pub/station-resources";
  final String apiResouceUrl = "$domainUrl/v1/api/station-resources";

  //$  Resouce Spec
  final String pubResouceSpecUrl = "$domainUrl/v1/pub/station-resources/specs";
  final String apiResouceSpecUrl = "$domainUrl/v1/api/station-resources/specs";
}
