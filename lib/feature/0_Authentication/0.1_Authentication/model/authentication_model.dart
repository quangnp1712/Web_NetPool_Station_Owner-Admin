import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AuthenticationModel {
  int? accountId;
  String? email;
  String? roleCode;
  String? accessToken;
  String? accessExpiredAt;
  String? refreshToken;
  String? refreshExpiredAt;

  AuthenticationModel({
    this.accountId,
    this.email,
    this.roleCode,
    this.accessToken,
    this.accessExpiredAt,
    this.refreshToken,
    this.refreshExpiredAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accountId': accountId,
      'email': email,
      'roleCode': roleCode,
      'accessToken': accessToken,
      'accessExpiredAt': accessExpiredAt,
      'refreshToken': refreshToken,
      'refreshExpiredAt': refreshExpiredAt,
    };
  }

  factory AuthenticationModel.fromMap(Map<String, dynamic> map) {
    return AuthenticationModel(
      accountId: map['accountId'] != null ? map['accountId'] as int : null,
      email: map['email'] != null ? map['email'] as String : null,
      roleCode: map['roleCode'] != null ? map['roleCode'] as String : null,
      accessToken:
          map['accessToken'] != null ? map['accessToken'] as String : null,
      accessExpiredAt: map['accessExpiredAt'] != null
          ? map['accessExpiredAt'] as String
          : null,
      refreshToken:
          map['refreshToken'] != null ? map['refreshToken'] as String : null,
      refreshExpiredAt: map['refreshExpiredAt'] != null
          ? map['refreshExpiredAt'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthenticationModel.fromJson(Map<String, dynamic> source) =>
      AuthenticationModel.fromMap(source);
}
