part of 'area_list_bloc.dart';

sealed class AreaListEvent extends Equatable {
  const AreaListEvent();

  @override
  List<Object> get props => [];
}

class AreaListInitialEvent extends AreaListEvent {
  final int stationId;

  AreaListInitialEvent(this.stationId);
}

class AreaListLoadDataEvent extends AreaListEvent {
  String? search;
  int? current;
  String? spaceId;
  String? statusCodes;

  AreaListLoadDataEvent({
    this.search,
    this.current,
    this.spaceId,
    this.statusCodes,
  });
}

class AreaListSelectSpaceEvent extends AreaListEvent {
  final StationSpaceModel? newValue;
  AreaListSelectSpaceEvent({
    this.newValue,
  });
}

class AreaListSelectStatusEvent extends AreaListEvent {
  final String? newValue;
  AreaListSelectStatusEvent({
    this.newValue,
  });
}

class AreaListApplySearchEvent extends AreaListEvent {
  final String searchTerm;
  AreaListApplySearchEvent({
    required this.searchTerm,
  });
}

class AreaListChangePageEvent extends AreaListEvent {
  final int newPage;
  AreaListChangePageEvent({
    required this.newPage,
  });
}

class AreaListChangeRowsPerPageEvent extends AreaListEvent {
  final int newRowsPerPage;
  AreaListChangeRowsPerPageEvent({
    required this.newRowsPerPage,
  });
}

class AreaListResetEvent extends AreaListEvent {}
