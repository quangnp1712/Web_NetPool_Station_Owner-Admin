// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/3_area/area_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

class AreaListModelResponse extends BaseResponse {
  List<AreaModel>? data;
  MetaModel? meta;

  AreaListModelResponse({
    this.data,
    this.meta,
    status,
    success,
    errorCode,
    responseAt,
    message,
  });

  factory AreaListModelResponse.fromMap(Map<String, dynamic> map) {
    return AreaListModelResponse(
      data: map['data'] != null
          ? List<AreaModel>.from(
              (map['data'] as List).map(
                (x) => AreaModel.fromMap(x as Map<String, dynamic>),
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

  factory AreaListModelResponse.fromJson(Map<String, dynamic> source) =>
      AreaListModelResponse.fromMap(source);
}
