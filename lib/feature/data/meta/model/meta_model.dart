// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MetaModel {
  int? pageSize;
  int? current;
  int? total;
  MetaModel({
    this.pageSize,
    this.current,
    this.total,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pageSize': pageSize,
      'current': current,
      'total': total,
    };
  }

  factory MetaModel.fromMap(Map<String, dynamic> map) {
    return MetaModel(
      pageSize: map['pageSize'] != null ? map['pageSize'] as int : null,
      current: map['current'] != null ? map['current'] as int : null,
      total: map['total'] != null ? map['total'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MetaModel.fromJson(Map<String, dynamic> source) =>
      MetaModel.fromMap(source);

  MetaModel copyWith({
    int? pageSize,
    int? current,
    int? total,
  }) {
    return MetaModel(
      pageSize: pageSize ?? this.pageSize,
      current: current ?? this.current,
      total: total ?? this.total,
    );
  }
}
