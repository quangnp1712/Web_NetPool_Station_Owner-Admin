import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.2_Account_Admin_Create/model/admin_create_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.2_Account_Admin_Create/model/admin_create_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.2_Account_Admin_Create/repository/account_list_repository.dart';

part 'admin_create_event.dart';
part 'admin_create_state.dart';

class AdminCreateBloc extends Bloc<AdminCreateEvent, AdminCreateState> {
  String _captchaText = "";

  AdminCreateBloc() : super(AdminCreateInitial()) {
    on<AdminCreateInitialEvent>(_adminCreateInitialEvent);
    on<GenerateCaptchaEvent>(_generateCaptchaEvent);
    on<HandleVerifyCaptchaEvent>(_handleVerifyCaptchaEvent);
    on<ResetFormEvent>(_resetFormEvent);
    on<SubmitAdminCreateEvent>(_submitAdminCreateEvent);
    on<SelectedStationIdEvent>(_selectedStationIdEvent);
  }
  FutureOr<void> _adminCreateInitialEvent(
      AdminCreateInitialEvent event, Emitter<AdminCreateState> emit) {
    emit(AdminCreateInitial());
    add(GenerateCaptchaEvent());
    // thêm lấy ds station
  }

  final Random _random = Random();
  FutureOr<void> _generateCaptchaEvent(
      GenerateCaptchaEvent event, Emitter<AdminCreateState> emit) async {
    emit(AdminCreate_ChangeState());
    emit(AdminCreate_LoadingState(isLoading: true));

    try {
      _generateCaptcha();
      //setState
      // Reset lại trạng thái xác thực
      emit(GenerateCaptchaState(
          captchaText: _captchaText,
          isCaptchaVerified: false,
          isVerifyingCaptcha: false,
          isClearCaptchaController: true));
      emit(AdminCreate_ChangeState());
      emit(AdminCreate_LoadingState(isLoading: false));
    } catch (e) {
      emit(AdminCreate_ChangeState());
      emit(AdminCreate_LoadingState(isLoading: false));
      DebugLogger.printLog(e.toString());
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
    }
  }

  FutureOr<void> _handleVerifyCaptchaEvent(
      HandleVerifyCaptchaEvent event, Emitter<AdminCreateState> emit) async {
    emit(AdminCreate_ChangeState());

    try {
      if (event.captcha == "") {
        // (Tùy chọn: hiển thị snackbar lỗi "Vui lòng nhập mã")
        emit(ShowSnackBarActionState(
            message: "Vui lòng nhập mã", success: false));
      } else {
        // _isVerifyingCaptcha - Loading

        emit(LoadingCaptchaState(isVerifyingCaptcha: true));

        // --- Giả lập gọi API kiểm tra captcha ---
        await Future.delayed(const Duration(seconds: 1));

        //  So sánh với mã động
        bool isSuccess = event.captcha == _captchaText;

        if (isSuccess) {
          // setState(() {
          //   _isCaptchaVerified = true;
          // });
          emit(HandleVerifyCaptchaState(
              isVerifyingCaptcha: false, isCaptchaVerified: true));
        } else {
          // (Tùy chọn: hiển thị snackbar lỗi "Mã xác thực không đúng")
          emit(ShowSnackBarActionState(
              message: "Mã xác thực không đúng", success: false));
          _generateCaptcha(); //  Tạo mã mới nếu sai
          emit(GenerateCaptchaState(
              captchaText: _captchaText,
              isCaptchaVerified: false,
              isVerifyingCaptcha: false,
              isClearCaptchaController: true));
        }
      }
    } catch (e) {
      emit(AdminCreate_ChangeState());
      emit(AdminCreate_LoadingState(isLoading: false));
      DebugLogger.printLog(e.toString());
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
    }
  }

  FutureOr<void> _resetFormEvent(
      ResetFormEvent event, Emitter<AdminCreateState> emit) async {
    emit(AdminCreate_ChangeState());
    emit(ResetFormState());
  }

  FutureOr<void> _submitAdminCreateEvent(
      SubmitAdminCreateEvent event, Emitter<AdminCreateState> emit) async {
    emit(AdminCreate_ChangeState());

    emit(AdminCreate_LoadingState(isLoading: true));
    try {
      AdminCreateModel adminCreateModel = AdminCreateModel(
          email: event.email,
          password: event.password,
          username: event.username,
          phone: event.phone,
          identification: event.identification);
      // lấy station
      String station = "0";
      var results =
          await AdminCreateRepository().createAdmin(adminCreateModel, station);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        emit(AdminCreate_LoadingState(isLoading: false));
        emit(AdminCreateSuccessState());

        emit(ShowSnackBarActionState(
            message: "Đăng ký thành công", success: responseSuccess));
      } else if (responseStatus == 400) {
        emit(AdminCreate_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else if (responseStatus == 404) {
        emit(AdminCreate_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else if (responseStatus == 401) {
        emit(AdminCreate_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else {
        emit(AdminCreate_LoadingState(isLoading: false));
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: false));
      }
    } catch (e) {
      emit(AdminCreate_LoadingState(isLoading: false));
      DebugLogger.printLog(e.toString());
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
    }
  }

  FutureOr<void> _selectedStationIdEvent(
      SelectedStationIdEvent event, Emitter<AdminCreateState> emit) async {
    emit(AdminCreate_ChangeState());
    emit(SelectedStationIdState(newValue: event.newValue));
  }

  void _generateCaptcha() {
    String newCaptcha = "";
    // Tạo 5 số ngẫu nhiên
    for (int i = 0; i < 5; i++) {
      newCaptcha += _random.nextInt(10).toString();
    }
    _captchaText = newCaptcha;
  }
}
