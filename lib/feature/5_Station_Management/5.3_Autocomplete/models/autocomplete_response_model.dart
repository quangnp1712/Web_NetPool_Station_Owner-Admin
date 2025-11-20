// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web_netpool_station_owner_admin/core/model/base_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/models/autocomplete_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

class AutocompleteModelResponse extends BaseResponse {
  List<AutocompleteModel>? data;
  MetaModel? meta;

  AutocompleteModelResponse({
    this.data,
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

  factory AutocompleteModelResponse.fromMap(Map<String, dynamic> map) {
    return AutocompleteModelResponse(
      data: map['data'] != null
          ? List<AutocompleteModel>.from(
              (map['data'] as List).map(
                (x) => AutocompleteModel.fromMap(x as Map<String, dynamic>),
              ),
            )
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

  factory AutocompleteModelResponse.fromJson(Map<String, dynamic> source) =>
      AutocompleteModelResponse.fromMap(source);
}
