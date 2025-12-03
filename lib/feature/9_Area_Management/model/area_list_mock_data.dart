import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_model.dart';

final List<StationSpaceModel> mockStationSpace = [
  StationSpaceModel(
      stationSpaceId: 1,
      spaceCode: "PS0003",
      spaceName: "PLAYSTATION 5",
      space: PlatformSpaceModel(
          metadata: SpaceMetaDataModel(icon: "PS5", bgColor: "0070D1"))),
  StationSpaceModel(
      stationSpaceId: 2,
      spaceCode: "PC001",
      spaceName: "PC GAMING VIP",
      space: PlatformSpaceModel(
          metadata: SpaceMetaDataModel(icon: "PC", bgColor: "#FF4500"))),
  StationSpaceModel(
      stationSpaceId: 3,
      spaceCode: "BL01",
      spaceName: "BILLIARDS",
      space: PlatformSpaceModel(
          metadata: SpaceMetaDataModel(icon: "BILLIARD", bgColor: "10B981"))),
];

final List<AreaModel> mockAreas = [
  // stationSpaceId: 1 (PLAYSTATION 5)
  AreaModel(
      areaId: 1,
      stationSpaceId: 1,
      areaCode: "VIP-PS-01",
      areaName: "Phòng PS5 VIP 1",
      price: 50000,
      statusName: "Hoạt động",
      statusCode: "ACTIVE"),
  AreaModel(
      areaId: 2,
      stationSpaceId: 1,
      areaCode: "STD-PS-01",
      areaName: "Máy PS5 Standard 01",
      price: 30000,
      statusName: "Hoạt động",
      statusCode: "ACTIVE"),
  AreaModel(
      areaId: 3,
      stationSpaceId: 1,
      areaCode: "STD-PS-02",
      areaName: "Máy PS5 Standard 02",
      price: 30000,
      statusName: "Bảo trì",
      statusCode: "INACTIVE"),
  AreaModel(
      areaId: 4,
      stationSpaceId: 1,
      areaCode: "VIP-PS-02",
      areaName: "Phòng PS5 VIP 2",
      price: 50000,
      statusName: "Hoạt động",
      statusCode: "ACTIVE"),
  AreaModel(
      areaId: 5,
      stationSpaceId: 1,
      areaCode: "VIP-PS-03",
      areaName: "Phòng PS5 VIP 3",
      price: 50000,
      statusName: "Hoạt động",
      statusCode: "ACTIVE"),

  // stationSpaceId: 2 (PC GAMING VIP)
  AreaModel(
      areaId: 6,
      stationSpaceId: 2,
      areaCode: "PC-VIP-01",
      areaName: "PC VIP A1",
      price: 60000,
      statusName: "Hoạt động",
      statusCode: "ACTIVE"),
  AreaModel(
      areaId: 7,
      stationSpaceId: 2,
      areaCode: "PC-STD-01",
      areaName: "PC Standard 1",
      price: 40000,
      statusName: "Hoạt động",
      statusCode: "ACTIVE"),
];
