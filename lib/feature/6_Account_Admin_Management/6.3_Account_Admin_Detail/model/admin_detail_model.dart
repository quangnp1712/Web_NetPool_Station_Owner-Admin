import 'dart:convert';

import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_stations_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class AdminDetailModel {
  int? accountId;
  int? roleId;
  String? avatar;
  String? username;
  String? password;
  String? identification;
  String? phone;
  String? email;
  String? statusCode;
  String? statusName;
  List<AuthStationsModel>? stations;

  AdminDetailModel({
    this.accountId,
    this.roleId,
    this.avatar,
    this.username,
    this.password,
    this.identification,
    this.phone,
    this.email,
    this.statusCode,
    this.statusName,
    this.stations,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accountId': accountId,
      'roleId': roleId,
      'avatar': avatar,
      'username': username,
      'password': password,
      'identification': identification,
      'phone': phone,
      'email': email,
      'statusCode': statusCode,
      'statusName': statusName,
    };
  }

  factory AdminDetailModel.fromMap(Map<String, dynamic> map) {
    return AdminDetailModel(
      accountId: map['accountId'] != null ? map['accountId'] as int : null,
      roleId: map['roleId'] != null ? map['roleId'] as int : null,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      username: map['username'] != null ? map['username'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      identification: map['identification'] != null
          ? map['identification'] as String
          : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      statusCode:
          map['statusCode'] != null ? map['statusCode'] as String : null,
      statusName:
          map['statusName'] != null ? map['statusName'] as String : null,
      stations: map['stations'] != null
          ? List<AuthStationsModel>.from(
              (map['stations'] as List).map(
                (x) => AuthStationsModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AdminDetailModel.fromJson(Map<String, dynamic> source) =>
      AdminDetailModel.fromMap(source);
}

// ------------------------------------------
