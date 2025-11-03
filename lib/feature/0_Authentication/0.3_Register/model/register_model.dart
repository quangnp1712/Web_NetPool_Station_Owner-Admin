import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

//! Register - station owner !//
class RegisterModel {
  String? avatar;
  String? username;
  String? password;
  String? identification;
  String? phone;
  String? email;
  RegisterModel({
    this.avatar,
    this.username,
    this.password,
    this.identification,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'avatar': avatar ?? "",
      'username': username,
      'password': password,
      'identification': identification,
      'phone': phone,
      'email': email,
    };
  }

  factory RegisterModel.fromMap(Map<String, dynamic> map) {
    return RegisterModel(
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      username: map['username'] != null ? map['username'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      identification: map['identification'] != null
          ? map['identification'] as String
          : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterModel.fromJson(Map<String, dynamic> source) =>
      RegisterModel.fromMap(source);
}
