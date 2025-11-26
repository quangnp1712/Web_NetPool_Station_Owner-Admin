// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'admin_list_bloc.dart';

sealed class AdminListEvent {
  const AdminListEvent();
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

class GetStationIdEvent extends AdminListEvent {}

class SelectedStationEvent extends AdminListEvent {
  String? newValue;
  SelectedStationEvent({
    this.newValue,
  });
}

class SelectedStatusEvent extends AdminListEvent {
  String? newValue;
  SelectedStatusEvent({
    this.newValue,
  });
}

class ResetPressedEvent extends AdminListEvent {}

class ShowCreateAdminEvent extends AdminListEvent {}

class ShowDetailAdminEvent extends AdminListEvent {
  String? accountId;
  ShowDetailAdminEvent({
    this.accountId,
  });
}
