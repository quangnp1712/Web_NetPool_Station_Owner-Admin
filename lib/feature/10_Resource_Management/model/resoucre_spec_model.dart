import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ResourceSpecModel {
  int? stationResourceSpecId;
  int? stationResourceId;

  // --- Nhóm PC - NET ---
  String? pcCpu;
  String? pcGpuModel;
  String? pcRam;
  String? pcMonitor;
  String? pcKeyboard;
  String? pcMouse;
  String? pcHeadphone;

  // --- Nhóm BT - BIDA ---
  String? btTableDetail;
  String? btCueDetail;
  String? btBallDetail;

  // --- Nhóm CS - PLAYSTATION ---
  String? csConsoleModel;
  String? csTvModel;
  String? csControllerType;
  int? csControllerCount;

  ResourceSpecModel({
    this.stationResourceSpecId,
    this.stationResourceId,
    this.pcCpu,
    this.pcGpuModel,
    this.pcRam,
    this.pcMonitor,
    this.pcKeyboard,
    this.pcMouse,
    this.pcHeadphone,
    this.btTableDetail,
    this.btCueDetail,
    this.btBallDetail,
    this.csConsoleModel,
    this.csTvModel,
    this.csControllerType,
    this.csControllerCount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stationResourceSpecId': stationResourceSpecId,
      'stationResourceId': stationResourceId,
      'pcCpu': pcCpu,
      'pcGpuModel': pcGpuModel,
      'pcRam': pcRam,
      'pcMonitor': pcMonitor,
      'pcKeyboard': pcKeyboard,
      'pcMouse': pcMouse,
      'pcHeadphone': pcHeadphone,
      'btTableDetail': btTableDetail,
      'btCueDetail': btCueDetail,
      'btBallDetail': btBallDetail,
      'csConsoleModel': csConsoleModel,
      'csTvModel': csTvModel,
      'csControllerType': csControllerType,
      'csControllerCount': csControllerCount,
    };
  }

  factory ResourceSpecModel.fromMap(Map<String, dynamic> map) {
    return ResourceSpecModel(
      stationResourceSpecId: map['stationResourceSpecId'] != null
          ? map['stationResourceSpecId'] as int
          : null,
      stationResourceId: map['stationResourceId'] != null
          ? map['stationResourceId'] as int
          : null,
      pcCpu: map['pcCpu'] != null ? map['pcCpu'] as String : null,
      pcGpuModel:
          map['pcGpuModel'] != null ? map['pcGpuModel'] as String : null,
      pcRam: map['pcRam'] != null ? map['pcRam'] as String : null,
      pcMonitor: map['pcMonitor'] != null ? map['pcMonitor'] as String : null,
      pcKeyboard:
          map['pcKeyboard'] != null ? map['pcKeyboard'] as String : null,
      pcMouse: map['pcMouse'] != null ? map['pcMouse'] as String : null,
      pcHeadphone:
          map['pcHeadphone'] != null ? map['pcHeadphone'] as String : null,
      btTableDetail:
          map['btTableDetail'] != null ? map['btTableDetail'] as String : null,
      btCueDetail:
          map['btCueDetail'] != null ? map['btCueDetail'] as String : null,
      btBallDetail:
          map['btBallDetail'] != null ? map['btBallDetail'] as String : null,
      csConsoleModel: map['csConsoleModel'] != null
          ? map['csConsoleModel'] as String
          : null,
      csTvModel: map['csTvModel'] != null ? map['csTvModel'] as String : null,
      csControllerType: map['csControllerType'] != null
          ? map['csControllerType'] as String
          : null,
      csControllerCount: map['csControllerCount'] != null
          ? map['csControllerCount'] as int
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ResourceSpecModel.fromJson(Map<String, dynamic> source) =>
      ResourceSpecModel.fromMap(source);
}
