import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class BaseResponse {
  String? status;
  bool? success;
  String? errorCode;
  String? message;
  String? responseAt;
  BaseResponse({
    this.status,
    this.success,
    this.errorCode,
    this.message,
    this.responseAt,
  });

  factory BaseResponse.fromMap(Map<String, dynamic> map) {
    return BaseResponse(
      status: map['status'] != null ? map['status'] as String : null,
      success: map['success'] != null ? map['success'] as bool : null,
      errorCode: map['errorCode'] != null ? map['errorCode'] as String : null,
      message: map['message'] != null ? map['message'] as String : null,
      responseAt:
          map['responseAt'] != null ? map['responseAt'] as String : null,
    );
  }

  factory BaseResponse.fromJson(Map<String, dynamic> source) =>
      BaseResponse.fromMap(source);
}
