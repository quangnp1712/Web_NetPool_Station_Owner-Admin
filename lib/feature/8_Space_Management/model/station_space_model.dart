import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/space_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class StationSpaceModel {
  int? stationSpaceId;
  int? stationId;
  int? spaceId;
  String? spaceCode;
  String? spaceName;
  int? capacity;
  String? statusCode;
  String? statusName;
  SpaceMetaDataModel? metadata;

  // bổ sung
  PlatformSpaceModel? space;

  // contruction
  StationSpaceModel({
    this.stationSpaceId,
    this.stationId,
    this.spaceId,
    this.spaceCode,
    this.spaceName,
    this.capacity,
    this.statusCode,
    this.statusName,
    this.space,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stationId': stationId,
      'spaceId': spaceId,
      'spaceCode': spaceCode,
      'spaceName': spaceName,
      'capacity': capacity,
      'metadata': metadata?.toMap(),
    };
  }

  factory StationSpaceModel.fromMap(Map<String, dynamic> map) {
    return StationSpaceModel(
      stationSpaceId:
          map['stationSpaceId'] != null ? map['stationSpaceId'] as int : null,
      stationId: map['stationId'] != null ? map['stationId'] as int : null,
      spaceId: map['spaceId'] != null ? map['spaceId'] as int : null,
      spaceCode: map['spaceCode'] != null ? map['spaceCode'] as String : null,
      spaceName: map['spaceName'] != null ? map['spaceName'] as String : null,
      capacity: map['capacity'] != null ? map['capacity'] as int : null,
      statusCode:
          map['statusCode'] != null ? map['statusCode'] as String : null,
      statusName:
          map['statusName'] != null ? map['statusName'] as String : null,
      metadata: map['metadata'] != null
          ? SpaceMetaDataModel.fromMap(map['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StationSpaceModel.fromJson(Map<String, dynamic> source) =>
      StationSpaceModel.fromMap(source);

  StationSpaceModel copyWith({
    int? stationSpaceId,
    int? stationId,
    int? spaceId,
    String? spaceCode,
    String? spaceName,
    int? capacity,
    String? statusCode,
    String? statusName,
    PlatformSpaceModel? space,
    SpaceMetaDataModel? metadata,
  }) {
    return StationSpaceModel(
      stationSpaceId: stationSpaceId ?? this.stationSpaceId,
      stationId: stationId ?? this.stationId,
      spaceId: spaceId ?? this.spaceId,
      spaceCode: spaceCode ?? this.spaceCode,
      spaceName: spaceName ?? this.spaceName,
      capacity: capacity ?? this.capacity,
      statusCode: statusCode ?? this.statusCode,
      statusName: statusName ?? this.statusName,
      space: space ?? this.space,
      metadata: metadata ?? this.metadata,
    );
  }
}
