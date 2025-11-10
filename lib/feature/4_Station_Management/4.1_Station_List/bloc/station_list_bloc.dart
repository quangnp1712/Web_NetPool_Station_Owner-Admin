import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.1_Station_List/model/station_list_mock_data.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.1_Station_List/model/station_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.1_Station_List/model/station_list_response_model.dart';

part 'station_list_event.dart';
part 'station_list_state.dart';

class StationListBloc extends Bloc<StationListEvent, StationListState> {
  StationListBloc() : super(StationListInitial()) {
    on<StationListInitialEvent>(_StationListInitialEvent);
    on<StationListLoadEvent>(_StationListLoadEvent);
  }
  FutureOr<void> _StationListInitialEvent(
      StationListInitialEvent event, Emitter<StationListState> emit) {
    emit(StationListInitial());
    add(StationListLoadEvent()); // truyền roleIds của player
  }

  FutureOr<void> _StationListLoadEvent(
      StationListLoadEvent event, Emitter<StationListState> emit) async {
    emit(StationList_ChangeState());
    emit(StationList_LoadingState(isLoading: true));
    try {
      String? search = event.search ?? "";

      String? statusCodes = event.search ?? "";

      String? roleIds = event.roleIds ?? "";

      String? sorter = event.search ?? "";

      String? current = event.current ?? "";

      String? pageSize = "10";

      String? stationId = event.stationId ?? "";

      // var results = await StationListRepository().listWithSearch(
      //     search, statusCodes, roleIds, sorter, current, pageSize, stationId);

      // 1. Decode JSON
      // (responseJson bây giờ là Map<String, dynamic>)
      var responseJson = jsonDecode(stationListJson);
      dynamic results = {"body": responseJson, "success": true};

      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        StationListModelResponse stationListModelResponse =
            StationListModelResponse.fromJson(responseBody);
        List<StationListModel> _stationList = [];

        try {
          if (stationListModelResponse.data != null) {
            if (stationListModelResponse.data!.isNotEmpty) {
              _stationList = stationListModelResponse.data!;
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
              // 1. Dùng map() để lấy tất cả statusName (bao gồm cả null và trùng lặp)
              // 2. Dùng whereType<String>() để lọc bỏ null
              // 3. Dùng toSet() để loại bỏ trùng lặp
              // 4. Dùng toList() để chuyển về danh sách (List)
              List<String> statusNames = _stationList
                  .map((station) => station.statusName)
                  .whereType<String>()
                  .toSet()
                  .toList();
              StationListMetaModel metaModel = stationListModelResponse.meta!;
              try {
                // if (metaModel.current! >= 0) {
                //   metaModel.current = metaModel.current! + 1;
                // }
              } catch (e) {}
              emit(StationListSuccessState(
                  stationList: _stationList,
                  statusNames: statusNames,
                  meta: metaModel));
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
}
