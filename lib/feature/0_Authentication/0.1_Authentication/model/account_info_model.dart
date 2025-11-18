import 'dart:convert';

import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_stations_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class AccountInfoModel {
  int? accountId;
  int? roleId;

  String? avatar;
  String? username;
  String? identification;
  String? phone;
  String? email;
  String? statusCode;
  String? statusName;
  String? roleCode;
  String? accessToken;
  String? accessExpiredAt;
  String? refreshToken;
  String? refreshExpiredAt;
  List<AuthStationsModel>? stations;
  AccountInfoModel({
    this.accountId,
    this.roleId,
    this.avatar,
    this.username,
    this.identification,
    this.phone,
    this.email,
    this.statusCode,
    this.statusName,
    this.roleCode,
    this.accessToken,
    this.accessExpiredAt,
    this.refreshToken,
    this.refreshExpiredAt,
    this.stations,
  });

  factory AccountInfoModel.fromMap(Map<String, dynamic> map) {
    return AccountInfoModel(
      accountId: map['accountId'] != null ? map['accountId'] as int : null,
      roleId: map['roleId'] != null ? map['roleId'] as int : null,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      username: map['username'] != null ? map['username'] as String : null,
      identification: map['identification'] != null
          ? map['identification'] as String
          : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      statusCode:
          map['statusCode'] != null ? map['statusCode'] as String : null,
      statusName:
          map['statusName'] != null ? map['statusName'] as String : null,
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
      stations: map['stations'] != null
          ? List<AuthStationsModel>.from(
              (map['stations'] as List).map(
                (x) => AuthStationsModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  factory AccountInfoModel.fromJson(Map<String, dynamic> source) =>
      AccountInfoModel.fromMap(source);
}
