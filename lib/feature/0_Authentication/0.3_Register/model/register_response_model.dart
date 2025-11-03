import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/model/register_model.dart';

class RegisterModelResponse extends BaseResponse {
  RegisterModel? data;

  RegisterModelResponse({
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

  factory RegisterModelResponse.fromMap(Map<String, dynamic> map) {
    return RegisterModelResponse(
      data: map['data'] != null
          ? RegisterModel.fromMap(map['data'] as Map<String, dynamic>)
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

  factory RegisterModelResponse.fromJson(Map<String, dynamic> source) =>
      RegisterModelResponse.fromMap(source);
}
