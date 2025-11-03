part of 'account_list_bloc.dart';

sealed class AccountListState extends Equatable {
  const AccountListState();

  @override
  List<Object> get props => [];
}

final class AccountListInitial extends AccountListState {}

abstract class AccountListActionState extends AccountListState {}

class AccountList_ChangeState extends AccountListActionState {}

class AccountList_LoadingState extends AccountListActionState {
  final bool isLoading;

  AccountList_LoadingState({required this.isLoading});
}

class AccountListSuccessState extends AccountListState {}

class AccountListEmptyState extends AccountListState {}

class ShowSnackBarActionState extends AccountListActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}
