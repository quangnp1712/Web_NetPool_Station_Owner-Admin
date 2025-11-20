import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AutocompleteModel {
  String? address;
  String? placeId;
  CompoundModel? compound;
  AutocompleteModel({
    this.address,
    this.placeId,
    this.compound,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'address': address,
      'placeId': placeId,
      'compound': compound?.toMap(),
    };
  }

  factory AutocompleteModel.fromMap(Map<String, dynamic> map) {
    return AutocompleteModel(
      address: map['address'] != null ? map['address'] as String : null,
      placeId: map['placeId'] != null ? map['placeId'] as String : null,
      compound: map['compound'] != null
          ? CompoundModel.fromMap(map['compound'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AutocompleteModel.fromJson(Map<String, dynamic> source) =>
      AutocompleteModel.fromMap(source);
}

class CompoundModel {
  String? district;
  String? commune;
  String? province;
  CompoundModel({
    this.district,
    this.commune,
    this.province,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'district': district,
      'commune': commune,
      'province': province,
    };
  }

  factory CompoundModel.fromMap(Map<String, dynamic> map) {
    return CompoundModel(
      district: map['district'] != null ? map['district'] as String : null,
      commune: map['commune'] != null ? map['commune'] as String : null,
      province: map['province'] != null ? map['province'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompoundModel.fromJson(Map<String, dynamic> source) =>
      CompoundModel.fromMap(source);
}
