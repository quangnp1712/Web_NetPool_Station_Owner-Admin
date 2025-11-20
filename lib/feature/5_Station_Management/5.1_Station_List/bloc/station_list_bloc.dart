import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_stations_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/model/station_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/model/station_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/repository/station_list_repository.dart';

part 'station_list_event.dart';
part 'station_list_state.dart';

class StationListBloc extends Bloc<StationListEvent, StationListState> {
  List<StationListModel> _masterStationList = [];
  Map<String, String> _masterStatusNameMap = {};

  StationListBloc() : super(StationListInitial()) {
    on<StationListInitialEvent>(_StationListInitialEvent);
    on<StationListLoadEvent>(_StationListLoadEvent);
    on<SelectedStatusEvent>(_selectedStatusEvent);
    on<SelectedProvinceEvent>(_selectedProvinceEvent);
    on<SelectedDistrictEvent>(_selectedDistrictEvent);
    on<ShowCreateStationPageEvent>(_showCreateStationPageEvent);
  }
  FutureOr<void> _StationListInitialEvent(
      StationListInitialEvent event, Emitter<StationListState> emit) {
    emit(StationListInitial());
    add(StationListLoadEvent(current: 1)); // truyền roleIds của player
  }

  FutureOr<void> _StationListLoadEvent(
      StationListLoadEvent event, Emitter<StationListState> emit) async {
    emit(StationList_ChangeState());
    emit(StationList_LoadingState(isLoading: true));
    try {
      int apiPage = event.current - 1; // Chuyển 1->0, 2->1...

      String search = event.search ?? "";

      String province = event.province ?? "";

      String commune = event.commune ?? "";

      String district = event.district ?? "";

      String statusCode = _masterStatusNameMap[event.statusName] ?? "";

      String pageSize = "10";

      var results = await StationListRepository().listWithSearch(
          search,
          province,
          commune,
          district,
          statusCode,
          apiPage.toString(),
          pageSize);

      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        StationListModelResponse stationListModelResponse =
            StationListModelResponse.fromJson(responseBody);

        try {
          if (stationListModelResponse.data != null) {
            if (stationListModelResponse.data!.isNotEmpty) {
              // 1. Lấy danh sách TẤT CẢ station từ API
              List<StationListModel> allStations =
                  stationListModelResponse.data!;

              final List<String> stationJsonList =
                  AuthenticationPref.getStationsJson();
              if (stationJsonList.isEmpty) {
                emit(StationListEmptyState());
                return;
              }

              // 3. Chuyển đổi danh sách JSON string thành một Set<String> các ID
              final Set<String> ownedStationIds = stationJsonList
                  .map((jsonString) {
                    // (Giả sử model của bạn là AuthStationsModel)
                    return AuthStationsModel.fromJson(jsonDecode(jsonString))
                        .stationId;
                  })
                  .whereType<String>()
                  .toSet();

              List<StationListModel> _stationList =
                  allStations.where((station) {
                return ownedStationIds.contains(station.stationId.toString());
              }).toList();

              for (var _station in _stationList) {
                _station.stationName =
                    Utf8Encoding().decode(_station.stationName.toString());
                _station.province =
                    Utf8Encoding().decode(_station.province.toString());
                _station.district =
                    Utf8Encoding().decode(_station.district.toString());
                _station.statusName =
                    Utf8Encoding().decode(_station.statusName.toString());
              }

              // --- SỬA: Lấy statusMap (Name -> Code) ---
              Map<String, String> statusNameMap = {};
              for (var station in _stationList) {
                if (station.statusCode != null && station.statusName != null) {
                  // Key là Name (Kích hoạt), Value là Code (ACTIVE)
                  statusNameMap[station.statusName!] = station.statusCode!;
                }
              }
              // ------------------------------------

              StationListMetaModel metaModel = stationListModelResponse.meta!;
              try {
                metaModel.current = (metaModel.current ?? 0) + 1;
              } catch (e) {}

              if (_masterStationList.isEmpty) {
                // Giả định: Lần đầu tiên load (không filter) phải trả về TẤT CẢ
                // các station và TẤT CẢ các loại status.
                // (Nếu API của bạn không làm vậy, bạn CẦN 1 API GET /filters riêng)

                _masterStationList = _stationList;

                // Tạo Map (Name -> Code)
                Map<String, String> statusNameMap = {};
                for (var station in _stationList) {
                  if (station.statusCode != null &&
                      station.statusName != null) {
                    statusNameMap[station.statusName!] = station.statusCode!;
                  }
                }
                _masterStatusNameMap = statusNameMap;
              }
              emit(StationListSuccessState(
                stationList: _stationList, // Gửi đi danh sách (đã phân trang)
                statusNames: _masterStatusNameMap.keys
                    .toList(), // Gửi đi danh sách (đầy đủ)
                meta: metaModel,
                allOwnedStations:
                    _masterStationList, // Gửi đi danh sách (đầy đủ)
              ));
              return;
            }
          }
          emit(StationListEmptyState());
        } catch (e) {
          emit(StationListEmptyState());
          DebugLogger.printLog(e.toString());
        }
        DebugLogger.printLog("$responseStatus - $responseMessage - thành công");
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(StationListEmptyState());
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: responseSuccess));
      }
    } catch (e) {
      emit(StationListEmptyState());
      emit(StationList_LoadingState(isLoading: false));
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _selectedStatusEvent(
      SelectedStatusEvent event, Emitter<StationListState> emit) async {
    emit(StationList_ChangeState());
    emit(SelectedStatusState(selectedStatus: event.newValue));
  }

  FutureOr<void> _selectedProvinceEvent(
      SelectedProvinceEvent event, Emitter<StationListState> emit) async {
    emit(StationList_ChangeState());
    emit(SelectedProvinceState(selectedProvince: event.newValue));
  }

  FutureOr<void> _selectedDistrictEvent(
      SelectedDistrictEvent event, Emitter<StationListState> emit) async {
    emit(StationList_ChangeState());
    emit(SelectedDistrictState(selectedDistrict: event.newValue));
  }

  FutureOr<void> _showCreateStationPageEvent(
      ShowCreateStationPageEvent event, Emitter<StationListState> emit) async {
    emit(StationList_ChangeState());
    emit(ShowCreateStationPageState());
  }
}
