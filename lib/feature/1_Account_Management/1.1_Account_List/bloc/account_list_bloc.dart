// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/model/account_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/repository/account_list_repository.dart';

part 'account_list_event.dart';
part 'account_list_state.dart';

class AccountListBloc extends Bloc<AccountListEvent, AccountListState> {
  AccountListBloc() : super(AccountListInitial()) {
    on<AccountListInitialEvent>(_accountListInitialEvent);
    on<SearchEvent>(_searchEvent);
  }

  FutureOr<void> _accountListInitialEvent(
      AccountListInitialEvent event, Emitter<AccountListState> emit) {
    emit(AccountListInitial());
    add(SearchEvent()); // truyền roleIds của player
  }

  FutureOr<void> _searchEvent(
      SearchEvent event, Emitter<AccountListState> emit) async {
    emit(AccountList_ChangeState());

    emit(AccountList_LoadingState(isLoading: true));
    try {
      String? search = event.search ?? "";

      String? statusCodes = event.search ?? "";

      String? roleIds = event.roleIds ?? "";

      String? sorter = event.search ?? "";

      String? current = event.current ?? "";

      String? pageSize = event.pageSize ?? "";

      String? stationId = event.stationId ?? "";

      var results = await AccountListRepository().listWithSearch(
          search, statusCodes, roleIds, sorter, current, pageSize, stationId);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        AccountListModelResponse accountListModelResponse =
            AccountListModelResponse.fromJson(responseBody);

        emit(AccountList_LoadingState(isLoading: false));
        try {
          if (accountListModelResponse.data != null) {
            if (accountListModelResponse.data!.isNotEmpty) {
              emit(AccountListSuccessState());
            }
          }
        } catch (e) {
          emit(AccountListEmptyState());
        }
        DebugLogger.printLog("$responseStatus - $responseMessage - thành công");
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");

        emit(AccountList_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: responseSuccess));
      }
    } catch (e) {
      emit(AccountList_LoadingState(isLoading: false));
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
      DebugLogger.printLog(e.toString());
    }
  }
}
