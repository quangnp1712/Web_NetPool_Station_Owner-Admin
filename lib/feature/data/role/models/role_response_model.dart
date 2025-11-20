import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/role/models/role_model.dart';

class RoleModelResponse extends BaseResponse {
  List<RoleModel>? data;

  RoleModelResponse({
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

  factory RoleModelResponse.fromMap(Map<String, dynamic> map) {
    return RoleModelResponse(
      data: map['data'] != null
          ? List<RoleModel>.from(
              (map['data'] as List).map(
                (x) => RoleModel.fromMap(x as Map<String, dynamic>),
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

  factory RoleModelResponse.fromJson(Map<String, dynamic> source) =>
      RoleModelResponse.fromMap(source);
}
