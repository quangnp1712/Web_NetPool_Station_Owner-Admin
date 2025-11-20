import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_stations_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/model/admin_create_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/model/admin_create_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/repository/account_list_repository.dart';

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
    on<PickAvatarEvent>(_pickAvatarEvent);
  }
  FutureOr<void> _adminCreateInitialEvent(
      AdminCreateInitialEvent event, Emitter<AdminCreateState> emit) {
    emit(AdminCreateInitial());
    emit(AdminCreate_State(isLoading: true));
    try {
      _generateCaptcha();
      final List<String> stationJsonList = AuthenticationPref.getStationsJson();
      List<AuthStationsModel> stations = stationJsonList.isNotEmpty
          ? stationJsonList.map((jsonString) {
              // 1. Decode chuỗi JSON thành Map
              final Map<String, dynamic> map = jsonDecode(jsonString);
              // 2. Chuyển Map thành Object
              return AuthStationsModel.fromMap(map);
            }).toList()
          : [];
      emit(AdminCreate_State(
        isLoading: false,
        captchaText: _captchaText,
        isCaptchaVerified: false,
        isVerifyingCaptcha: false,
        isClearCaptchaController: true,
        stations: stations,
      ));
    } catch (e) {
      emit(AdminCreate_State(isLoading: false));

      DebugLogger.printLog(e.toString());
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
    }
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
    emit(AdminCreate_State(isLoading: true));

    try {
      String avatar = event.avatar != null
          ? await _uploadImagesToFirebase(event.avatar!)
          : "";
      AdminCreateModel adminCreateModel = AdminCreateModel(
          email: event.email,
          password: event.password,
          username: event.username,
          phone: event.phone,
          identification: event.identification,
          avatar: avatar);
      // lấy station

      var results = await AdminCreateRepository()
          .createAdmin(adminCreateModel, event.stationId);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        emit(AdminCreate_LoadingState(isLoading: false));
        emit(AdminCreateSuccessState());

        emit(ShowSnackBarActionState(
            message: "Đăng ký thành công", success: responseSuccess));
        return;
      } else if (responseStatus == 400) {
        emit(AdminCreate_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else if (responseStatus == 404) {
        emit(AdminCreate_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else if (responseStatus == 409) {
        emit(AdminCreate_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else {
        emit(AdminCreate_LoadingState(isLoading: false));
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: false));
      }
      emit(AdminCreateFail_State());
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

  FutureOr<void> _pickAvatarEvent(
      PickAvatarEvent event, Emitter<AdminCreateState> emit) async {
    emit(AdminCreate_ChangeState());
    if (event.isPickingImage) return; // Chống spam

    emit(IsPickingImageState(isPickingImage: true));

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          String base64String = base64Encode(file.bytes!);
          String dataUri =
              "data:image/${file.extension ?? 'png'};base64,$base64String";
          emit(
              PickingImagesState(base64Images: dataUri, isPickingImage: false));
        }

        // Cập nhật state: Lấy danh sách cũ + thêm danh sách mới
      } else {
        // Người dùng không chọn gì
        emit(IsPickingImageState(isPickingImage: false));
      }
    } catch (e) {
      emit(ShowSnackBarActionState(message: "Lỗi chọn ảnh", success: false));
      emit(IsPickingImageState(isPickingImage: false));
      DebugLogger.printLog(e.toString());
    }
  }

  // --- THÊM: HÀM HELPER UPLOAD ẢNH ---
  Future<String> _uploadImagesToFirebase(String base64Images) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    String uploadedUrls = "";

    // (Chúng ta dùng `for` thay vì `forEach` vì `forEach` không hỗ trợ `await`)

    try {
      // 1. Tách chuỗi Base64
      // (data:image/png;base64,iVBOR...)
      final String base64String = base64Images.split(',').last;
      // 2. Decode thành bytes
      final Uint8List imageBytes = base64Decode(base64String);

      // 3. Tạo tên file ngẫu nhiên
      final String fileName =
          'admin_avatar/admin_avatar_${DateTime.now().millisecondsSinceEpoch}.png';

      // 4. Tạo reference (tham chiếu)
      final Reference ref = storage.ref().child(fileName);

      // 5. Upload (dùng putData)
      // (Set metadata để trình duyệt hiển thị đúng)
      final SettableMetadata metadata =
          SettableMetadata(contentType: 'image/png');
      await ref.putData(imageBytes, metadata);

      // 6. Lấy URL
      final String downloadURL = await ref.getDownloadURL();

      // 7. Thêm vào danh sách (dưới dạng MediaModel)
      uploadedUrls = downloadURL;
    } catch (e) {
      DebugLogger.printLog("Lỗi upload 1 ảnh: $e");
      // (Bỏ qua ảnh này và tiếp tục)
    }

    DebugLogger.printLog("Đã upload xong ảnh.");
    return uploadedUrls;
  }
  // ------------------------------------
}
