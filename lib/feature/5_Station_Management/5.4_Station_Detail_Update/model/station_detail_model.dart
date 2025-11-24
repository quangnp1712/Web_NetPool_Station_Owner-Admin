import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class StationDetailModel {
  int? stationId;
  String? avatar;
  String? stationCode;
  String? stationName;
  String? address;
  String? province;
  String? commune;
  String? district;
  String? hotline;
  String? statusCode;
  String? statusName;
  List<MediaModel>? media;
  MetaDataModel? metadata;

  StationDetailModel({
    this.stationId,
    this.avatar,
    this.stationCode,
    this.stationName,
    this.address,
    this.province,
    this.commune,
    this.district,
    this.hotline,
    this.statusCode,
    this.statusName,
    this.media,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'avatar': avatar,
      'stationName': stationName,
      'address': address,
      'province': province,
      'commune': commune,
      'district': district,
      'hotline': hotline,
    };
  }

  factory StationDetailModel.fromMap(Map<String, dynamic> map) {
    return StationDetailModel(
      stationId: map['stationId'] != null ? map['stationId'] as int : null,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      stationCode:
          map['stationCode'] != null ? map['stationCode'] as String : null,
      stationName:
          map['stationName'] != null ? map['stationName'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      province: map['province'] != null ? map['province'] as String : null,
      commune: map['commune'] != null ? map['commune'] as String : null,
      district: map['district'] != null ? map['district'] as String : null,
      hotline: map['hotline'] != null ? map['hotline'] as String : null,
      statusCode:
          map['statusCode'] != null ? map['statusCode'] as String : null,
      statusName:
          map['statusName'] != null ? map['statusName'] as String : null,
      media: map['media'] != null
          ? List<MediaModel>.from(
              (map['media'] as List).map(
                (x) => MediaModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      metadata: map['metadata'] != null
          ? MetaDataModel.fromMap(map['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StationDetailModel.fromJson(Map<String, dynamic> source) =>
      StationDetailModel.fromMap(source);
}

class MediaModel {
  String? url;
  MediaModel({
    this.url,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
    };
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      url: map['url'] != null ? map['url'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaModel.fromJson(Map<String, dynamic> source) =>
      MediaModel.fromMap(source);
}

class MetaDataModel {
  String? rejectReason;
  DateTime? rejectAt;
  MetaDataModel({
    this.rejectReason,
    this.rejectAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rejectReason': rejectReason,
      'rejectAt': rejectAt?.millisecondsSinceEpoch,
    };
  }

  factory MetaDataModel.fromMap(Map<String, dynamic> map) {
    return MetaDataModel(
      rejectReason:
          map['rejectReason'] != null ? map['rejectReason'] as String : null,
      rejectAt: map['rejectAt'] != null
          ? DateTime.parse(map['rejectAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MetaDataModel.fromJson(Map<String, dynamic> source) =>
      MetaDataModel.fromMap(source);
}
