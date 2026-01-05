// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/1.station/station_detail_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

class StationDetailModelResponse extends BaseResponse {
  StationDetailModel? data;
  MetaModel? meta;

  StationDetailModelResponse({
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
      'data': data,
      'status': status,
      'success': success,
      'errorCode': errorCode,
      'responseAt': responseAt,
      'message': message,
    };
  }

  factory StationDetailModelResponse.fromMap(Map<String, dynamic> map) {
    return StationDetailModelResponse(
      data: map['data'] != null
          ? StationDetailModel.fromMap(map['data'] as Map<String, dynamic>)
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

  factory StationDetailModelResponse.fromJson(Map<String, dynamic> source) =>
      StationDetailModelResponse.fromMap(source);
}
