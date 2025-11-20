class ProvinceModel {
  final int code;
  final String name;
  ProvinceModel({required this.code, required this.name});
  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(code: json['code'], name: json['name']);
  }
}

class DistrictModel {
  final int code;
  final String name;
  DistrictModel({required this.code, required this.name});
  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(code: json['code'], name: json['name']);
  }
}

class CommuneModel {
  final int code;
  final String name;
  CommuneModel({required this.code, required this.name});
  factory CommuneModel.fromJson(Map<String, dynamic> json) {
    return CommuneModel(code: json['code'], name: json['name']);
  }
}
