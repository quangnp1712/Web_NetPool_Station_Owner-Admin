// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/model/admin_detail_model.dart';

class AdminDetailModelResponse extends BaseResponse {
  AdminDetailModel? data;

  AdminDetailModelResponse({
    this.data,
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

  factory AdminDetailModelResponse.fromMap(Map<String, dynamic> map) {
    return AdminDetailModelResponse(
      data: map['data'] != null
          ? AdminDetailModel.fromMap(map['data'] as Map<String, dynamic>)
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

  factory AdminDetailModelResponse.fromJson(Map<String, dynamic> source) =>
      AdminDetailModelResponse.fromMap(source);
}
