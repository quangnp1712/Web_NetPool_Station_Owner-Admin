// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: camel_case_types

part of 'admin_create_bloc.dart';

sealed class AdminCreateState extends Equatable {
  const AdminCreateState();

  @override
  List<Object> get props => [];
}

final class AdminCreateInitial extends AdminCreateState {}

abstract class AdminCreateActionState extends AdminCreateState {}

class AdminCreate_ChangeState extends AdminCreateActionState {}

class AdminCreate_LoadingState extends AdminCreateActionState {
  final bool isLoading;

  AdminCreate_LoadingState({required this.isLoading});
}

class AdminCreateSuccessState extends AdminCreateState {}

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

class SelectedStationIdState extends AdminCreateState {
  int? newValue;
  SelectedStationIdState({
    this.newValue,
  });
}
