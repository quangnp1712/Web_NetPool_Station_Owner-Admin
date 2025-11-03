import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/model/register_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/model/register_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/repository/register_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/shared_preferences/register_shared_pref.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterInitialEvent>(_registerInitialEvent);
    on<SubmitRegisterEvent>(_submitRegisterEvent);
    on<ShowLoginEvent>(_showLoginEvent);
  }

  FutureOr<void> _registerInitialEvent(
      RegisterInitialEvent event, Emitter<RegisterState> emit) {}

  FutureOr<void> _submitRegisterEvent(
      SubmitRegisterEvent event, Emitter<RegisterState> emit) async {
    emit(Register_ChangeState());

    emit(Register_LoadingState(isLoading: true));
    try {
      RegisterModel registerModel = RegisterModel(
          email: event.email,
          password: event.password,
          username: event.username,
          phone: event.phone,
          identification: event.identification);

      var results = await RegisterRepository().register(registerModel);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        RegisterModelResponse registerModelResponse =
            RegisterModelResponse.fromJson(responseBody);

        RegisterSharedPref.setEmail(event.email);
        emit(Register_LoadingState(isLoading: false));
        emit(RegisterSuccessState());

        emit(ShowSnackBarActionState(
            message: "Đăng ký thành công", success: responseSuccess));
      } else if (responseStatus == 404) {
        emit(Register_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else if (responseStatus == 401) {
        emit(Register_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else {
        emit(Register_LoadingState(isLoading: false));
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: false));
      }
    } catch (e) {
      emit(Register_LoadingState(isLoading: false));
      DebugLogger.printLog(e.toString());
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
    }
  }

  FutureOr<void> _showLoginEvent(
      ShowLoginEvent event, Emitter<RegisterState> emit) {
    Get.toNamed(loginPageRoute);
  }
}
