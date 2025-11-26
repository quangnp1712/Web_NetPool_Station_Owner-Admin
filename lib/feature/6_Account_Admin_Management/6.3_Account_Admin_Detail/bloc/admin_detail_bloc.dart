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
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/model/admin_detail_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/model/admin_detail_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/repository/account_detail_repository.dart';

part 'admin_detail_event.dart';
part 'admin_detail_state.dart';

class AdminDetailBloc extends Bloc<AdminDetailEvent, AdminDetailState> {
  AdminDetailBloc() : super(const AdminDetailState()) {
    on<InitAdminDetailEvent>(_onInit);
    on<ToggleEditModeEvent>(_onToggleEditMode);
    on<PickAvatarEvent>(_onPickAvatar);
    on<GenerateCaptchaEvent>(_onGenerateCaptcha);
    on<HandleVerifyCaptchaEvent>(_onVerifyCaptcha);
    on<SubmitUpdateAdminEvent>(_onSubmit);
    on<SelectedStationEvent>(_onSelectedStationEvent);
    on<SelectedStatusEvent>(_onSelectedStatusEvent);
    on<SubmitChangeStatusEvent>(_onSubmitChangeStatusEvent);
  }

  // 1. Init: Load thông tin Admin + List Station
  Future<void> _onInit(
      InitAdminDetailEvent event, Emitter<AdminDetailState> emit) async {
    emit(state.copyWith(status: AdminDetailStatus.loading));
    try {
      if (event.accountId == "") {
        emit(state.copyWith(
          status: AdminDetailStatus.failure,
          message: "Lỗi vui lòng thử lại",
        ));
        DebugLogger.printLog("Lỗi: không có accountID ");
        return;
      }

      //! A.  gọi API lấy chi tiết Admin
      AdminDetailModel _admin;
      String? _selectedStationId;
      var results =
          await AdminDetailRepository().getDetailAdmin(event.accountId);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        AdminDetailModelResponse resultsBody =
            AdminDetailModelResponse.fromJson(responseBody);
        if (resultsBody.data != null) {
          _admin = resultsBody.data!;
          if (_admin.stations != null) {
            // _selectedStationId = _admin.stations!.first.stationId;
            _selectedStationId = _admin.stations!.first.stationName;
          } else {
            DebugLogger.printLog("Lỗi: $responseMessage ");
            emit(state.copyWith(
              status: AdminDetailStatus.failure,
              message: "Lỗi vui lòng thử lại",
            ));
            return;
          }
        } else {
          DebugLogger.printLog("Lỗi: $responseMessage ");
          emit(state.copyWith(
            status: AdminDetailStatus.failure,
            message: "Lỗi vui lòng thử lại",
          ));
          return;
        }

        //! B.  gọi API lấy danh sách Station (để fill dropdown khi edit)
        final List<String> stationJsonList =
            AuthenticationPref.getStationsJson();
        List<AuthStationsModel> stations = stationJsonList.isNotEmpty
            ? stationJsonList.map((jsonString) {
                // 1. Decode chuỗi JSON thành Map
                final Map<String, dynamic> map = jsonDecode(jsonString);
                // 2. Chuyển Map thành Object
                return AuthStationsModel.fromMap(map);
              }).toList()
            : [];

        emit(state.copyWith(
          screenMode: ScreenMode.view, // Mặc định vào là xem
          currentAccountId: event.accountId,

          // Data
          username: _admin.username,
          email: _admin.email,
          phone: _admin.phone,
          identification: _admin.identification,
          avatar: _admin.avatar,
          statusCode: _admin.statusCode,
          statusName: _admin.statusName,
          selectedStationId: _selectedStationId,
          password: _admin.password,

          // Dropdown List
          stationList: stations,
        ));
        return;
      } else {
        emit(state.copyWith(
          status: AdminDetailStatus.failure,
          message: "Lỗi vui lòng thử lại",
        ));
        return;
      }
    } catch (e) {
      emit(state.copyWith(
          status: AdminDetailStatus.failure, message: "Lỗi tải dữ liệu: $e"));
    }
  }

  // 2. Toggle Edit Mode
  void _onToggleEditMode(
      ToggleEditModeEvent event, Emitter<AdminDetailState> emit) {
    emit(state.copyWith(
      screenMode: event.enableEdit ? ScreenMode.edit : ScreenMode.view,
      // Reset Captcha khi chuyển mode
      captchaText: event.enableEdit ? _generateRandomCaptcha() : '',
      isCaptchaVerified: false,
      isClearCaptchaController: true,
    ));
  }

  // 3. Pick Avatar
  Future<void> _onPickAvatar(
      PickAvatarEvent event, Emitter<AdminDetailState> emit) async {
    emit(state.copyWith(isPickingImage: true));
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        String base64String = base64Encode(result.files.single.bytes!);
        String ext = result.files.single.extension ?? 'png';
        String dataUri = "data:image/$ext;base64,$base64String";

        emit(state.copyWith(isPickingImage: false, avatar: dataUri));
      } else {
        emit(state.copyWith(isPickingImage: false));
      }
    } catch (e) {
      emit(state.copyWith(isPickingImage: false));
    }
  }

  // 4. Captcha Logic
  void _onGenerateCaptcha(
      GenerateCaptchaEvent event, Emitter<AdminDetailState> emit) {
    emit(state.copyWith(
        captchaText: _generateRandomCaptcha(),
        isCaptchaVerified: false,
        isClearCaptchaController: true));
  }

  void _onVerifyCaptcha(
      HandleVerifyCaptchaEvent event, Emitter<AdminDetailState> emit) {
    bool isValid = event.input == state.captchaText;
    emit(state.copyWith(
        isCaptchaVerified: isValid,
        isVerifyingCaptcha: false, // Tắt loading
        isClearCaptchaController: !isValid // Clear text nếu sai
        ));
  }

  // 5. Submit Update
  Future<void> _onSubmit(
      SubmitUpdateAdminEvent event, Emitter<AdminDetailState> emit) async {
    emit(state.copyWith(status: AdminDetailStatus.loading));
    try {
      //$ 1. LOGIC MERGE DỮ LIỆU (Giữ cũ nếu mới rỗng)

      // Username
      final String finalUsername =
          (event.username != null && event.username!.trim().isNotEmpty)
              ? event.username!
              : (state.username ?? "");

      // Email
      final String finalEmail =
          (event.email != null && event.email!.trim().isNotEmpty)
              ? event.email!
              : (state.email ?? "");

      // Phone
      final String finalPhone =
          (event.phone != null && event.phone!.trim().isNotEmpty)
              ? event.phone!
              : (state.phone ?? "");

      // Identification (CCCD)
      final String finalIdentification = (event.identification != null &&
              event.identification!.trim().isNotEmpty)
          ? event.identification!
          : (state.identification ?? "");

      // Station ID (Đã được cập nhật vào state khi chọn dropdown)
      final String finalStationId = state.selectedStationId ?? "";

      // Avatar (Đã được cập nhật vào state khi pick ảnh)
      String finalAvatar = "";

      finalAvatar = state.avatar != null
          ? await _uploadImagesToFirebase(state.avatar!)
          : "";
      if (finalAvatar == "") {
        finalAvatar = state.avatar ?? "";
      }

      // Password (Riêng password: Nếu rỗng thì gửi null hoặc chuỗi rỗng tùy BE quy định để không đổi pass)
      final String? finalPassword =
          (event.password != null && event.password!.trim().isNotEmpty)
              ? event.password
              : (state.password ??
                  ""); // Backend thường check null để bỏ qua update pass

      //$ 2. GỌI API UPDATE
      AdminDetailModel adminDetailModel = AdminDetailModel(
          username: finalUsername,
          email: finalEmail,
          password: finalPassword,
          phone: finalPhone,
          identification: finalIdentification,
          avatar: finalAvatar);
      var results = await AdminDetailRepository()
          .updateAdmin(adminDetailModel, state.currentAccountId ?? "");
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        //$ 3. THÀNH CÔNG
        emit(state.copyWith(
          status: AdminDetailStatus.success,
          message: "Cập nhật thành công!",
          screenMode: ScreenMode.view, // Tự động chuyển về chế độ Xem
        ));

        // (Optional) Reload lại data từ server để chắc chắn đồng bộ
        add(InitAdminDetailEvent(accountId: state.currentAccountId!));

        return;
      } else if (responseStatus == 400) {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: responseMessage,
        ));
      } else if (responseStatus == 404) {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: responseMessage,
        ));
      } else if (responseStatus == 409) {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: responseMessage,
        ));
      } else {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: "Lỗi! Vui lòng thử lại",
        ));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: "Cập nhật thất bại: $e"));
    }
  }

  Future<void> _onSelectedStationEvent(
      SelectedStationEvent event, Emitter<AdminDetailState> emit) async {
    emit(state.copyWith(selectedStationId: event.stationId));
  }

  Future<void> _onSelectedStatusEvent(
      SelectedStatusEvent event, Emitter<AdminDetailState> emit) async {
    String statusName = event.status == 'ENABLE'
        ? 'Kích hoạt'
        : (event.status == 'DISABLE' ? 'Vô hiệu' : event.status ?? "");
    emit(state.copyWith(statusCode: event.status, statusName: statusName));
  }

  Future<void> _onSubmitChangeStatusEvent(
      SubmitChangeStatusEvent event, Emitter<AdminDetailState> emit) async {
    // Dùng statusChangeStatus để chỉ loading cái nút nhỏ, không loading toàn màn hình
    emit(state.copyWith(
        blocState: AdminDetailBlocState.ChangeStatusLoadingState));
    try {
      String status = "";
      if (state.statusCode == 'ENABLE') {
        status = "enable";
      }
      if (state.statusCode == 'DISABLE') {
        status = "disable";
      }
      var results = await AdminDetailRepository()
          .updateStatusAdmin(state.currentAccountId!, status);

      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.success,
          message: "Đổi trạng thái thành công!",
          // Cập nhật status mới vào state
        ));
      } else if (responseStatus == 400) {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: responseMessage,
        ));
      } else if (responseStatus == 404) {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: responseMessage,
        ));
      } else if (responseStatus == 409) {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: responseMessage,
        ));
      } else {
        emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: "Lỗi! Vui lòng thử lại",
        ));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
          blocState: AdminDetailBlocState.ResetCaptchaState,
          status: AdminDetailStatus.failure,
          message: "Lỗi đổi trạng thái: $e"));
    }
  }

  String _generateRandomCaptcha() {
    return Random().nextInt(999999).toString().padLeft(6, '0');
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
