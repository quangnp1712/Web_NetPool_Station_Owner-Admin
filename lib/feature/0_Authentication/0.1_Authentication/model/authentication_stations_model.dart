import 'dart:convert';

class AuthStationsModel {
  String? stationId;
  String? stationCode;
  String? stationName;
  String? statusCode;
  String? statusName;
  AuthStationsModel({
    this.stationId,
    this.stationCode,
    this.stationName,
    this.statusCode,
    this.statusName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stationId': stationId,
      'stationCode': stationCode,
      'stationName': stationName,
    };
  }

  factory AuthStationsModel.fromMap(Map<String, dynamic> map) {
    return AuthStationsModel(
      stationId: map['stationId'] != null ? map['stationId'] as String : null,
      stationCode:
          map['stationCode'] != null ? map['stationCode'] as String : null,
      stationName:
          map['stationName'] != null ? map['stationName'] as String : null,
      statusCode:
          map['statusCode'] != null ? map['statusCode'] as String : null,
      statusName:
          map['statusName'] != null ? map['statusName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthStationsModel.fromJson(Map<String, dynamic> source) =>
      AuthStationsModel.fromMap(source);
}
