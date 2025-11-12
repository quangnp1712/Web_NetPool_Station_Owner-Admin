// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.2_Staion_Create/model/station_create_model.dart';

class StationCreateModelResponse extends BaseResponse {
  List<StationCreateModel>? data;
  StationCreateMetaModel? meta;

  StationCreateModelResponse({
    this.data,
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

  factory StationCreateModelResponse.fromMap(Map<String, dynamic> map) {
    return StationCreateModelResponse(
      data: map['data'] != null
          ? List<StationCreateModel>.from(
              (map['data'] as List).map(
                (x) => StationCreateModel.fromMap(x as Map<String, dynamic>),
              ),
            )
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

  factory StationCreateModelResponse.fromJson(Map<String, dynamic> source) =>
      StationCreateModelResponse.fromMap(source);
}

class StationCreateMetaModel {
  int? pageSize;
  int? current;
  int? total;
  StationCreateMetaModel({
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

  factory StationCreateMetaModel.fromMap(Map<String, dynamic> map) {
    return StationCreateMetaModel(
      pageSize: map['pageSize'] != null ? map['pageSize'] as int : null,
      current: map['current'] != null ? map['current'] as int : null,
      total: map['total'] != null ? map['total'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StationCreateMetaModel.fromJson(Map<String, dynamic> source) =>
      StationCreateMetaModel.fromMap(source);
}
