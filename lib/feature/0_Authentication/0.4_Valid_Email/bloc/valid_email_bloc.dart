import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/shared_preferences/login_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/shared_preferences/register_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/model/verify_email_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/repository/verify_email_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/shared_preferences/verify_email_shared_preferences.dart';

part 'valid_email_event.dart';
part 'valid_email_state.dart';

class ValidEmailBloc extends Bloc<ValidEmailEvent, ValidEmailState> {
  String _email = "";

  ValidEmailBloc() : super(ValidEmailInitial()) {
    on<ValidEmailInitialEvent>(_validEmailInitialEvent);
    on<SendValidCodeEvent>(_sendValidEmailEvent);
    on<SubmitValidEmailEvent>(_submitValidEmailEvent);
    on<ShowVerifyEmailEvent>(_showVerifyEmailEvent);
  }

  FutureOr<void> _validEmailInitialEvent(
      ValidEmailInitialEvent event, Emitter<ValidEmailState> emit) {
    emit(ValidEmail_ChangeState());
    if (RegisterSharedPref.getEmail().toString() != "") {
      _email = RegisterSharedPref.getEmail().toString();
    } else if (VerifyEmailPref.getEmail().toString() != "") {
      _email = VerifyEmailPref.getEmail().toString();
    } else {
      emit(ValidEmailInitial());
    }
    if (_email != "") {
      emit(ValidEmailInitial(email: _email));
      add(SendValidCodeEvent(email: _email));
    }
  }

  FutureOr<void> _showVerifyEmailEvent(
      ShowVerifyEmailEvent event, Emitter<ValidEmailState> emit) {
    RegisterSharedPref.clearEmail();
    VerifyEmailPref.setEmail(event.email.toString());

    Get.toNamed(validEmailPageRoute);
  }

  FutureOr<void> _sendValidEmailEvent(
      SendValidCodeEvent event, Emitter<ValidEmailState> emit) async {
    emit(ValidEmail_ChangeState());

    emit(ValidEmail_LoadingState(isLoading: true));
    emit(ValidEmailInitial(email: _email));

    try {
      VerfyEmailModel validEmailModel = VerfyEmailModel(
        email: event.email,
      );

      var results =
          await VerifyEmailRepository().SendVerifyCode(validEmailModel);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        emit(ValidEmail_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: "OTP đã được gửi đến Email $_email",
            success: responseSuccess));
        DebugLogger.printLog("$responseStatus - $responseMessage - thanh cong");
      } else if (responseStatus == 404) {
        emit(ValidEmail_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else if (responseStatus == 401) {
        emit(ValidEmail_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else {
        emit(ValidEmail_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: false));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
    } catch (e) {
      emit(ValidEmail_LoadingState(isLoading: false));
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _submitValidEmailEvent(
      SubmitValidEmailEvent event, Emitter<ValidEmailState> emit) async {
    emit(ValidEmail_ChangeState());

    emit(ValidEmail_LoadingState(isLoading: true));
    try {
      VerfyEmailModel validEmailModel = VerfyEmailModel(
        verificationCode: event.verificationCode,
      );

      var results = await VerifyEmailRepository().VerifyEmail(validEmailModel);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        emit(ValidEmail_LoadingState(isLoading: false));
        DebugLogger.printLog("$responseStatus - $responseMessage - thanh cong");
        LoginPref.setEmail(_email);
        emit(ShowSnackBarActionState(
            message: "Email: $_email xác thực thành công !",
            success: responseSuccess));
        Get.offAllNamed(loginPageRoute);
      } else if (responseStatus == 404) {
        emit(ValidEmail_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: "Mã OTP không đúng", success: responseSuccess));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else if (responseStatus == 401) {
        emit(ValidEmail_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: responseSuccess));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else {
        emit(ValidEmail_LoadingState(isLoading: false));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
    } catch (e) {
      emit(ValidEmail_LoadingState(isLoading: false));
      DebugLogger.printLog(e.toString());
    }
  }
}
