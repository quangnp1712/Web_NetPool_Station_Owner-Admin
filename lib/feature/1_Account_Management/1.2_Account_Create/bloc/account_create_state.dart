part of 'account_create_bloc.dart';

sealed class AccountCreateState extends Equatable {
  const AccountCreateState();
  
  @override
  List<Object> get props => [];
}

final class AccountCreateInitial extends AccountCreateState {}
