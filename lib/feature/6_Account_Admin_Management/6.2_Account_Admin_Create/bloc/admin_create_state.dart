// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: camel_case_types

part of 'admin_create_bloc.dart';

sealed class AdminCreateState {
  const AdminCreateState();
}

final class AdminCreateInitial extends AdminCreateState {}

abstract class AdminCreateActionState extends AdminCreateState {}

class AdminCreate_State extends AdminCreateState {
  bool? isLoading;

  //GenerateCaptchaState
  String? captchaText;
  bool? isCaptchaVerified;
  bool? isVerifyingCaptcha;
  bool? isClearCaptchaController;

  //SelectedStationIdState
  int? newValue;

  // list station
  List<AuthStationsModel>? stations;
  AdminCreate_State({
    this.isLoading,
    this.captchaText,
    this.isCaptchaVerified,
    this.isVerifyingCaptcha,
    this.isClearCaptchaController,
    this.newValue,
    this.stations,
  });
}

class AdminCreate_ChangeState extends AdminCreateState {}

class AdminCreate_LoadingState extends AdminCreateState {
  final bool isLoading;

  AdminCreate_LoadingState({required this.isLoading});
}

class AdminCreateSuccessState extends AdminCreateActionState {}

class ShowSnackBarActionState extends AdminCreateActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}

class GenerateCaptchaState extends AdminCreateState {
  String captchaText;
  bool isCaptchaVerified;
  bool isVerifyingCaptcha;
  bool isClearCaptchaController;
  GenerateCaptchaState({
    required this.captchaText,
    required this.isCaptchaVerified,
    required this.isVerifyingCaptcha,
    required this.isClearCaptchaController,
  });
}

class HandleVerifyCaptchaState extends AdminCreateState {
  String? captchaText;
  bool? isCaptchaVerified;
  bool? isVerifyingCaptcha;
  bool? isClearCaptchaController;
  HandleVerifyCaptchaState({
    this.captchaText,
    this.isCaptchaVerified,
    this.isVerifyingCaptcha,
    this.isClearCaptchaController,
  });
}

class LoadingCaptchaState extends AdminCreateState {
  bool isVerifyingCaptcha;

  LoadingCaptchaState({
    required this.isVerifyingCaptcha,
  });
}

class ResetFormState extends AdminCreateState {}

class AdminCreateFail_State extends AdminCreateState {}

class SelectedStationIdState extends AdminCreateState {
  int? newValue;
  SelectedStationIdState({
    this.newValue,
  });
}

class IsPickingImageState extends AdminCreateState {
  bool isPickingImage;
  IsPickingImageState({
    required this.isPickingImage,
  });
}

class PickingImagesState extends AdminCreateState {
  bool isPickingImage;
  String base64Images;
  PickingImagesState({
    required this.isPickingImage,
    required this.base64Images,
  });
}
