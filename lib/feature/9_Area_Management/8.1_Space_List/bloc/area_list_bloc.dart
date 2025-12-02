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
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/model/area_list_mock_data.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/model/area_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/model/area_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/repository/area_list_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

part 'area_list_event.dart';
part 'area_list_state.dart';

class AreaListBloc extends Bloc<AreaListEvent, AreaListState> {
  AreaListBloc() : super(AreaListState()) {
    on<AreaListInitialEvent>(_areaListInitialEvent);
    on<AreaListLoadDataEvent>(_areaListLoadDataEvent);
    on<AreaListSelectSpaceEvent>(_areaListSelectSpaceEvent);
    on<AreaListSelectStatusEvent>(_areaListSelectStatusEvent);
    on<AreaListApplySearchEvent>(_areaListApplySearchEvent);
    on<AreaListChangePageEvent>(_areaListChangePageEvent);
    on<AreaListChangeRowsPerPageEvent>(_areaListChangeRowsPerPageEvent);
    on<AreaListResetEvent>(_areaListResetEvent);
  }

  // --- 1. INITIAL LOAD ---
  FutureOr<void> _areaListInitialEvent(
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
        final statusCodes = mockAreas
            .map((e) => e.statusCode ?? "")
            .toSet()
            .where((e) => e.isNotEmpty)
            .toList();

        emit(state.copyWith(
          blocState: AreaListBlocState.Initial,
          allStationSpaces: stationSpaces,
          statusOptions: statusCodes,
          currentStationId: event.stationId,
          areaList: [],
          meta: MetaModel(current: 1, pageSize: 10, total: 0),
        ));
        return;
      }
      emit(state.copyWith(
        blocState: AreaListBlocState.Initial,
        currentStationId: event.stationId,
        areaList: [],
        meta: MetaModel(current: 1, pageSize: 10, total: 0),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AreaListStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
      DebugLogger.printLog("Lỗi: $e");
    }
  }

  // --- 2. LOAD DATA (Main Logic) ---
  FutureOr<void> _areaListLoadDataEvent(
      AreaListLoadDataEvent event, Emitter<AreaListState> emit) async {
    // Cập nhật PageSize và Current Page trước khi tải
    String search = event.search ?? "";
    String spaceId = state.selectedSpace?.spaceId.toString() ?? "";
    String statusCodes = state.selectedStatus ?? "";
    final int currentPage = event.current ?? state.meta?.current ?? 1;
    final int pageSize = 10;

    emit(state.copyWith(
      status: AreaListStatus.loading,
    ));
    // Trường hợp 1: Chưa chọn Space - out
    if (state.selectedSpace == null) {
      emit(state.copyWith(
        areaList: const [],
        meta: MetaModel(current: 1, pageSize: pageSize, total: 0),
      ));
      return;
    }

    //! Trường hợp 2: Có chọn Space
    //! Call Api Area List - Find All
    try {
      List<AreaModel> areas = [];
      var results = await AreaListRepository().getArea(
        search,
        state.currentStationId.toString(),
        spaceId,
        statusCodes,
        currentPage.toString(),
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
          } catch (e) {
            areas = [];
          }
          final int selectedSpaceId = state.selectedSpace!.stationSpaceId!;

          final List<AreaModel> filteredList = areas.where((area) {
            // Lọc theo Space
            bool spaceMatch = area.stationSpaceId == selectedSpaceId;

            // Lọc theo Status
            bool statusMatch = state.selectedStatus == null ||
                area.statusCode == state.selectedStatus;

            // Lọc theo Search Term
            bool searchMatch = state.searchTerm.isEmpty ||
                (area.areaName
                        ?.toLowerCase()
                        .contains(state.searchTerm.toLowerCase()) ??
                    false) ||
                (area.areaCode
                        ?.toLowerCase()
                        .contains(state.searchTerm.toLowerCase()) ??
                    false);

            return spaceMatch && statusMatch && searchMatch;
          }).toList();

          final int totalItems = filteredList.length;
          final int start = (currentPage - 1) * pageSize;
          final int end = min(start + pageSize, totalItems);
          final List<AreaModel> pageData =
              totalItems > 0 ? filteredList.sublist(start, end) : <AreaModel>[];

          emit(state.copyWith(
            status: AreaListStatus.success,
            blocState: pageData.isEmpty
                ? AreaListBlocState.AreaListEmpty
                : AreaListBlocState.AreaListSuccess,
            areaList: pageData,
            meta: MetaModel(
                current: currentPage, pageSize: pageSize, total: totalItems),
          ));
          return;
        }
      }
      emit(state.copyWith(
        blocState: AreaListBlocState.AreaListEmpty,
        areaList: [],
        meta: MetaModel(current: currentPage, pageSize: pageSize, total: 0),
      ));
      DebugLogger.printLog("$responseStatus - $responseMessage");
    } catch (e) {
      emit(state.copyWith(
        status: AreaListStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
      DebugLogger.printLog("Lỗi: $e");
    }
  }

  // --- 3. FILTER EVENTS ---

  FutureOr<void> _areaListSelectSpaceEvent(
      AreaListSelectSpaceEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
      selectedSpace: event.newValue,
      blocState: AreaListBlocState.SelectedSpace,
      meta: MetaModel(current: 1, pageSize: 10, total: 0),
    ));
  }

  FutureOr<void> _areaListSelectStatusEvent(
      AreaListSelectStatusEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
      selectedStatus: event.newValue,
      blocState: AreaListBlocState.SelectedStatus,
      meta: MetaModel(current: 1, pageSize: 10, total: 0),
    ));
  }

  FutureOr<void> _areaListApplySearchEvent(
      AreaListApplySearchEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
      searchTerm: event.searchTerm,
      blocState: AreaListBlocState.AppliedSearch,
      // Reset Page khi tìm kiếm
      meta: MetaModel(current: 1, pageSize: 10, total: 0),
    ));
  }

  // --- 4. PAGINATION EVENTS ---

  FutureOr<void> _areaListChangePageEvent(
      AreaListChangePageEvent event, Emitter<AreaListState> emit) {
    // Chỉ cập nhật Current Page
    add(AreaListLoadDataEvent(current: event.newPage));
  }

  FutureOr<void> _areaListChangeRowsPerPageEvent(
      AreaListChangeRowsPerPageEvent event, Emitter<AreaListState> emit) {
    // Cập nhật Page Size và reset về trang 1
    add(AreaListLoadDataEvent(
      search: state.searchTerm,
      current: event.newRowsPerPage,
      spaceId: state.currentStationId.toString(),
      statusCodes: state.selectedStatus ?? "",
    ));
  }

  // --- 5. RESET ---

  FutureOr<void> _areaListResetEvent(
      AreaListResetEvent event, Emitter<AreaListState> emit) {
    emit(state.copyWith(
        forceNullSpace: true,
        forceNullStatus: true,
        searchTerm: "",
        blocState: AreaListBlocState.ResetFilters,
        areaList: [],
        meta: MetaModel(current: 1, pageSize: 10, total: 0)));
    // Load lại dữ liệu, sẽ hiển thị NoSpaceSelectedState
  }
}
