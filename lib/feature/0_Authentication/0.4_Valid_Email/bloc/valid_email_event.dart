part of 'valid_email_bloc.dart';

sealed class ValidEmailEvent {
  const ValidEmailEvent();
}

class ValidEmailInitialEvent extends ValidEmailEvent {}

class SubmitValidEmailEvent extends ValidEmailEvent {
  final String verificationCode;
  SubmitValidEmailEvent({
    required this.verificationCode,
  });
}

class SendValidCodeEvent extends ValidEmailEvent {
  final String email;
  SendValidCodeEvent({
    required this.email,
  });
}

class ShowVerifyEmailEvent extends ValidEmailEvent {
  final String email;
  ShowVerifyEmailEvent({
    required this.email,
  });
}
