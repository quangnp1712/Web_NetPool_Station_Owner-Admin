import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class AccountListModel {
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

  AccountListModel({
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

  factory AccountListModel.fromMap(Map<String, dynamic> map) {
    return AccountListModel(
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
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountListModel.fromJson(Map<String, dynamic> source) =>
      AccountListModel.fromMap(source);
}
