import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/model/login_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/repository/login_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/shared_preferences/login_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/models/role_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/repository/role_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  String _email = "";
  LoginBloc() : super(LoginInitial()) {
    on<LoginInitialEvent>(_loginInitialEvent);
    on<SubmitLoginEvent>(_submitLoginEvent);
    on<ShowRegisterEvent>(_showRegisterEvent);
  }

  FutureOr<void> _loginInitialEvent(
      LoginInitialEvent event, Emitter<LoginState> emit) {
    emit(Login_ChangeState());
    _email = "";
    if (LoginPref.getEmail().toString() != "") {
      _email = LoginPref.getEmail().toString();
    } else {
      emit(LoginInitial());
    }
    if (_email != "") {
      emit(LoginInitial(email: _email));
    }
  }

  FutureOr<void> _submitLoginEvent(
      SubmitLoginEvent event, Emitter<LoginState> emit) async {
    emit(Login_ChangeState());

    emit(Login_LoadingState(isLoading: true));
    try {
      LoginModel loginModel =
          LoginModel(email: event.email, password: event.password);
      var results = await LoginRepository().login(loginModel);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        //$ Get role

        AuthenticationModelResponse authenticationModelResponse =
            AuthenticationModelResponse.fromJson(responseBody);
        if (authenticationModelResponse.data != null) {
          if (authenticationModelResponse.data?.roleCode != null) {
            if (authenticationModelResponse.data?.roleCode == "STATION_OWNER" ||
                authenticationModelResponse.data?.roleCode == "STATION_ADMIN") {
              AuthenticationPref.setRoleCode(
                  authenticationModelResponse.data?.roleCode ?? "");

              AuthenticationPref.setAccountID(
                  authenticationModelResponse.data?.accountId as int);
              AuthenticationPref.setAccessToken(
                  authenticationModelResponse.data?.accessToken.toString() ??
                      "");
              AuthenticationPref.setAccessExpiredAt(authenticationModelResponse
                      .data?.accessExpiredAt
                      .toString() ??
                  "");
              AuthenticationPref.setPassword(event.password.toString());
              AuthenticationPref.setEmail(event.email.toString());
              List<String>? stationJsonList = authenticationModelResponse
                  .data?.stations!
                  .map((s) => s.toJson())
                  .toList();

              AuthenticationPref.setStationsJson(stationJsonList ?? []);

              emit(Login_LoadingState(isLoading: false));
              emit(LoginSuccessState(
                  authenticationModel: authenticationModelResponse.data!));
              DebugLogger.printLog(
                  "$responseStatus - $responseMessage - thành công");

              emit(ShowSnackBarActionState(
                  message: "Đăng nhập thành công", success: responseSuccess));
              return;
            } else {
              emit(Login_LoadingState(isLoading: false));
              emit(ShowSnackBarActionState(
                  message: "Tài khoản không có quyền truy cập",
                  success: false));
              return;
            }
          }
        }
        emit(Login_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: false));
      } else if (responseStatus == 404) {
        DebugLogger.printLog("$responseStatus - $responseMessage");

        emit(Login_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: "Email hoặc mật khẩu không đúng",
            success: responseSuccess));
      } else if (responseStatus == 401) {
        DebugLogger.printLog("$responseStatus - $responseMessage");

        emit(Login_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: "Email hoặc mật khẩu không đúng",
            success: responseSuccess));
      } else if (responseStatus == 403) {
        DebugLogger.printLog("Chưa xác thực email");

        emit(Login_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: "Chưa xác thực email", success: responseSuccess));
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");

        emit(Login_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: responseSuccess));
      }
    } catch (e) {
      emit(Login_LoadingState(isLoading: false));
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _showRegisterEvent(
      ShowRegisterEvent event, Emitter<LoginState> emit) {
    Get.toNamed(registerPageRoute);
  }

  void _getRole() async {
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
            dataRole.roleName = Utf8Encoding().decode(dataRole.roleName ?? "");
          }
        }
      } else {}
    } catch (e) {
      DebugLogger.printLog(e.toString());
    }
  }
}
