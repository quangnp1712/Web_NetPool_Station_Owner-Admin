import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/model/verify_email_model.dart';

class VerfyEmailModelResponse extends BaseResponse {
  VerfyEmailModel? data;

  VerfyEmailModelResponse({
    this.data,
    status,
    success,
    errorCode,
    responseAt,
    message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data?.toMap(),
      'status': status,
      'success': success,
      'errorCode': errorCode,
      'responseAt': responseAt,
      'message': message,
    };
  }

  factory VerfyEmailModelResponse.fromMap(Map<String, dynamic> map) {
    return VerfyEmailModelResponse(
      data: map['data'] != null
          ? VerfyEmailModel.fromMap(map['data'] as Map<String, dynamic>)
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

  factory VerfyEmailModelResponse.fromJson(Map<String, dynamic> source) =>
      VerfyEmailModelResponse.fromMap(source);
}
