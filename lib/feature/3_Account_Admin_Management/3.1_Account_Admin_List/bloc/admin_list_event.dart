part of 'admin_list_bloc.dart';

sealed class AdminListEvent extends Equatable {
  const AdminListEvent();

  @override
  List<Object> get props => [];
}

class AdminListInitialEvent extends AdminListEvent {}

class AdminListLoadEvent extends AdminListEvent {
  String? search;
  String? statusCodes;
  String? roleIds;
  String? sorter;
  String? current;
  String? stationId;
  AdminListLoadEvent({
    this.search,
    this.statusCodes,
    this.roleIds,
    this.sorter,
    this.current,
    this.stationId,
  });
}

class RoleEvent extends AdminListEvent {}
