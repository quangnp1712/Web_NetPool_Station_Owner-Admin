// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: camel_case_types

part of 'login_bloc.dart';

sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  String? email;
  LoginInitial({this.email});
}

abstract class LoginActionState extends LoginState {}

class ShowRegisterState extends LoginActionState {}

class Login_ChangeState extends LoginActionState {}

class Login_LoadingState extends LoginState {
  final bool isLoading;

  Login_LoadingState({required this.isLoading});
}

class LoginSuccessState extends LoginActionState {
  AuthenticationModel authenticationModel;
  LoginSuccessState({
    required this.authenticationModel,
  });
}

class ShowSnackBarActionState extends LoginActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}
