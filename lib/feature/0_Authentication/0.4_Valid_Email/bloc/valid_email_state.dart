part of 'valid_email_bloc.dart';

sealed class ValidEmailState {
  const ValidEmailState();
}

final class ValidEmailInitial extends ValidEmailState {
  String? email;
  ValidEmailInitial({this.email});
}

abstract class ValidEmailActionState extends ValidEmailState {}

class ShowRegisterState extends ValidEmailActionState {}

class ValidEmail_ChangeState extends ValidEmailActionState {}

class ValidEmail_LoadingState extends ValidEmailState {
  final bool isLoading;

  ValidEmail_LoadingState({required this.isLoading});
}

class ValidEmailSuccessState extends ValidEmailActionState {}

class ShowSnackBarActionState extends ValidEmailActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}
