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
  StationListSuccessState(
      {required this.stationList,
      required this.statusNames,
      required this.meta});
}

class StationListEmptyState extends StationListState {}

class ShowSnackBarActionState extends StationListActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}
