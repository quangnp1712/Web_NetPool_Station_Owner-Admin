part of 'area_list_bloc.dart';

sealed class AreaListEvent extends Equatable {
  const AreaListEvent();
  @override
  List<Object> get props => [];
}

class AreaListInitialEvent extends AreaListEvent {
  final int stationId;
  const AreaListInitialEvent(this.stationId);
}

class AreaListLoadDataEvent extends AreaListEvent {
  final String? search;
  final int? current;
  final String? spaceId;
  final String? statusCodes;
  const AreaListLoadDataEvent(
      {this.search, this.current, this.spaceId, this.statusCodes});
}

class AreaListSelectSpaceEvent extends AreaListEvent {
  final StationSpaceModel? newValue;
  const AreaListSelectSpaceEvent({this.newValue});
}

class AreaListSelectStatusEvent extends AreaListEvent {
  final String? newValue;
  const AreaListSelectStatusEvent({this.newValue});
}

class AreaListApplySearchEvent extends AreaListEvent {
  final String searchTerm;
  const AreaListApplySearchEvent({required this.searchTerm});
}

class AreaListChangePageEvent extends AreaListEvent {
  final int newPage;
  const AreaListChangePageEvent({required this.newPage});
}

class AreaListChangeRowsPerPageEvent extends AreaListEvent {
  final int newRowsPerPage;
  const AreaListChangeRowsPerPageEvent({required this.newRowsPerPage});
}

class AreaListResetEvent extends AreaListEvent {}

class AreaListCreateEvent extends AreaListEvent {
  final StationSpaceModel stationSpace;
  final String areaCode;
  final String areaName;
  final int price;
  const AreaListCreateEvent(
      {required this.stationSpace,
      required this.areaCode,
      required this.areaName,
      required this.price});
}

// New Events for CRUD
class UpdateAreaEvent extends AreaListEvent {
  final AreaModel updatedArea;
  const UpdateAreaEvent(this.updatedArea);
}

class ToggleStatusEvent extends AreaListEvent {
  final AreaModel area;
  const ToggleStatusEvent(this.area);
}
