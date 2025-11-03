// ignore_for_file: camel_case_types

part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {
  String? email;
  LoginInitial({this.email});
}

abstract class LoginActionState extends LoginState {}

class ShowRegisterState extends LoginActionState {}

class Login_ChangeState extends LoginActionState {}

class Login_LoadingState extends LoginActionState {
  final bool isLoading;

  Login_LoadingState({required this.isLoading});
}

class LoginSuccessState extends LoginActionState {}
