// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

class ResoucreListModelResponse extends BaseResponse {
  List<StationResourceModel>? data;
  MetaModel? meta;

  ResoucreListModelResponse({
    this.data,
    this.meta,
    status,
    success,
    errorCode,
    responseAt,
    message,
  });

  factory ResoucreListModelResponse.fromMap(Map<String, dynamic> map) {
    return ResoucreListModelResponse(
      data: map['data'] != null
          ? List<StationResourceModel>.from(
              (map['data'] as List).map(
                (x) => StationResourceModel.fromMap(x as Map<String, dynamic>),
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

  factory ResoucreListModelResponse.fromJson(Map<String, dynamic> source) =>
      ResoucreListModelResponse.fromMap(source);
}
