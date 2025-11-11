// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'station_list_bloc.dart';

sealed class StationListEvent extends Equatable {
  const StationListEvent();

  @override
  List<Object> get props => [];
}

class StationListInitialEvent extends StationListEvent {}

class StationListLoadEvent extends StationListEvent {
  String? search;
  String? province;
  String? commune;
  String? district;
  String? statusName;
  int current;
  StationListLoadEvent({
    this.search,
    this.province,
    this.commune,
    this.district,
    this.statusName,
    required this.current,
  });
}

class SelectedStatusEvent extends StationListEvent {
  String? newValue;
  SelectedStatusEvent({
    this.newValue,
  });
}

class SelectedDistrictEvent extends StationListEvent {
  String? newValue;
  SelectedDistrictEvent({
    this.newValue,
  });
}

class SelectedProvinceEvent extends StationListEvent {
  String? newValue;
  SelectedProvinceEvent({
    this.newValue,
  });
}

class ShowCreateStationPageEvent extends StationListEvent {}

class RoleEvent extends StationListEvent {}
