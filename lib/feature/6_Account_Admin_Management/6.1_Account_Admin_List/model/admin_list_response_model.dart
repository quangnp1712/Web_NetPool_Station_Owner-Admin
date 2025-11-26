// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/model/admin_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

class AdminListModelResponse extends BaseResponse {
  List<AdminListModel>? data;
  MetaModel? meta;

  AdminListModelResponse({
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

  factory AdminListModelResponse.fromMap(Map<String, dynamic> map) {
    return AdminListModelResponse(
      data: map['data'] != null
          ? List<AdminListModel>.from(
              (map['data'] as List).map(
                (x) => AdminListModel.fromMap(x as Map<String, dynamic>),
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

  factory AdminListModelResponse.fromJson(Map<String, dynamic> source) =>
      AdminListModelResponse.fromMap(source);
}
