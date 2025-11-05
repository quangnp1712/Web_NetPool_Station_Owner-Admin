// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'admin_create_bloc.dart';

sealed class AdminCreateEvent extends Equatable {
  const AdminCreateEvent();

  @override
  List<Object> get props => [];
}

class AdminCreateInitialEvent extends AdminCreateEvent {}

class SubmitAdminCreateEvent extends AdminCreateEvent {
  final String email;
  final String password;
  final String identification;
  final String phone;
  final String username;

  SubmitAdminCreateEvent({
    required this.email,
    required this.password,
    required this.identification,
    required this.phone,
    required this.username,
  });
}

class GenerateCaptchaEvent extends AdminCreateEvent {}

class HandleVerifyCaptchaEvent extends AdminCreateEvent {
  String captcha;
  HandleVerifyCaptchaEvent({
    required this.captcha,
  });
}

class ResetFormEvent extends AdminCreateEvent {}

class SelectedStationIdEvent extends AdminCreateEvent {
  int? newValue;
  SelectedStationIdEvent({
    this.newValue,
  });
}

class ShowLoginEvent extends AdminCreateEvent {}
