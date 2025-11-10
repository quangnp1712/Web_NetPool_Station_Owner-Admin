// ignore_for_file: unused_local_variable, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Player_Management/1.1_Account_List/model/account_list_mock_data.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Player_Management/1.1_Account_List/model/account_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Player_Management/1.1_Account_List/model/account_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/models/role_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/models/role_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/repository/role_repository.dart';

part 'account_list_event.dart';
part 'account_list_state.dart';

class AccountListBloc extends Bloc<AccountListEvent, AccountListState> {
  RoleModel _rolePlayer = RoleModel();

  AccountListBloc() : super(AccountListInitial()) {
    on<AccountListInitialEvent>(_accountListInitialEvent);
    on<RoleEvent>(_roleEvent);
    on<AccountListLoadEvent>(_accountListLoadEvent);
  }

  FutureOr<void> _accountListInitialEvent(
    AccountListInitialEvent event,
    Emitter<AccountListState> emit,
  ) {
    emit(AccountListInitial());
    add(RoleEvent()); // truyền roleIds của player
  }

  FutureOr<void> _roleEvent(
    RoleEvent event,
    Emitter<AccountListState> emit,
  ) async {
    emit(AccountList_ChangeState());
    emit(AccountList_LoadingState(isLoading: true));
    try {
      var results = await RoleRepository().roles();
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        RoleModelResponse roleModelResponse = RoleModelResponse.fromJson(
          responseBody,
        );
        if (roleModelResponse.data != null) {
          for (var dataRole in roleModelResponse.data!) {
            if (dataRole.roleCode == "PLAYER") {
              _rolePlayer = dataRole;
              break;
            }
          }
        }
        DebugLogger.printLog("$responseStatus - $responseMessage - thành công");
        add(AccountListLoadEvent(roleIds: _rolePlayer.roleId.toString()));
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");

        emit(
          ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại",
            success: responseSuccess,
          ),
        );
      }
    } catch (e) {
      emit(
        ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại",
          success: false,
        ),
      );
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _accountListLoadEvent(
    AccountListLoadEvent event,
    Emitter<AccountListState> emit,
  ) async {
    emit(AccountList_ChangeState());
    emit(AccountList_LoadingState(isLoading: true));

    try {
      String? search = event.search ?? "";

      String? statusCodes = event.search ?? "";

      String? roleIds = event.roleIds ?? "";

      String? sorter = event.search ?? "";

      String? current = event.current ?? "";

      String? pageSize = "10";

      String? stationId = event.stationId ?? "";

      // var results = await AccountListRepository().listWithSearch(
      //     search, statusCodes, roleIds, sorter, current, pageSize, stationId);

      // 1. Decode JSON
      // (responseJson bây giờ là Map<String, dynamic>)
      var responseJson = jsonDecode(accountListJson);
      dynamic results = {"body": responseJson, "success": true};

      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        AccountListModelResponse accountListModelResponse =
            AccountListModelResponse.fromJson(responseBody);
        List<AccountListModel> accountList = [];

        try {
          if (accountListModelResponse.data != null) {
            if (accountListModelResponse.data!.isNotEmpty) {
              accountList = accountListModelResponse.data!.where((account) {
                return account.roleId == _rolePlayer.roleId;
              }).toList();
              if (accountList.isEmpty) {
                emit(AccountList_ChangeState());
                emit(AccountListEmptyState());
                return;
              } else {
                for (var _account in accountList) {
                  _account.username = Utf8Encoding().decode(
                    _account.username.toString(),
                  );
                  _account.email = Utf8Encoding().decode(
                    _account.email.toString(),
                  );
                  _account.statusName = Utf8Encoding().decode(
                    _account.statusName.toString(),
                  );
                }
                // 1. Dùng map() để lấy tất cả statusName (bao gồm cả null và trùng lặp)
                // 2. Dùng whereType<String>() để lọc bỏ null
                // 3. Dùng toSet() để loại bỏ trùng lặp
                // 4. Dùng toList() để chuyển về danh sách (List)

                List<String> statusNames = accountList
                    .map((account) => account.statusName)
                    .whereType<String>()
                    .toSet()
                    .toList();
                ACLMetaModel metaModel = accountListModelResponse.meta!;
                try {
                  // if (metaModel.current! >= 0) {
                  //   metaModel.current = metaModel.current! + 1;
                  // }
                } catch (e) {}
                emit(AccountList_ChangeState());
                emit(
                  AccountListSuccessState(
                    accountList: accountList,
                    statusNames: statusNames,
                    meta: metaModel,
                  ),
                );
                return;
              }
            }
          }

          emit(AccountList_ChangeState());
          emit(AccountListEmptyState());
        } catch (e) {
          emit(AccountListEmptyState());
          DebugLogger.printLog(e.toString());
        }
        DebugLogger.printLog("$responseStatus - $responseMessage - thành công");
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(AccountListEmptyState());
        emit(
          ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại",
            success: responseSuccess,
          ),
        );
      }
    } catch (e) {
      emit(AccountListEmptyState());

      emit(AccountList_LoadingState(isLoading: false));
      emit(
        ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại",
          success: false,
        ),
      );
      DebugLogger.printLog(e.toString());
    }
  }
}
