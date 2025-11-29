// ignore_for_file: unnecessary_this

part of 'space_bloc.dart';

// status
enum SpaceStatus { initial, loading, success, failure }

// blocState
enum SpaceBlocState {
  initial,
  loadMasterSuccess,
  createSuccess,
  updateSuccess,
  deleteSuccess
}

class SpaceState extends Equatable {
  final SpaceStatus status;
  final SpaceBlocState blocState;
  final String message;
  final String currentStationId;
  final bool isHeaderExpanded;

  // Danh sách Space của Station (Đã thêm)
  final List<StationSpaceModel> mySpaces;

  // Danh sách Master Space (Của nền tảng - dùng để chọn khi tạo)
  final List<PlatformSpaceModel> platformSpaces;

  final StationDetailModel? station;

  // Loading riêng cho dialog/action
  final bool isActionLoading;

  const SpaceState({
    this.status = SpaceStatus.initial,
    this.blocState = SpaceBlocState.initial,
    this.station,
    this.message = '',
    this.currentStationId = '',
    this.mySpaces = const [],
    this.platformSpaces = const [],
    this.isActionLoading = false,
    this.isHeaderExpanded = true,
  });

  SpaceState copyWith({
    SpaceStatus? status,
    SpaceBlocState? blocState,
    String? message,
    String? currentStationId,
    List<StationSpaceModel>? mySpaces,
    List<PlatformSpaceModel>? platformSpaces,
    bool? isActionLoading,
    bool? isHeaderExpanded,
    StationDetailModel? station,
  }) {
    return SpaceState(
      status: status ?? SpaceStatus.initial,
      blocState: blocState ?? SpaceBlocState.initial,
      message: message ?? this.message,
      currentStationId: currentStationId ?? this.currentStationId,
      mySpaces: mySpaces ?? this.mySpaces,
      platformSpaces: platformSpaces ?? this.platformSpaces,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      station: station ?? this.station,
      isHeaderExpanded: isHeaderExpanded ?? this.isHeaderExpanded,
    );
  }

  @override
  List<Object?> get props => [
        status,
        blocState,
        message,
        currentStationId,
        mySpaces,
        platformSpaces,
        isActionLoading,
        station,
        isHeaderExpanded,
      ];
}
