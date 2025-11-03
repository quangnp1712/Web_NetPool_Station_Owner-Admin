import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class VerfyEmailModel {
  String? email;
  String? verificationCode;
  VerfyEmailModel({
    this.email,
    this.verificationCode,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'verificationCode': verificationCode,
    };
  }

  factory VerfyEmailModel.fromMap(Map<String, dynamic> map) {
    return VerfyEmailModel(
      email: map['email'] != null ? map['email'] as String : null,
      verificationCode: map['verificationCode'] != null
          ? map['verificationCode'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory VerfyEmailModel.fromJson(Map<String, dynamic> source) =>
      VerfyEmailModel.fromMap(source);
}
