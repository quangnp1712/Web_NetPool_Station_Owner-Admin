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

  AdminCreateBloc() : super(AdminCreateState()) {
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
    emit(state.copyWith(status: AdminCreateStatus.loading));
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
      emit(state.copyWith(
        captchaText: _captchaText,
        isCaptchaVerified: false,
        isVerifyingCaptcha: false,
        isClearCaptchaController: true,
        stations: stations,
      ));
    } catch (e) {
      DebugLogger.printLog(e.toString());
      emit(state.copyWith(
        message: "Lỗi! Vui lòng thử lại",
        status: AdminCreateStatus.failure,
      ));
    }
  }

  final Random _random = Random();
  FutureOr<void> _generateCaptchaEvent(
      GenerateCaptchaEvent event, Emitter<AdminCreateState> emit) async {
    emit(state.copyWith(status: AdminCreateStatus.loading));

    try {
      _generateCaptcha();
      //setState
      // Reset lại trạng thái xác thực
      emit(state.copyWith(
          captchaText: _captchaText,
          isCaptchaVerified: false,
          isVerifyingCaptcha: false,
          isClearCaptchaController: true));
    } catch (e) {
      DebugLogger.printLog(e.toString());
      emit(state.copyWith(
        status: AdminCreateStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
    }
  }

  FutureOr<void> _handleVerifyCaptchaEvent(
      HandleVerifyCaptchaEvent event, Emitter<AdminCreateState> emit) async {
    try {
      if (event.captcha == "") {
        // (Tùy chọn: hiển thị snackbar lỗi "Vui lòng nhập mã")
        emit(state.copyWith(
            message: "Vui lòng nhập mã", status: AdminCreateStatus.failure));
      } else {
        // _isVerifyingCaptcha - Loading

        emit(state.copyWith(isVerifyingCaptcha: true));

        // --- Giả lập gọi API kiểm tra captcha ---
        await Future.delayed(const Duration(seconds: 1));

        //  So sánh với mã động
        bool isSuccess = event.captcha == _captchaText;

        if (isSuccess) {
          emit(state.copyWith(
            isVerifyingCaptcha: false,
            isCaptchaVerified: true,
            blocState: AdminCreateBlocState.VerifyCaptchaSuccessState,
          ));
        } else {
          // (Tùy chọn: hiển thị snackbar lỗi "Mã xác thực không đúng")
          emit(state.copyWith(
            status: AdminCreateStatus.failure,
            message: "Mã xác thực không đúng",
          ));

          _generateCaptcha(); //  Tạo mã mới nếu sai
          emit(state.copyWith(
            captchaText: _captchaText,
            isCaptchaVerified: false,
            isVerifyingCaptcha: false,
            isClearCaptchaController: true,
          ));
        }
      }
    } catch (e) {
      DebugLogger.printLog(e.toString());
      emit(state.copyWith(
        status: AdminCreateStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
    }
  }

  FutureOr<void> _resetFormEvent(
      ResetFormEvent event, Emitter<AdminCreateState> emit) async {
    emit(AdminCreateState(
      // Bạn có thể giữ lại một số thông tin nếu cần, ví dụ list tỉnh đã load
      blocState: AdminCreateBlocState.ResetFormState,
      stations: state.stations,

      // Các trường còn lại sẽ tự động về null/false/empty theo constructor mặc định
    ));
  }

  FutureOr<void> _submitAdminCreateEvent(
      SubmitAdminCreateEvent event, Emitter<AdminCreateState> emit) async {
    emit(state.copyWith(status: AdminCreateStatus.loading));

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
      // var responseSuccess = true;
      // var responseStatus = 200;
      // var responseMessage = "";

      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          status: AdminCreateStatus.success,
          message: "Đăng ký thành công",
          blocState: AdminCreateBlocState.AdminCreateSuccessState,
        ));

        return;
      } else if (responseStatus == 400) {
        emit(state.copyWith(
          status: AdminCreateStatus.failure,
          message: responseMessage,
        ));
      } else if (responseStatus == 404) {
        emit(state.copyWith(
          status: AdminCreateStatus.failure,
          message: responseMessage,
        ));
      } else if (responseStatus == 409) {
        emit(state.copyWith(
          status: AdminCreateStatus.failure,
          message: responseMessage,
        ));
      } else {
        emit(state.copyWith(
          status: AdminCreateStatus.failure,
          message: "Lỗi! Vui lòng thử lại",
        ));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
      emit(state.copyWith(
        blocState: AdminCreateBlocState.AdminCreateFailState,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminCreateStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _selectedStationIdEvent(
      SelectedStationIdEvent event, Emitter<AdminCreateState> emit) async {
    emit(state.copyWith(
      blocState: AdminCreateBlocState.SelectedStationIdState,
      selectedAdminId: event.newValue,
    ));
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
    if (event.isPickingImage) return; // Chống spam

    emit(state.copyWith(isPickingImage: true));

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
          emit(state.copyWith(
            blocState: AdminCreateBlocState.PickImagesState,
            avatarBase64: dataUri,
            isPickingImage: false,
          ));
        }

        // Cập nhật state: Lấy danh sách cũ + thêm danh sách mới
      } else {
        // Người dùng không chọn gì
        emit(state.copyWith(isPickingImage: false));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AdminCreateStatus.failure,
        message: "Lỗi chọn ảnh",
        isPickingImage: false,
      ));

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
