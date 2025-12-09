import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AreaModel {
  int? areaId; // id
  int? stationSpaceId;
  int? price;
  String? areaCode; // code
  String? areaName; // name
  String? statusCode;
  String? statusName;

  // feild hỗ trợ
  String? spaceName;
  AreaModel({
    this.spaceName,
    this.areaId,
    this.stationSpaceId,
    this.price,
    this.areaCode,
    this.areaName,
    this.statusCode,
    this.statusName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'areaId': areaId,
      'stationSpaceId': stationSpaceId,
      'price': price,
      'areaCode': areaCode,
      'areaName': areaName,
      'statusCode': statusCode,
      'statusName': statusName,
    };
  }

  factory AreaModel.fromMap(Map<String, dynamic> map) {
    return AreaModel(
      areaId: map['areaId'] != null ? map['areaId'] as int : null,
      stationSpaceId:
          map['stationSpaceId'] != null ? map['stationSpaceId'] as int : null,
      price: map['price'] != null ? map['price'] as int : null,
      areaCode: map['areaCode'] != null ? map['areaCode'] as String : null,
      areaName: map['areaName'] != null ? map['areaName'] as String : null,
      statusCode:
          map['statusCode'] != null ? map['statusCode'] as String : null,
      statusName:
          map['statusName'] != null ? map['statusName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AreaModel.fromJson(Map<String, dynamic> source) =>
      AreaModel.fromMap(source);
}
