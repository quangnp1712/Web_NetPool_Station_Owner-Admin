// ignore_for_file: constant_identifier_names

part of 'area_list_bloc.dart';

const _sentinel = Object();

// status
enum AreaListStatus {
  initial,
  loading,
  success,
  failure,
}

// blocState
enum AreaListBlocState {
  Initial,
  AreaListSuccess,
  AreaListEmpty,
  SelectedSpace,
  SelectedStatus,
  AppliedSearch,
  ResetFilters,
}

class AreaListState extends Equatable {
  // --- General Data ---
  final String message;
  final int currentStationId;

  // --- General Status ---
  final AreaListStatus status;
  final AreaListBlocState blocState;

  // --- Data Lists ---
  final List<AreaModel> areaList;
  final List<StationSpaceModel> allStationSpaces;
  final List<String> statusOptions;

  // --- Filter Selections & Inputs ---
  final StationSpaceModel? selectedSpace;
  final String? selectedStatus;
  final String searchTerm;

  // --- Pagination & Meta ---
  MetaModel? meta;

  AreaListState({
    this.message = "",
    this.currentStationId = 0,
    this.status = AreaListStatus.initial,
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
    AreaListBlocState? blocState,
    List<AreaModel>? areaList,
    List<StationSpaceModel>? allStationSpaces,
    List<String>? statusOptions,
    StationSpaceModel? selectedSpace,
    String? selectedStatus,
    String? searchTerm,
    MetaModel? meta,
    bool forceNullSpace = false, // Helper để set null cho selectedSpace
    bool forceNullStatus = false,
  }) {
    return AreaListState(
      message: message ?? this.message,
      currentStationId: currentStationId ?? this.currentStationId,
      status:
          status ?? AreaListStatus.initial, // Giữ status cũ nếu không truyền
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
