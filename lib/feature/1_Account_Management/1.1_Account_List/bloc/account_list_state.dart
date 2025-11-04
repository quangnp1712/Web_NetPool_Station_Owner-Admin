// ignore_for_file: public_member_api_docs, sort_constructors_first
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

class AccountListSuccessState extends AccountListState {
  List<AccountListModel> accountList;
  List<String> statusNames;
  AccountListSuccessState({
    required this.accountList,
    required this.statusNames,
  });
}

class AccountListEmptyState extends AccountListState {}

class ShowSnackBarActionState extends AccountListActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}
