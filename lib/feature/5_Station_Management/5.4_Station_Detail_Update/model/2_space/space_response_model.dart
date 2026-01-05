// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/2_space/space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

class SpaceListModelResponse extends BaseResponse {
  List<PlatformSpaceModel>? data;
  MetaModel? meta;

  SpaceListModelResponse({
    this.data,
    this.meta,
    status,
    success,
    errorCode,
    responseAt,
    message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data?.map((x) => x.toMap()).toList(),
      'status': status,
      'success': success,
      'errorCode': errorCode,
      'responseAt': responseAt,
      'message': message,
    };
  }

  factory SpaceListModelResponse.fromMap(Map<String, dynamic> map) {
    return SpaceListModelResponse(
      data: map['data'] != null
          ? List<PlatformSpaceModel>.from(
              (map['data'] as List).map(
                (x) => PlatformSpaceModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      meta: map['meta'] != null
          ? MetaModel.fromMap(map['meta'] as Map<String, dynamic>)
          : null,
      status: map['status'] != null ? map['status'] as String : null,
      success: map['success'] != null ? map['success'] as bool : null,
      errorCode: map['errorCode'] as dynamic,
      responseAt:
          map['responseAt'] != null ? map['responseAt'] as String : null,
      message: map['message'] != null ? map['message'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SpaceListModelResponse.fromJson(Map<String, dynamic> source) =>
      SpaceListModelResponse.fromMap(source);
}

class SpaceListMetaModel {
  int? pageSize;
  int? current;
  int? total;
  SpaceListMetaModel({
    this.pageSize,
    this.current,
    this.total,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pageSize': pageSize,
      'current': current,
      'total': total,
    };
  }

  factory SpaceListMetaModel.fromMap(Map<String, dynamic> map) {
    return SpaceListMetaModel(
      pageSize: map['pageSize'] != null ? map['pageSize'] as int : null,
      current: map['current'] != null ? map['current'] as int : null,
      total: map['total'] != null ? map['total'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SpaceListMetaModel.fromJson(Map<String, dynamic> source) =>
      SpaceListMetaModel.fromMap(source);
}
