// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_constructors_in_immutables, camel_case_types
part of 'account_list_bloc.dart';

sealed class AccountListState extends Equatable {
  const AccountListState();

  @override
  List<Object> get props => [];
}

final class AccountListInitial extends AccountListState {}

abstract class AccountListActionState extends AccountListState {}

class AccountList_ChangeState extends AccountListActionState {}

class AccountList_LoadingState extends AccountListState {
  final bool isLoading;

  AccountList_LoadingState({required this.isLoading});
}

class AccountListSuccessState extends AccountListState {
  List<AccountListModel> accountList;
  List<String> statusNames;
  ACLMetaModel meta;
  AccountListSuccessState(
      {required this.accountList,
      required this.statusNames,
      required this.meta});
}

class AccountListEmptyState extends AccountListState {}

class ShowSnackBarActionState extends AccountListActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}
