// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Player_Management/1.1_Account_List/model/account_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.2_Account_Admin_Create/model/admin_create_model.dart';

class AdminCreateModelResponse extends BaseResponse {
  List<AdminCreateModel>? data;

  AdminCreateModelResponse({
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

  factory AdminCreateModelResponse.fromMap(Map<String, dynamic> map) {
    return AdminCreateModelResponse(
      data: map['data'] != null
          ? List<AdminCreateModel>.from(
              (map['data'] as List).map(
                (x) => AdminCreateModel.fromMap(x as Map<String, dynamic>),
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

  factory AdminCreateModelResponse.fromJson(Map<String, dynamic> source) =>
      AdminCreateModelResponse.fromMap(source);
}
