import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class PlatformSpaceModel {
  int? spaceId;
  String? typeCode;
  String? typeName;
  String? statusCode;
  String? statusName;
  String? description;
  SpaceMetaDataModel? metadata;

  PlatformSpaceModel({
    this.spaceId,
    this.typeCode,
    this.typeName,
    this.statusCode,
    this.statusName,
    this.description,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'spaceId': spaceId,
      'typeCode': typeCode,
      'typeName': typeName,
      'statusCode': statusCode,
      'statusName': statusName,
      'description': description,
      'metadata': metadata?.toMap(),
    };
  }

  factory PlatformSpaceModel.fromMap(Map<String, dynamic> map) {
    return PlatformSpaceModel(
      spaceId: map['spaceId'] != null ? map['spaceId'] as int : null,
      typeCode: map['typeCode'] != null ? map['typeCode'] as String : null,
      typeName: map['typeName'] != null ? map['typeName'] as String : null,
      statusCode:
          map['statusCode'] != null ? map['statusCode'] as String : null,
      statusName:
          map['statusName'] != null ? map['statusName'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      metadata: map['metadata'] != null
          ? SpaceMetaDataModel.fromMap(map['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlatformSpaceModel.fromJson(Map<String, dynamic> source) =>
      PlatformSpaceModel.fromMap(source);

  // Clone method để copy object
  PlatformSpaceModel copyWith({
    int? spaceId,
    String? typeCode,
    String? typeName,
    String? statusCode,
    String? statusName,
    String? description,
    SpaceMetaDataModel? metadata,
  }) {
    return PlatformSpaceModel(
      spaceId: spaceId ?? this.spaceId,
      typeCode: typeCode ?? this.typeCode,
      typeName: typeName ?? this.typeName,
      statusCode: statusCode ?? this.statusCode,
      statusName: statusName ?? this.statusName,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }
}

class SpaceMetaDataModel {
  String? icon;
  String? bgColor;
  SpaceMetaDataModel({
    this.icon,
    this.bgColor,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'icon': icon,
      'bgColor': bgColor,
    };
  }

  factory SpaceMetaDataModel.fromMap(Map<String, dynamic> map) {
    return SpaceMetaDataModel(
      icon: map['icon'] != null ? map['icon'] as String : null,
      bgColor: map['bgColor'] != null ? map['bgColor'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SpaceMetaDataModel.fromJson(Map<String, dynamic> source) =>
      SpaceMetaDataModel.fromMap(source);
}
