import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Account_Admin_Management/10.1_Account_Admin_List/model/admin_list_mock_data.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Account_Admin_Management/10.1_Account_Admin_List/model/admin_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Account_Admin_Management/10.1_Account_Admin_List/model/admin_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/models/role_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/models/role_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/repository/role_repository.dart';

part 'admin_list_event.dart';
part 'admin_list_state.dart';

class AdminListBloc extends Bloc<AdminListEvent, AdminListState> {
  RoleModel _rolePlayer = RoleModel();

  AdminListBloc() : super(AdminListInitial()) {
    on<AdminListInitialEvent>(_AdminListInitialEvent);
    on<RoleEvent>(_roleEvent);
    on<GetStationIdEvent>(_getStationIdEvent);
    on<AdminListLoadEvent>(_adminListLoadEvent);
  }

  FutureOr<void> _AdminListInitialEvent(
      AdminListInitialEvent event, Emitter<AdminListState> emit) {
    emit(AdminListInitial());
    add(RoleEvent()); // truyền roleIds của player
  }

  FutureOr<void> _roleEvent(
      RoleEvent event, Emitter<AdminListState> emit) async {
    emit(AdminList_ChangeState());
    emit(AdminList_LoadingState(isLoading: true));
    try {
      var results = await RoleRepository().roles();
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        RoleModelResponse roleModelResponse =
            RoleModelResponse.fromJson(responseBody);
        if (roleModelResponse.data != null) {
          for (var dataRole in roleModelResponse.data!) {
            if (dataRole.roleCode == "STATION_ADMIN") {
              _rolePlayer = dataRole;
              break;
            }
          }
        }
        emit(AdminList_LoadingState(isLoading: false));
        DebugLogger.printLog("$responseStatus - $responseMessage - thành công");
        add(AdminListLoadEvent(roleIds: _rolePlayer.roleId.toString()));
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");

        emit(AdminList_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: responseSuccess));
      }
    } catch (e) {
      emit(AdminList_LoadingState(isLoading: false));
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _getStationIdEvent(
      GetStationIdEvent event, Emitter<AdminListState> emit) async {
    emit(AdminList_ChangeState());
    emit(AdminList_LoadingState(isLoading: true));
    try {
      var results = await RoleRepository().roles();
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        RoleModelResponse roleModelResponse =
            RoleModelResponse.fromJson(responseBody);
        if (roleModelResponse.data != null) {
          for (var dataRole in roleModelResponse.data!) {
            if (dataRole.roleCode == "STATION_ADMIN") {
              _rolePlayer = dataRole;
              break;
            }
          }
        }
        emit(AdminList_LoadingState(isLoading: false));
        DebugLogger.printLog("$responseStatus - $responseMessage - thành công");
        add(AdminListLoadEvent(roleIds: _rolePlayer.roleId.toString()));
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");

        emit(AdminList_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: responseSuccess));
      }
    } catch (e) {
      emit(AdminList_LoadingState(isLoading: false));
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _adminListLoadEvent(
      AdminListLoadEvent event, Emitter<AdminListState> emit) async {
    emit(AdminList_ChangeState());

    emit(AdminList_LoadingState(isLoading: true));
    try {
      String? search = event.search ?? "";

      String? statusCodes = event.search ?? "";

      String? roleIds = event.roleIds ?? "";

      String? sorter = event.search ?? "";

      String? current = event.current ?? "";

      String? pageSize = "10";

      String? stationId = event.stationId ?? "";

      // var results = await AdminListRepository().listWithSearch(
      //     search, statusCodes, roleIds, sorter, current, pageSize, stationId);

      // 1. Decode JSON
      // (responseJson bây giờ là Map<String, dynamic>)
      var responseJson = jsonDecode(adminListJson);
      dynamic results = {"body": responseJson, "success": true};

      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        AdminListModelResponse adminListModelResponse =
            AdminListModelResponse.fromJson(responseBody);
        List<AdminListModel> _adminList = [];

        emit(AdminList_LoadingState(isLoading: false));
        try {
          if (adminListModelResponse.data != null) {
            if (adminListModelResponse.data!.isNotEmpty) {
              _adminList = adminListModelResponse.data!.where((admin) {
                return admin.roleId == _rolePlayer.roleId;
              }).toList();
              for (var _admin in _adminList) {
                _admin.username =
                    Utf8Encoding().decode(_admin.username.toString());
                _admin.email = Utf8Encoding().decode(_admin.email.toString());
                _admin.statusName =
                    Utf8Encoding().decode(_admin.statusName.toString());
              }
              // 1. Dùng map() để lấy tất cả statusName (bao gồm cả null và trùng lặp)
              // 2. Dùng whereType<String>() để lọc bỏ null
              // 3. Dùng toSet() để loại bỏ trùng lặp
              // 4. Dùng toList() để chuyển về danh sách (List)
              List<String> statusNames = _adminList
                  .map((admin) => admin.statusName)
                  .whereType<String>()
                  .toSet()
                  .toList();
              AdminListMetaModel metaModel = adminListModelResponse.meta!;
              emit(AdminListSuccessState(
                  AdminList: _adminList,
                  statusNames: statusNames,
                  meta: metaModel));
            }
          }
        } catch (e) {
          emit(AdminListEmptyState());
          DebugLogger.printLog(e.toString());
        }
        DebugLogger.printLog("$responseStatus - $responseMessage - thành công");
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");

        emit(AdminList_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: responseSuccess));
      }
    } catch (e) {
      emit(AdminList_LoadingState(isLoading: false));
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
      DebugLogger.printLog(e.toString());
    }
  }
}
