import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/space_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/repository/space_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/repository/area_list_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

part 'area_list_event.dart';
part 'area_list_state.dart';

class AreaListBloc extends Bloc<AreaListEvent, AreaListState> {
  AreaListBloc() : super(AreaListState()) {
    on<AreaListInitialEvent>(_onInitial);
    on<AreaListLoadDataEvent>(_onLoadData);
    on<AreaListCreateEvent>(_onCreateArea);
    on<UpdateAreaEvent>(_onUpdateArea);
    on<ToggleStatusEvent>(_onToggleStatus);

    //
    on<AreaListSelectSpaceEvent>(_onSelectSpace);
    on<AreaListSelectStatusEvent>(_onSelectStatus);
    on<AreaListApplySearchEvent>(_onApplySearch);
    on<AreaListChangePageEvent>(_onChangePage);
    on<AreaListChangeRowsPerPageEvent>(_onChangeRowsPerPage);
    on<AreaListResetEvent>(_onReset);
  }

  FutureOr<void> _onInitial(
      AreaListInitialEvent event, Emitter<AreaListState> emit) async {
    emit(state.copyWith(status: AreaListStatus.loading));
    try {
      //! 1 API STATION SPACE
      List<StationSpaceModel> stationSpaces = [];
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
            stationSpaces = resultsBodySpace.data!;
          } catch (e) {
            stationSpaces = [];
          }
        }
      }

      //! 2 API PLATFORM SPACE
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

      //! Gắn platform space vào staion space
      if (platformSpaces.isNotEmpty && stationSpaces.isNotEmpty) {
        final platformMap = {for (var p in platformSpaces) p.spaceId: p};

        for (var space in stationSpaces) {
          // Tìm kiếm trong Map cực nhanh
          final platform = platformMap[space.spaceId];

          if (platform != null) {
            space.space = platform;
          }
        }

        emit(state.copyWith(
          blocState: AreaListBlocState.Initial,
          status: AreaListStatus.success,
          currentStationId: event.stationId,
          allStationSpaces: stationSpaces,
          statusOptions: [
            "ACTIVE",
            "INACTIVE",
          ],
          areaList: [],
          meta: MetaModel(current: 1, pageSize: 10, total: 0),
        ));
        return;
      }
      emit(state.copyWith(
        blocState: AreaListBlocState.Initial,
        currentStationId: event.stationId,
        statusOptions: [
          "ACTIVE",
          "INACTIVE",
        ],
        areaList: [],
        meta: MetaModel(current: 1, pageSize: 10, total: 0),
      ));
    } catch (e) {
      emit(state.copyWith(
        blocState: AreaListBlocState.Initial,
        currentStationId: event.stationId,
        statusOptions: [
          "ACTIVE",
          "INACTIVE",
        ],
        areaList: [],
        meta: MetaModel(current: 1, pageSize: 10, total: 0),
        status: AreaListStatus.failure,
        message: "Lỗi khởi tạo",
      ));
    }
  }

  //! get/find all area
  FutureOr<void> _onLoadData(
      AreaListLoadDataEvent event, Emitter<AreaListState> emit) async {
    if (state.selectedSpace == null) {
      emit(state.copyWith(
          status: AreaListStatus.success,
          areaList: [],
          meta: MetaModel(current: 1, pageSize: 10, total: 0)));
      return;
    }
    //! Trường hợp 2: Có chọn Space
    //! Call Api Area List - Find All
    emit(state.copyWith(status: AreaListStatus.loading));
    try {
      final current = (event.current ?? state.meta.current ?? 1) - 1;
      final pageSize = state.meta.pageSize ?? 10;
      String search = event.search ?? "";
      String spaceId = state.selectedSpace?.spaceId.toString() ?? "";
      String statusCodes = state.selectedStatus ?? "";

      List<AreaModel> areas = [];
      MetaModel metaModel =
          MetaModel(current: event.current, pageSize: 10, total: 0);

      var results = await AreaListRepository().getArea(
        search,
        state.currentStationId.toString(),
        spaceId,
        statusCodes,
        current.toString(),
        pageSize.toString(),
      );
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      if (responseSuccess || responseStatus == 200) {
        AreaListModelResponse resultsBody =
            AreaListModelResponse.fromJson(responseBody);

        //! Lọc dữ liệu
        if (resultsBody.data != null) {
          try {
            areas = resultsBody.data!;
            metaModel = resultsBody.meta!;
          } catch (e) {
            areas = [];
          }

          emit(state.copyWith(
            status: AreaListStatus.success,
            blocState: AreaListBlocState.AreaListSuccess,
            areaList: areas,
            meta: MetaModel(
                current: event.current,
                pageSize: pageSize,
                total: metaModel.total),
          ));
          return;
        }
      }
      emit(state.copyWith(
        blocState: AreaListBlocState.AreaListEmpty,
        areaList: [],
        meta: MetaModel(current: event.current, pageSize: pageSize, total: 0),
      ));
      DebugLogger.printLog("$responseStatus - $responseMessage");
    } catch (e) {
      emit(state.copyWith(
          status: AreaListStatus.failure, message: "Lỗi tải dữ liệu"));
      DebugLogger.printLog("Lỗi tải dữ liệu: $e");
    }
  }

  //! Create area
  FutureOr<void> _onCreateArea(
      AreaListCreateEvent event, Emitter<AreaListState> emit) async {
    emit(state.copyWith(createStatus: CreateStatus.loading));

    try {
      // AreaModel
      final newArea = AreaModel(
        stationSpaceId: event.stationSpace.stationSpaceId,
        areaCode: event.areaCode,
        areaName: event.areaName,
        price: event.price,
      );

      // Call api
      var results = await AreaListRepository().createArea(newArea);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      // response
      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
            createStatus: CreateStatus.success,
            message: "Tạo khu vực thành công"));

        if (state.selectedSpace?.stationSpaceId ==
            event.stationSpace.stationSpaceId) {
          add(AreaListLoadDataEvent(current: 1));
        } else {
          add(AreaListSelectSpaceEvent(newValue: event.stationSpace));
        }
        return;
      } else if (responseStatus == 409) {
        emit(state.copyWith(
            createStatus: CreateStatus.failure, message: responseMessage));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
          createStatus: CreateStatus.failure, message: "Tạo thất bại: $e"));
    } finally {
      emit(state.copyWith(createStatus: CreateStatus.initial));
    }
  }

  //! update area
  FutureOr<void> _onUpdateArea(
      UpdateAreaEvent event, Emitter<AreaListState> emit) async {
    emit(state.copyWith(updateStatus: UpdateStatus.loading));

    try {
      if (event.updatedArea.areaId == null) {
        DebugLogger.printLog("Area ID không hợp lệ");
        return;
      }

      // AreaModel
      final newArea = AreaModel(
        stationSpaceId: event.updatedArea.stationSpaceId,
        areaCode: event.updatedArea.areaCode,
        areaName: event.updatedArea.areaName,
        price: event.updatedArea.price,
      );

      // Call api
      var results = await AreaListRepository()
          .updateArea(event.updatedArea.areaId.toString(), newArea);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      // response
      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
            updateStatus: UpdateStatus.success,
            message:
                "Cập nhật khu vực ${event.updatedArea.areaName} thành công"));

        // 2. Tải lại Data (Giữ nguyên filter và trang)
        add(AreaListLoadDataEvent(current: state.meta.current));
        return;
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
          updateStatus: UpdateStatus.failure,
          message: "Cập nhật thất bại: $e"));
    } finally {
      emit(state.copyWith(updateStatus: UpdateStatus.initial));
    }
  }

  //! change status
  FutureOr<void> _onToggleStatus(
      ToggleStatusEvent event, Emitter<AreaListState> emit) async {
    emit(state.copyWith(updateStatus: UpdateStatus.loading));
    try {
      final isCurrentlyActive = event.area.statusCode == "ACTIVE";
      final newStatus = isCurrentlyActive ? "disable" : "enable";
      final newName = isCurrentlyActive ? "Hoạt động" : "Không hoạt động";
// Call api
      var results = await AreaListRepository()
          .changeStatusArea(event.area.areaId.toString(), newStatus);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      // response
      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
            updateStatus: UpdateStatus.success,
            message: "Đổi trạng thái thành $newName"));
        add(AreaListLoadDataEvent(current: state.meta.current));
      } else {
        emit(state.copyWith(
            updateStatus: UpdateStatus.failure,
            message: "Đổi trạng thái thất bại \n$responseMessage"));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }

      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      emit(state.copyWith(
          updateStatus: UpdateStatus.failure,
          message: "Đổi trạng thái thất bại: $e"));
    } finally {
      emit(state.copyWith(updateStatus: UpdateStatus.initial));
    }
  }

  FutureOr<void> _onSelectSpace(
      AreaListSelectSpaceEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
        selectedSpace: event.newValue,
        blocState: AreaListBlocState.SelectedSpace,
        meta: MetaModel(current: 1, pageSize: state.meta.pageSize, total: 0)));
    add(AreaListLoadDataEvent(current: 1));
  }

  FutureOr<void> _onSelectStatus(
      AreaListSelectStatusEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
        selectedStatus: event.newValue,
        blocState: AreaListBlocState.SelectedStatus,
        meta: MetaModel(current: 1, pageSize: state.meta.pageSize, total: 0)));
    add(AreaListLoadDataEvent(current: 1));
  }

  FutureOr<void> _onApplySearch(
      AreaListApplySearchEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
        searchTerm: event.searchTerm,
        blocState: AreaListBlocState.AppliedSearch,
        meta: MetaModel(current: 1, pageSize: state.meta.pageSize, total: 0)));
    add(AreaListLoadDataEvent(current: 1));
  }

  FutureOr<void> _onChangePage(
      AreaListChangePageEvent event, Emitter<AreaListState> emit) {
    add(AreaListLoadDataEvent(current: event.newPage));
  }

  FutureOr<void> _onChangeRowsPerPage(
      AreaListChangeRowsPerPageEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
        meta: MetaModel(
            current: 1,
            pageSize: event.newRowsPerPage,
            total: state.meta.total)));
    add(AreaListLoadDataEvent(current: 1));
  }

  FutureOr<void> _onReset(
      AreaListResetEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
        forceNullSpace: true,
        forceNullStatus: true,
        searchTerm: "",
        blocState: AreaListBlocState.ResetFilters,
        areaList: [],
        meta: MetaModel(current: 1, pageSize: 10, total: 0)));
  }
}
