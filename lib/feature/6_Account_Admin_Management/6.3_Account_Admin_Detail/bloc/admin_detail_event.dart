// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_constructors_in_immutables

part of 'admin_detail_bloc.dart';

sealed class AdminDetailEvent extends Equatable {
  const AdminDetailEvent();

  @override
  List<Object> get props => [];
}

class InitAdminDetailEvent extends AdminDetailEvent {
  final String accountId;
  InitAdminDetailEvent({required this.accountId});
}

class ToggleEditModeEvent extends AdminDetailEvent {
  final bool enableEdit;
  ToggleEditModeEvent(this.enableEdit);
}

class PickAvatarEvent extends AdminDetailEvent {}

class GenerateCaptchaEvent extends AdminDetailEvent {}

class HandleVerifyCaptchaEvent extends AdminDetailEvent {
  final String input;
  HandleVerifyCaptchaEvent(this.input);
}

class SubmitUpdateAdminEvent extends AdminDetailEvent {
  final String? username;
  final String? email;
  final String? password;
  final String? phone;
  final String? identification;

  SubmitUpdateAdminEvent({
    this.username,
    this.email,
    this.password,
    this.phone,
    this.identification,
  });
}

class SelectedStationEvent extends AdminDetailEvent {
  final String? stationId;
  SelectedStationEvent(this.stationId);
}

class SelectedStatusEvent extends AdminDetailEvent {
  final String? status;
  SelectedStatusEvent(this.status);
}

class SubmitChangeStatusEvent extends AdminDetailEvent {
  String? status;
  SubmitChangeStatusEvent({
    this.status,
  });
}
