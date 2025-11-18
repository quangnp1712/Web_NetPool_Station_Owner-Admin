// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/account_info_model.dart';

class AccountInfoModelResponse extends BaseResponse {
  AccountInfoModel? data;

  AccountInfoModelResponse({
    this.data,
    status,
    success,
    errorCode,
    responseAt,
    message,
  });

  factory AccountInfoModelResponse.fromMap(Map<String, dynamic> map) {
    return AccountInfoModelResponse(
      data: map['data'] != null
          ? AccountInfoModel.fromMap(map['data'] as Map<String, dynamic>)
          : null,
      status: map['status'] != null ? map['status'] as String : null,
      success: map['success'] != null ? map['success'] as bool : null,
      errorCode: map['errorCode'] as dynamic,
      responseAt:
          map['responseAt'] != null ? map['responseAt'] as String : null,
      message: map['message'] != null ? map['message'] as String : null,
    );
  }

  factory AccountInfoModelResponse.fromJson(Map<String, dynamic> source) =>
      AccountInfoModelResponse.fromMap(source);
}
