// ignore_for_file: constant_identifier_names

part of 'station_resource_bloc.dart';

// status
enum ResourceStatus { initial, loading, success, failure }

enum ResourceBlocState { Initial, ResourceLoadDataState }

class StationResourceState extends Equatable {
  final ResourceBlocState blocState;
  final ResourceStatus status;
  final String message;

  // Filter Data
  final List<StationSpaceModel> spaceOptions;
  final List<AreaModel> areaOptions; // Areas thuộc Space đã chọn

  // Current Selections
  final StationSpaceModel? selectedSpace;
  final AreaModel? selectedArea;
  final String? selectedStatus;
  final String searchTerm;

  // Resource Data
  final List<StationResourceModel> resourceList;

  // Pagination
  final MetaModel meta;

  StationResourceState({
    this.blocState = ResourceBlocState.Initial,
    this.status = ResourceStatus.initial,
    this.message = '',
    this.spaceOptions = const [],
    this.areaOptions = const [],
    this.selectedSpace,
    this.selectedArea,
    this.selectedStatus,
    this.searchTerm = '',
    this.resourceList = const [],
    MetaModel? meta,
  }) : meta = meta ?? MetaModel(current: 1, pageSize: 12, total: 0);

  StationResourceState copyWith({
    ResourceBlocState? blocState,
    ResourceStatus? status,
    String? message,
    List<StationSpaceModel>? spaceOptions,
    List<AreaModel>? areaOptions,
    StationSpaceModel? selectedSpace,
    AreaModel? selectedArea,
    String? selectedStatus,
    String? searchTerm,
    List<StationResourceModel>? resourceList,
    MetaModel? meta,
    bool forceNullArea = false,
    bool forceNullStatus = false,
  }) {
    return StationResourceState(
      blocState: blocState ?? ResourceBlocState.Initial,
      status: status ?? ResourceStatus.initial,
      message: message ?? this.message,
      spaceOptions: spaceOptions ?? this.spaceOptions,
      areaOptions: areaOptions ?? this.areaOptions,
      selectedSpace: selectedSpace ?? this.selectedSpace,
      selectedArea: forceNullArea ? null : (selectedArea ?? this.selectedArea),
      selectedStatus:
          forceNullStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchTerm: searchTerm ?? this.searchTerm,
      resourceList: resourceList ?? this.resourceList,
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        spaceOptions,
        areaOptions,
        selectedSpace,
        selectedArea,
        selectedStatus,
        searchTerm,
        resourceList,
        meta
      ];
}
