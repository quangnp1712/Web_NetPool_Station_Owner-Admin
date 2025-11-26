// ignore_for_file: constant_identifier_names

part of 'admin_detail_bloc.dart';

// status
enum AdminDetailStatus { initial, loading, success, failure }

// screenMode
enum ScreenMode { view, edit }

// blocState
enum AdminDetailBlocState {
  Initial,
  AdminUpdateSuccessState,
  SelectedStatusState,
  ResetCaptchaState,
  ChangeStatusLoadingState,
}

const _sentinel = Object();

class AdminDetailState extends Equatable {
  // --- Status & Mode ---
  final AdminDetailStatus status;
  final AdminDetailBlocState blocState;
  final ScreenMode screenMode;
  final String message;
  final String? currentAccountId;

  // --- Data ---
  // Thông tin Admin
  final String? username;
  final String? email;
  final String? phone;
  final String? identification;
  final String? avatar; // URL hoặc Base64
  final String? statusCode;
  final String? statusName;
  final String? password;

  // --- Dropdown Data ---
  final List<AuthStationsModel> stationList;

  // --- Selection ---
  final String? selectedStationId;

  // --- Loading Flags ---
  final bool isPickingImage;

  // --- Captcha (Chỉ dùng khi Edit) ---
  final String captchaText;
  final bool isVerifyingCaptcha;
  final bool isCaptchaVerified;
  final bool isClearCaptchaController;

  // --- Getters ---
  bool get isReadOnly => screenMode == ScreenMode.view;
  bool get isEditMode => screenMode == ScreenMode.edit;

  const AdminDetailState({
    this.status = AdminDetailStatus.initial,
    this.blocState = AdminDetailBlocState.Initial,
    this.message = '',
    this.screenMode = ScreenMode.view, // Mặc định là View
    this.currentAccountId,
    this.username,
    this.email,
    this.phone,
    this.identification,
    this.avatar,
    this.statusCode,
    this.statusName,
    this.password,
    this.stationList = const [],
    this.selectedStationId,
    this.isPickingImage = false,
    this.captchaText = '',
    this.isVerifyingCaptcha = false,
    this.isCaptchaVerified = false,
    this.isClearCaptchaController = false,
  });

  AdminDetailState copyWith({
    AdminDetailStatus? status,
    AdminDetailBlocState? blocState,
    String? message,
    ScreenMode? screenMode,
    String? currentAccountId,
    String? username,
    String? email,
    String? phone,
    String? identification,
    String? avatar,
    String? statusCode,
    String? statusName,
    String? password,
    List<AuthStationsModel>? stationList,
    Object? selectedStationId = _sentinel, // Nullable

    bool? isPickingImage,
    String? captchaText,
    bool? isVerifyingCaptcha,
    bool? isCaptchaVerified,
    bool? isClearCaptchaController,
  }) {
    return AdminDetailState(
      status: status ?? AdminDetailStatus.initial,
      blocState: blocState ?? AdminDetailBlocState.Initial,
      message: message ?? this.message,
      screenMode: screenMode ?? this.screenMode,
      currentAccountId: currentAccountId ?? this.currentAccountId,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      identification: identification ?? this.identification,
      avatar: avatar ?? this.avatar,
      password: password ?? this.password,
      statusCode: statusCode ?? this.statusCode,
      statusName: statusName ?? this.statusName,
      stationList: stationList ?? this.stationList,
      selectedStationId: selectedStationId == _sentinel
          ? this.selectedStationId
          : selectedStationId as String?,
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
        blocState,
        message,
        screenMode,
        currentAccountId,
        username,
        email,
        phone,
        identification,
        password,
        avatar,
        statusCode,
        statusName,
        stationList,
        selectedStationId,
        isPickingImage,
        captchaText,
        isVerifyingCaptcha,
        isCaptchaVerified,
        isClearCaptchaController,
      ];
}
