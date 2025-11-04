// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RoleModel {
  int? roleId;
  String? roleCode;
  String? roleName;
  RoleModel({
    this.roleId,
    this.roleCode,
    this.roleName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'roleId': roleId,
      'roleCode': roleCode,
      'roleName': roleName,
    };
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      roleId: map['roleId'] != null ? map['roleId'] as int : null,
      roleCode: map['roleCode'] != null ? map['roleCode'] as String : null,
      roleName: map['roleName'] != null ? map['roleName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RoleModel.fromJson(Map<String, dynamic> source) =>
      RoleModel.fromMap(source);
}
