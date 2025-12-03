// ignore_for_file: constant_identifier_names

part of 'area_list_bloc.dart';

enum AreaListStatus { initial, loading, success, failure }

enum AreaListBlocState {
  Initial,
  AreaListSuccess,
  AreaListEmpty,
  SelectedSpace,
  SelectedStatus,
  AppliedSearch,
  ResetFilters
}

enum CreateStatus { initial, loading, success, failure }

enum UpdateStatus { initial, loading, success, failure } // New Status

class AreaListState extends Equatable {
  final AreaListStatus status;
  final String message;
  final int currentStationId;

  final AreaListBlocState blocState;
  final CreateStatus createStatus;
  final UpdateStatus updateStatus;

  final List<AreaModel> areaList;
  final List<StationSpaceModel> allStationSpaces;
  final List<String> statusOptions;
  final StationSpaceModel? selectedSpace;
  final String? selectedStatus;
  final String searchTerm;
  final MetaModel meta;

  AreaListState({
    this.message = "",
    this.currentStationId = 0,
    this.status = AreaListStatus.initial,
    this.createStatus = CreateStatus.initial,
    this.updateStatus = UpdateStatus.initial, // Default
    this.blocState = AreaListBlocState.Initial,
    this.areaList = const [],
    this.allStationSpaces = const [],
    this.statusOptions = const ["ACTIVE", "INACTIVE"],
    this.selectedSpace,
    this.selectedStatus,
    this.searchTerm = "",
    MetaModel? meta,
  }) : meta = meta ?? MetaModel(current: 1, pageSize: 10, total: 0);

  AreaListState copyWith({
    String? message,
    int? currentStationId,
    AreaListStatus? status,
    CreateStatus? createStatus,
    UpdateStatus? updateStatus, // Update copyWith
    AreaListBlocState? blocState,
    List<AreaModel>? areaList,
    List<StationSpaceModel>? allStationSpaces,
    List<String>? statusOptions,
    StationSpaceModel? selectedSpace,
    String? selectedStatus,
    String? searchTerm,
    MetaModel? meta,
    bool forceNullSpace = false,
    bool forceNullStatus = false,
  }) {
    return AreaListState(
      message: message ?? this.message,
      currentStationId: currentStationId ?? this.currentStationId,
      status: status ?? this.status,
      createStatus: createStatus ?? this.createStatus,
      updateStatus: updateStatus ?? this.updateStatus, // Update copyWith
      blocState: blocState ?? AreaListBlocState.Initial,
      areaList: areaList ?? this.areaList,
      allStationSpaces: allStationSpaces ?? this.allStationSpaces,
      statusOptions: statusOptions ?? this.statusOptions,
      searchTerm: searchTerm ?? this.searchTerm,
      meta: meta ?? this.meta,
      selectedSpace:
          forceNullSpace ? null : (selectedSpace ?? this.selectedSpace),
      selectedStatus:
          forceNullStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }

  @override
  List<Object?> get props => [
        message,
        currentStationId,
        status,
        createStatus,
        updateStatus,
        blocState,
        areaList,
        allStationSpaces,
        statusOptions,
        selectedSpace,
        selectedStatus,
        searchTerm,
        meta,
      ];
}
