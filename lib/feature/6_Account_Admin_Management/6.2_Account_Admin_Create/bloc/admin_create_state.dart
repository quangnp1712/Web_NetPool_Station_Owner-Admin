// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
// ignore_for_file: camel_case_types

part of 'admin_create_bloc.dart';

// Dùng để phân biệt giữa "không truyền" (giữ cũ) và "truyền null" (xóa).
const _sentinel = Object();

// status
enum AdminCreateStatus {
  initial,
  loading,
  success,
  failure,
}

// blocState
enum AdminCreateBlocState {
  Initial,
  AdminCreateSuccessState,
  AdminCreateFailState,
  GenerateCaptchaState,
  ResetFormState,
  PickImagesState,
  RemoveImageState,
  VerifyCaptchaSuccessState,
  SelectedStationIdState,
}

class AdminCreateState extends Equatable {
  // --- 1. General Status & Message ---

  final AdminCreateStatus status;
  final AdminCreateBlocState blocState;
  final String message;

  // --- 2. Data Lists ---
  final List<AuthStationsModel> stations;

  // --- 3. Form Selections & Inputs ---
  final int? selectedAdminId; // Thay cho 'newValue' trong SelectedAdminIdState
  final String? avatarBase64; // Thay cho 'base64Images' (String)

  // --- 4. Loading Flags ---
  final bool isPickingImage; // Loading khi chọn ảnh

  // --- 5. Captcha State ---
  final String captchaText;
  final bool isVerifyingCaptcha;
  final bool isCaptchaVerified;
  final bool isClearCaptchaController;

  const AdminCreateState({
    this.status = AdminCreateStatus.initial,
    this.blocState = AdminCreateBlocState.Initial,
    this.message = '',
    this.stations = const [],
    this.selectedAdminId,
    this.avatarBase64,
    this.isPickingImage = false,
    this.captchaText = '',
    this.isVerifyingCaptcha = false,
    this.isCaptchaVerified = false,
    this.isClearCaptchaController = false,
  });

  // --- COPY WITH ---
  AdminCreateState copyWith({
    AdminCreateStatus? status,
    AdminCreateBlocState? blocState,
    String? message,
    List<AuthStationsModel>? stations,

    // Các trường có thể set NULL -> dùng Object? = _sentinel
    Object? selectedAdminId = _sentinel,
    Object? avatarBase64 = _sentinel,
    bool? isLoading,
    bool? isPickingImage,
    String? captchaText,
    bool? isVerifyingCaptcha,
    bool? isCaptchaVerified,
    bool? isClearCaptchaController,
  }) {
    return AdminCreateState(
      // Tự động reset về initial nếu không truyền status mới (để tắt loading/snackbar)
      status: status ?? AdminCreateStatus.initial,
      blocState: blocState ?? AdminCreateBlocState.Initial,
      message: message ?? this.message,

      stations: stations ?? this.stations,

      // Logic Sentinel cho các trường Nullable
      selectedAdminId: selectedAdminId == _sentinel
          ? this.selectedAdminId
          : selectedAdminId as int?,
      avatarBase64: avatarBase64 == _sentinel
          ? this.avatarBase64
          : avatarBase64 as String?,

      isPickingImage: isPickingImage ?? this.isPickingImage,

      captchaText: captchaText ?? this.captchaText,
      isVerifyingCaptcha: isVerifyingCaptcha ?? this.isVerifyingCaptcha,
      isCaptchaVerified: isCaptchaVerified ?? this.isCaptchaVerified,
      isClearCaptchaController:
          isClearCaptchaController ?? this.isClearCaptchaController,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        stations,
        selectedAdminId,
        avatarBase64,
        isPickingImage,
        captchaText,
        isVerifyingCaptcha,
        isCaptchaVerified,
        isClearCaptchaController,
      ];
}
