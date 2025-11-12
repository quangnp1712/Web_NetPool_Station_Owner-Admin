// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/7_Account_Player_Management/7.1_Account_List/model/account_list_model.dart';

class AccountListModelResponse extends BaseResponse {
  List<AccountListModel>? data;
  ACLMetaModel? meta;

  AccountListModelResponse({
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

  factory AccountListModelResponse.fromMap(Map<String, dynamic> map) {
    return AccountListModelResponse(
      data: map['data'] != null
          ? List<AccountListModel>.from(
              (map['data'] as List).map(
                (x) => AccountListModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      meta: map['meta'] != null
          ? ACLMetaModel.fromMap(map['meta'] as Map<String, dynamic>)
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

  factory AccountListModelResponse.fromJson(Map<String, dynamic> source) =>
      AccountListModelResponse.fromMap(source);
}

class ACLMetaModel {
  int? pageSize;
  int? current;
  int? total;
  ACLMetaModel({
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

  factory ACLMetaModel.fromMap(Map<String, dynamic> map) {
    return ACLMetaModel(
      pageSize: map['pageSize'] != null ? map['pageSize'] as int : null,
      current: map['current'] != null ? map['current'] as int : null,
      total: map['total'] != null ? map['total'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ACLMetaModel.fromJson(Map<String, dynamic> source) =>
      ACLMetaModel.fromMap(source);
}
