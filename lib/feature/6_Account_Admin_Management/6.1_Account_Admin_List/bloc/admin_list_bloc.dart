// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_stations_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/model/admin_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/model/admin_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/repository/admin_list_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/shared_preferences/admin_detail_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/role/models/role_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/role/models/role_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/role/repository/role_repository.dart';

part 'admin_list_event.dart';
part 'admin_list_state.dart';

class AdminListBloc extends Bloc<AdminListEvent, AdminListState> {
  AdminListBloc() : super(AdminListState()) {
    on<AdminListInitialEvent>(_adminListInitialEvent);
    on<AdminListLoadEvent>(_adminListLoadEvent);
    on<SelectedStationEvent>(_selectedStationEvent);
    on<SelectedStatusEvent>(_selectedStatusEvent);
    on<ResetPressedEvent>(_resetPressedEvent);
    on<ShowCreateAdminEvent>(_showCreateAdminEvent);
    on<ShowDetailAdminEvent>(_showDetailAdminEvent);
  }

  FutureOr<void> _adminListInitialEvent(
      AdminListInitialEvent event, Emitter<AdminListState> emit) async {
    emit(state.copyWith(status: AdminListStatus.loading));

    //! Get Role > roleId - STATION_ADMIN
    RoleModel _roleAdmin = RoleModel();
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
              _roleAdmin = dataRole;
              break;
            }
          }
        }
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(state.copyWith(
          status: AdminListStatus.failure,
          message: "Lỗi! Vui lòng thử lại",
        ));

        return;
      }
    } catch (e) {
      emit(state.copyWith(
        status: AdminListStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
      DebugLogger.printLog(e.toString());
      return;
    }

    //! Stations Owner
    List<AuthStationsModel> _stationList = [];

    final UserSessionController sessionController = Get.find();
    if (sessionController.stationList.isNotEmpty) {
      _stationList = sessionController.stationList;
    } else {
      emit(state.copyWith(
        blocState: AdminListBlocState.AdminListEmptyState,
      ));
      DebugLogger.printLog("không có station");
      return;
    }

    //! Find all Account Admin
    List<AdminListModel> _adminList = [];
    MetaModel? metaModel;
    try {
      String? search = "";
      String? statusCodes = "";
      String? roleIds = _roleAdmin.roleId.toString();
      String? sorter = "";
      String? current = "0";
      String? pageSize = "20";

      String? stationId = _stationList.first.stationId;
      var results = await AdminListRepository().listWithSearch(
          search, statusCodes, roleIds, sorter, current, pageSize, stationId);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        AdminListModelResponse adminListModelResponse =
            AdminListModelResponse.fromJson(responseBody);
        try {
          // --- SỬA: Lấy statusMap (Name -> Code) ---
          Map<String, String> statusNameMap = {};
          for (var station in _stationList) {
            if (station.statusCode != null && station.statusName != null) {
              // Key là Name (Kích hoạt), Value là Code (ACTIVE)
              statusNameMap[station.statusName!] = station.statusCode!;
            }
          }
          // ------------------------------------
          metaModel = adminListModelResponse.meta!;
          try {
            metaModel.current = (metaModel.current ?? 0) + 1;
          } catch (e) {}
          //
          if (adminListModelResponse.data != null) {
            if (adminListModelResponse.data!.isNotEmpty) {
              _adminList.addAll(adminListModelResponse.data!);

              for (var admin in _adminList) {
                admin.username =
                    Utf8Encoding().decode(admin.username.toString());
                admin.email = Utf8Encoding().decode(admin.email.toString());
                admin.statusName =
                    Utf8Encoding().decode(admin.statusName.toString());
                admin.stationId = _stationList.first.stationId;
                admin.stationName = Utf8Encoding()
                    .decode(_stationList.first.stationName.toString());
              }

              if (state.adminList.isEmpty) {
                // Giả định: Lần đầu tiên load (không filter) phải trả về TẤT CẢ
                // các station và TẤT CẢ các loại status.
                // (Nếu API của bạn không làm vậy, bạn CẦN 1 API GET /filters riêng)

                statusNameMap = {};
                // Tạo Map (Name -> Code)
                for (var admin in _adminList) {
                  if (admin.statusCode != null && admin.statusName != null) {
                    statusNameMap[admin.statusName!] = admin.statusCode!;
                  }
                }
              }

              emit(state.copyWith(
                blocState: AdminListBlocState.AdminListSuccessState,
                meta: metaModel,
                statusNames: statusNameMap.keys.toList(),
                stationList: _stationList,
                adminList: _adminList,
                selectedStationId: stationId,
                masterStatusNameMap: statusNameMap,
                masterAdminList: _adminList,
                roleAdmin: _roleAdmin,
              ));
              DebugLogger.printLog(
                  "$responseStatus - $responseMessage - thành công");

              return;
            }
          }
        } catch (e) {
          emit(state.copyWith(
            blocState: AdminListBlocState.AdminListEmptyState,
          ));
          DebugLogger.printLog(e.toString());
        }
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
      emit(state.copyWith(
          blocState: AdminListBlocState.AdminListEmptyState,
          meta: metaModel,
          stationList: _stationList,
          adminList: _adminList,
          selectedStationId: stationId,
          masterAdminList: _adminList,
          roleAdmin: _roleAdmin));
    } catch (e) {
      emit(state.copyWith(
        status: AdminListStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
        blocState: AdminListBlocState.AdminListEmptyState,
      ));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _adminListLoadEvent(
      AdminListLoadEvent event, Emitter<AdminListState> emit) async {
    emit(state.copyWith(status: AdminListStatus.loading));
    //! Find all Account Admin
    List<AdminListModel> _adminList = [];
    MetaModel metaModel;
    try {
      String? search = event.search ?? "";
      String? statusCodes = event.statusCodes ?? "";
      String? roleIds = state.roleAdmin?.roleId.toString(); //null
      String? sorter = "";
      String? current = event.current ?? "0";
      String? pageSize = "20";
      String? stationId = event.stationId ?? state.selectedStationId; // null

      var results = await AdminListRepository().listWithSearch(
          search, statusCodes, roleIds, sorter, current, pageSize, stationId);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        AdminListModelResponse adminListModelResponse =
            AdminListModelResponse.fromJson(responseBody);
        try {
          if (adminListModelResponse.data != null) {
            if (adminListModelResponse.data!.isNotEmpty) {
              _adminList.addAll(adminListModelResponse.data!);

              for (var admin in _adminList) {
                admin.username =
                    Utf8Encoding().decode(admin.username.toString());
                admin.email = Utf8Encoding().decode(admin.email.toString());
                admin.statusName =
                    Utf8Encoding().decode(admin.statusName.toString());
                admin.stationId = stationId;

                // Tìm tên Station từ danh sách có sẵn trong State
                try {
                  var matchedStation = state.stationList.firstWhere(
                    (s) => s.stationId.toString() == stationId.toString(),
                  );
                  admin.stationName = Utf8Encoding()
                      .decode(matchedStation.stationName.toString());
                } catch (_) {
                  admin.stationName = "";
                }
              }
              metaModel = adminListModelResponse.meta!;
              try {
                metaModel.current = (metaModel.current ?? 0) + 1;
              } catch (e) {}
              // --- SỬA: Lấy statusMap (Name -> Code) ---

              Map<String, String> statusNameMap = {};
              // Logic:
              // 1. Nếu masterStatusNameMap chưa có (lần đầu load) -> Tạo mới.
              // 2. Nếu Station thay đổi (event.stationId khác state.selectedStationId) -> Tạo mới theo data của Station đó.
              // 3. Các trường hợp còn lại (Search, Filter Status, Phân trang) -> Giữ nguyên Map cũ để không mất option filter.

              bool isStationChanged = event.stationId != null &&
                  event.stationId != state.selectedStationId;
              bool isInitialMap = state.masterStatusNameMap.isEmpty;

              if (isStationChanged || isInitialMap) {
                // Tạo lại Map Status từ dữ liệu mới tải về
                statusNameMap = {};
                for (var admin in _adminList) {
                  if (admin.statusCode != null && admin.statusName != null) {
                    statusNameMap[admin.statusName!] = admin.statusCode!;
                  }
                }
              } else {
                // Giữ nguyên Map cũ
                statusNameMap = state.masterStatusNameMap;
              }
              // ----------------------------------------------------

              emit(state.copyWith(
                blocState: AdminListBlocState.AdminListSuccessState,
                status: AdminListStatus.success, // Đánh dấu thành công
                meta: metaModel,

                // Cập nhật danh sách Admin hiển thị
                adminList: _adminList,
                masterAdminList: _adminList, // Có thể dùng làm cache

                // Logic Station List: LUÔN GIỮ NGUYÊN từ state (đã load ở Initial)
                stationList: state.stationList,

                // Logic Status Map: Theo điều kiện bên trên
                masterStatusNameMap: statusNameMap,
                statusNames: statusNameMap.keys.toList(),

                // Cập nhật các giá trị đang được chọn
                selectedStationId: stationId,
                selectedStatus: statusCodes,
              ));
              return;
            } else {
              // Trường hợp data null -> Empty
              emit(state.copyWith(
                blocState: AdminListBlocState.AdminListEmptyState,
                // Vẫn giữ nguyên các filter state cũ
                stationList: state.stationList,
                masterStatusNameMap: state.masterStatusNameMap,
                statusNames: state.statusNames,
                selectedStationId: stationId,
                selectedStatus: statusCodes,
              ));
              return;
            }
          }
        } catch (e) {
          emit(state.copyWith(
            blocState: AdminListBlocState.AdminListEmptyState,
          ));
          DebugLogger.printLog(e.toString());
        }
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
      emit(state.copyWith(
        status: AdminListStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
        blocState: AdminListBlocState.AdminListEmptyState,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminListStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
        blocState: AdminListBlocState.AdminListEmptyState,
      ));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _selectedStatusEvent(
      SelectedStatusEvent event, Emitter<AdminListState> emit) async {
    emit(state.copyWith(
      selectedStatus: event.newValue,
      blocState: AdminListBlocState.SelectedStatusState,
    ));
  }

  FutureOr<void> _selectedStationEvent(
      SelectedStationEvent event, Emitter<AdminListState> emit) async {
    if (state.selectedStationId == null) return;
    try {
      String? selectedStationId = state.stationList
          .firstWhere(
              (e) => e.stationName.toString() == event.newValue.toString())
          .stationId;
      emit(state.copyWith(
        selectedStationId: selectedStationId,
        blocState: AdminListBlocState.SelectedStationState,
      ));
      return;
    } catch (e) {
      DebugLogger.printLog(e.toString());
      emit(state.copyWith(
        status: AdminListStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
      return;
    }
  }

  FutureOr<void> _resetPressedEvent(
      ResetPressedEvent event, Emitter<AdminListState> emit) async {
    emit(state.copyWith(
      blocState: AdminListBlocState.ResetPressedState,
      selectedStatus: null,
      selectedStationId: null,
    ));
  }

  FutureOr<void> _showCreateAdminEvent(
      ShowCreateAdminEvent event, Emitter<AdminListState> emit) async {
    emit(state.copyWith(
      blocState: AdminListBlocState.ShowCreateAdminState,
    ));
  }

  FutureOr<void> _showDetailAdminEvent(
      ShowDetailAdminEvent event, Emitter<AdminListState> emit) async {
    AdminDetailSharedPref.setAccountId(event.accountId.toString());

    emit(state.copyWith(
      blocState: AdminListBlocState.ShowDetailAdminState,
    ));
  }
}
