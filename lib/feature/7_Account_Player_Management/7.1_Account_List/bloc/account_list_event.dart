// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
part of 'account_list_bloc.dart';

sealed class AccountListEvent {
  const AccountListEvent();
}

class AccountListInitialEvent extends AccountListEvent {}

class AccountListLoadEvent extends AccountListEvent {
  String? search;
  String? statusCodes;
  String? roleIds;
  String? sorter;
  String? current;
  String? stationId;
  AccountListLoadEvent({
    this.search,
    this.statusCodes,
    this.roleIds,
    this.sorter,
    this.current,
    this.stationId,
  });
}

class RoleEvent extends AccountListEvent {}
