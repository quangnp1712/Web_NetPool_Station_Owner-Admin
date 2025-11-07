// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/2_Station_Management/2.1_Station_List/model/station_list_model.dart';

class StationListModelResponse extends BaseResponse {
  List<StationListModel>? data;
  StationListMetaModel? meta;

  StationListModelResponse({
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

  factory StationListModelResponse.fromMap(Map<String, dynamic> map) {
    return StationListModelResponse(
      data: map['data'] != null
          ? List<StationListModel>.from(
              (map['data'] as List).map(
                (x) => StationListModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      meta: map['meta'] != null
          ? StationListMetaModel.fromMap(map['meta'] as Map<String, dynamic>)
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

  factory StationListModelResponse.fromJson(Map<String, dynamic> source) =>
      StationListModelResponse.fromMap(source);
}

class StationListMetaModel {
  int? pageSize;
  int? current;
  int? total;
  StationListMetaModel({
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

  factory StationListMetaModel.fromMap(Map<String, dynamic> map) {
    return StationListMetaModel(
      pageSize: map['pageSize'] != null ? map['pageSize'] as int : null,
      current: map['current'] != null ? map['current'] as int : null,
      total: map['total'] != null ? map['total'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StationListMetaModel.fromJson(Map<String, dynamic> source) =>
      StationListMetaModel.fromMap(source);
}
