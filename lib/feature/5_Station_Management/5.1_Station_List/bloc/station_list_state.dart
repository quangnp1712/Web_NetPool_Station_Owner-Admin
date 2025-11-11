// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'station_list_bloc.dart';

sealed class StationListState extends Equatable {
  const StationListState();

  @override
  List<Object> get props => [];
}

final class StationListInitial extends StationListState {}

abstract class StationListActionState extends StationListState {}

class StationList_ChangeState extends StationListActionState {}

class StationList_LoadingState extends StationListState {
  final bool isLoading;

  StationList_LoadingState({required this.isLoading});
}

class StationListSuccessState extends StationListState {
  List<StationListModel> stationList;
  List<String> statusNames;
  StationListMetaModel meta;

  // Danh sách đầy đủ cho Filter
  final List<StationListModel> allOwnedStations;

  StationListSuccessState({
    required this.stationList,
    required this.statusNames,
    required this.meta,
    required this.allOwnedStations,
  });
}

class StationListEmptyState extends StationListState {}

class ShowSnackBarActionState extends StationListActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}

class SelectedStatusState extends StationListState {
  String? selectedStatus;
  SelectedStatusState({
    this.selectedStatus,
  });
}

class SelectedProvinceState extends StationListState {
  String? selectedProvince;
  SelectedProvinceState({
    this.selectedProvince,
  });
}

class SelectedDistrictState extends StationListState {
  String? selectedDistrict;
  SelectedDistrictState({
    this.selectedDistrict,
  });
}

class ShowCreateStationPageState extends StationListActionState {}
