import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
//! Login - station owner !//

class LoginModel {
  String? email;
  String? password;
  LoginModel({
    this.email,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
    };
  }

  factory LoginModel.fromMap(Map<String, dynamic> map) {
    return LoginModel(
      email: map['email'] != null ? map['email'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginModel.fromJson(Map<String, dynamic> source) =>
      LoginModel.fromMap(source);
}
