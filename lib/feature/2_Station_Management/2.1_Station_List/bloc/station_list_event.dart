part of 'station_list_bloc.dart';

sealed class StationListEvent extends Equatable {
  const StationListEvent();

  @override
  List<Object> get props => [];
}

class StationListInitialEvent extends StationListEvent {}

class StationListLoadEvent extends StationListEvent {
  String? search;
  String? statusCodes;
  String? roleIds;
  String? sorter;
  String? current;
  String? stationId;
  StationListLoadEvent({
    this.search,
    this.statusCodes,
    this.roleIds,
    this.sorter,
    this.current,
    this.stationId,
  });
}

class RoleEvent extends StationListEvent {}
