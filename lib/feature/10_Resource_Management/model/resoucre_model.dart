import 'dart:convert';

import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_spec_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class StationResourceModel {
  // model
  int? stationResourceId;
  int? areaId;
  ResourceSpecModel? spec;
  String? resourceName;
  String? resourceCode;
  String? typeCode;
  String? typeName;
  String? allowDirectPayment;
  String? statusCode;
  String? statusName;

  StationResourceModel({
    this.stationResourceId,
    this.areaId,
    this.spec,
    this.resourceCode,
    this.resourceName,
    this.typeCode,
    this.typeName,
    this.allowDirectPayment,
    this.statusCode,
    this.statusName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stationResourceId': stationResourceId,
      'areaId': areaId,
      'spec': spec?.toMap(),
      'resourceCode': resourceCode,
      'resourceName': resourceName,
      'typeCode': typeCode,
      'typeName': typeName,
      'allowDirectPayment': allowDirectPayment,
      'statusCode': statusCode,
      'statusName': statusName,
    };
  }

  factory StationResourceModel.fromMap(Map<String, dynamic> map) {
    return StationResourceModel(
      stationResourceId: map['stationResourceId'] != null
          ? map['stationResourceId'] as int
          : null,
      areaId: map['areaId'] != null ? map['areaId'] as int : null,
      spec: map['spec'] != null
          ? ResourceSpecModel.fromMap(map['spec'] as Map<String, dynamic>)
          : null,
      resourceCode:
          map['resourceCode'] != null ? map['resourceCode'] as String : null,
      resourceName:
          map['resourceName'] != null ? map['resourceName'] as String : null,
      typeCode: map['typeCode'] != null ? map['typeCode'] as String : null,
      typeName: map['typeName'] != null ? map['typeName'] as String : null,
      allowDirectPayment: map['allowDirectPayment'] != null
          ? map['allowDirectPayment'] as String
          : null,
      statusCode:
          map['statusCode'] != null ? map['statusCode'] as String : null,
      statusName:
          map['statusName'] != null ? map['statusName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StationResourceModel.fromJson(Map<String, dynamic> source) =>
      StationResourceModel.fromMap(source);

  StationResourceModel copyWith({
    int? stationResourceId,
    int? areaId,
    ResourceSpecModel? spec,
    String? resourceCode,
    String? resourceName,
    String? typeCode,
    String? typeName,
    String? allowDirectPayment,
    String? statusCode,
    String? statusName,
  }) {
    return StationResourceModel(
      stationResourceId: stationResourceId ?? this.stationResourceId,
      areaId: areaId ?? this.areaId,
      spec: spec ?? this.spec,
      resourceCode: resourceCode ?? this.resourceCode,
      resourceName: resourceName ?? this.resourceName,
      typeCode: typeCode ?? this.typeCode,
      typeName: typeName ?? this.typeName,
      allowDirectPayment: allowDirectPayment ?? this.allowDirectPayment,
      statusCode: statusCode ?? this.statusCode,
      statusName: statusName ?? this.statusName,
    );
  }
}
