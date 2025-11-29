import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/station_detail_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/station_detail_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/repository/station_detail_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/space_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/repository/space_repository.dart';

part 'space_event.dart';
part 'space_state.dart';

class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  SpaceBloc() : super(SpaceState()) {
    on<InitSpaceManageEvent>(_onInit);
    on<ToggleHeaderEvent>((event, emit) =>
        emit(state.copyWith(isHeaderExpanded: !state.isHeaderExpanded)));
    on<LoadMasterListEvent>(_onLoadMaster);
    on<CreateStationSpaceEvent>(_onCreate);
    on<UpdateStationSpaceEvent>(_onUpdate);
    on<ChangeStatusEvent>(_onChangeStatus);
    on<DeleteStationSpaceEvent>(_onDelete);
  }

  Future<void> _onInit(
      InitSpaceManageEvent event, Emitter<SpaceState> emit) async {
    emit(state.copyWith(status: SpaceStatus.loading));
    try {
      //! 1. API STATION
      if (event.stationId == "") {
        emit(state.copyWith(
          status: SpaceStatus.failure,
          message: "Lỗi vui lòng thử lại",
        ));
        DebugLogger.printLog("Lỗi: không có stationID ");
        return;
      }

      //! Call API Detail Station
      StationDetailModel? info;
      var resultsStation = await StationDetailRepository()
          .findDetailStation(event.stationId.toString());
      var responseMessageStation = resultsStation['message'];
      var responseStatusStation = resultsStation['status'];
      var responseSuccessStation = resultsStation['success'];
      var responseBodyStation = resultsStation['body'];
      if (responseSuccessStation || responseStatusStation == 200) {
        StationDetailModelResponse resultsBodyStation =
            StationDetailModelResponse.fromJson(responseBodyStation);
        if (resultsBodyStation.data != null) {
          try {
            info = resultsBodyStation.data!;
          } catch (e) {
            info = null;
          }
        }
      }

      //! 2. API STATION SPACE
      List<StationSpaceModel> spaces = [];
      var resultsSpace = await StationSpaceRepository()
          .getStationSpace(event.stationId.toString());
      var responseMessageSpace = resultsSpace['message'];
      var responseStatusSpace = resultsSpace['status'];
      var responseSuccessSpace = resultsSpace['success'];
      var responseBodySpace = resultsSpace['body'];
      if (responseSuccessSpace || responseStatusSpace == 200) {
        StationSpaceListModelResponse resultsBodySpace =
            StationSpaceListModelResponse.fromJson(responseBodySpace);
        if (resultsBodySpace.data != null) {
          try {
            spaces = resultsBodySpace.data!;
          } catch (e) {
            spaces = [];
          }
        }
      }

      //! 3. API PLATFORM SPACE
      List<PlatformSpaceModel> platformSpaces = [];
      var resultsPlatformSpaces = await StationSpaceRepository().getSpace();
      var responseMessagePlatformSpaces = resultsPlatformSpaces['message'];
      var responseStatusPlatformSpaces = resultsPlatformSpaces['status'];
      var responseSuccessPlatformSpaces = resultsPlatformSpaces['success'];
      var responseBodyPlatformSpaces = resultsPlatformSpaces['body'];

      if (responseSuccessPlatformSpaces ||
          responseStatusPlatformSpaces == 200) {
        SpaceListModelResponse resultsBodyPlatformSpaces =
            SpaceListModelResponse.fromJson(responseBodyPlatformSpaces);

        if (resultsBodyPlatformSpaces.data != null) {
          try {
            platformSpaces = resultsBodyPlatformSpaces.data!;
          } catch (e) {
            platformSpaces = [];
          }
        }
      }

      if (platformSpaces.isNotEmpty && spaces.isNotEmpty) {
        final platformMap = {for (var p in platformSpaces) p.spaceId: p};

        for (var space in spaces) {
          // Tìm kiếm trong Map cực nhanh
          final platform = platformMap[space.spaceId];

          if (platform != null) {
            space.space = platform;
          }
        }
      }
      emit(state.copyWith(
        status: SpaceStatus.success,
        station: info,
        mySpaces: spaces,
        platformSpaces: platformSpaces,
        currentStationId: event.stationId.toString(),
      ));
      DebugLogger.printLog(
          "Lỗi: 1.$responseMessagePlatformSpaces \n 2.$responseMessageSpace \n 3.$responseMessageStation ");
    } catch (e) {
      emit(state.copyWith(
        status: SpaceStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
      DebugLogger.printLog("Lỗi: $e");
    }
  }

  Future<void> _onLoadMaster(
      LoadMasterListEvent event, Emitter<SpaceState> emit) async {
    if (state.platformSpaces.isNotEmpty) return;
    emit(state.copyWith(isActionLoading: true));
    try {
      List<PlatformSpaceModel> platformSpaces = [];
      var results = await StationSpaceRepository().getSpace();
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      if (responseSuccess || responseStatus == 200) {
        SpaceListModelResponse resultsBody =
            SpaceListModelResponse.fromJson(responseBody);

        if (resultsBody.data != null) {
          try {
            platformSpaces = resultsBody.data!;
          } catch (e) {
            platformSpaces = [];
          }
        }
      } else {
        DebugLogger.printLog("Lỗi: $responseMessage");
      }
      emit(state.copyWith(
          isActionLoading: false, platformSpaces: platformSpaces));
    } catch (e) {
      emit(state.copyWith(isActionLoading: false));
      DebugLogger.printLog("Lỗi: $e");
    }
  }

  Future<void> _onCreate(
      CreateStationSpaceEvent event, Emitter<SpaceState> emit) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      //! Call API Create Station Space
      var results =
          await StationSpaceRepository().createStationSpace(event.newSpace);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          status: SpaceStatus.success,
          message: "Thêm thành công",
          isActionLoading: true,
        ));
        add(InitSpaceManageEvent(int.tryParse(state.currentStationId) ?? 0));
      } else {
        emit(state.copyWith(
          status: SpaceStatus.failure,
          message: "Thêm thất bại",
          isActionLoading: false,
        ));
        DebugLogger.printLog("Lỗi: $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
        status: SpaceStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
        isActionLoading: false,
      ));
      DebugLogger.printLog("Lỗi: $e");
    }
  }

  Future<void> _onUpdate(
      UpdateStationSpaceEvent event, Emitter<SpaceState> emit) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      //! Call API Update Station Space
      var results =
          await StationSpaceRepository().updateStationSpace(event.updatedSpace);

      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          status: SpaceStatus.success,
          message: "Cập nhập thành công",
          isActionLoading: true,
        ));
        add(InitSpaceManageEvent(int.tryParse(state.currentStationId) ?? 0));
      } else {
        emit(state.copyWith(
          status: SpaceStatus.failure,
          message: "Cập nhập thất bại",
          isActionLoading: false,
        ));
        DebugLogger.printLog("Lỗi: $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
          status: SpaceStatus.failure,
          message: "Cập nhập thất bại",
          isActionLoading: false));
      DebugLogger.printLog("Lỗi: $e");
    }
  }

  Future<void> _onChangeStatus(
      ChangeStatusEvent event, Emitter<SpaceState> emit) async {
    try {
      String status = event.status == "ACTIVE" ? "enable" : 'disable';
      //! Call API Change Status Station Space
      var results = await StationSpaceRepository()
          .changeStateStationSpace(event.stationSpaceId.toString(), status);

      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          status: SpaceStatus.success,
          message: "Đổi trạng thái thành công",
        ));
        final updatedList = state.mySpaces.map((s) {
          if (s.stationSpaceId == event.stationSpaceId) {
            return s.copyWith(
                statusCode: event.status,
                statusName: event.status == "ACTIVE"
                    ? "Đang hoạt động"
                    : "Ngừng hoạt động");
          }
          return s;
        }).toList();
        emit(state.copyWith(mySpaces: updatedList));
      } else {
        emit(state.copyWith(
          status: SpaceStatus.failure,
          message: "Đổi trạng thái thất bại",
          isActionLoading: false,
        ));
        DebugLogger.printLog("Lỗi: $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
        status: SpaceStatus.failure,
        message: "Đổi trạng thái thất bại",
        isActionLoading: false,
      ));
      DebugLogger.printLog("Lỗi: $e");
    }
  }

  Future<void> _onDelete(
      DeleteStationSpaceEvent event, Emitter<SpaceState> emit) async {
    try {
      //! Call API Change Status Station Space
      var results = await StationSpaceRepository()
          .deleteStationSpace(event.stationSpaceId.toString());

      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          status: SpaceStatus.success,
          message: "Xóa Loại hình thành công",
        ));
        add(InitSpaceManageEvent(int.tryParse(state.currentStationId) ?? 0));
      } else {
        emit(state.copyWith(
          status: SpaceStatus.failure,
          message: "Xóa Loại hình thất bại",
          isActionLoading: false,
        ));
        DebugLogger.printLog("Lỗi: $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
        status: SpaceStatus.failure,
        message: "Xóa Loại hình thất bại",
        isActionLoading: false,
      ));
      DebugLogger.printLog("Lỗi: $e");
    }
  }
}
