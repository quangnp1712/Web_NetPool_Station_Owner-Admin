// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'register_bloc.dart';

sealed class RegisterEvent {
  const RegisterEvent();
}

class RegisterInitialEvent extends RegisterEvent {}

class SubmitRegisterEvent extends RegisterEvent {
  final String email;
  final String password;
  final String identification;
  final String phone;
  final String username;

  SubmitRegisterEvent({
    required this.email,
    required this.password,
    required this.identification,
    required this.phone,
    required this.username,
  });
}

class ShowLoginEvent extends RegisterEvent {}
