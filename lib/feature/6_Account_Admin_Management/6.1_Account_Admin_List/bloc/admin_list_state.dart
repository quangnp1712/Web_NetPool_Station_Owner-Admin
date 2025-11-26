// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names

part of 'admin_list_bloc.dart';

const _sentinel = Object();

// status
enum AdminListStatus {
  initial,
  loading,
  success,
  failure,
}

// blocState
enum AdminListBlocState {
  Initial,
  AdminListSuccessState,
  AdminListEmptyState,
  SelectedStatusState,
  SelectedStationState,
  ResetPressedState,
  ShowCreateAdminState,
  ShowDetailAdminState,
}

class AdminListState extends Equatable {
// --- Chia State kiểu cũ ---
  final AdminListBlocState blocState;

  // --- General Loading & Status ---
  final AdminListStatus status;
  final String message; // Dùng để chứa lỗi hoặc thông báo thành công

  // --- Data ---
  final MetaModel? meta;
  final RoleModel? roleAdmin;

  // --- Data Lists ---
  final List<AdminListModel> adminList;
  final List<AdminListModel> masterAdminList;
  final List<String> statusNames;
  final Map<String, String> masterStatusNameMap;
  final List<AuthStationsModel> stationList;

  // --- Form Selections & Inputs ---
  final String? selectedStatus;
  final String? selectedStationId;

  AdminListState({
    this.blocState = AdminListBlocState.Initial,
    this.status = AdminListStatus.initial,
    this.message = '',
    this.meta,
    this.roleAdmin,
    this.stationList = const [],
    this.adminList = const [],
    this.masterAdminList = const [],
    this.statusNames = const [],
    this.masterStatusNameMap = const {},
    this.selectedStatus,
    this.selectedStationId,
  });

  AdminListState copyWith({
    AdminListBlocState? blocState,
    AdminListStatus? status,
    String? message,
    MetaModel? meta,
    RoleModel? roleAdmin,
    List<String>? statusNames,
    List<AuthStationsModel>? stationList,
    List<AdminListModel>? adminList,
    List<AdminListModel>? masterAdminList,
    Map<String, String>? masterStatusNameMap,
    String? selectedStatus,
    String? selectedStationId,
  }) {
    return AdminListState(
      blocState: blocState ?? AdminListBlocState.Initial,
      status: status ?? AdminListStatus.initial,
      message: message ?? this.message,
      meta: meta ?? this.meta,
      roleAdmin: roleAdmin ?? this.roleAdmin,
      statusNames: statusNames ?? this.statusNames,
      stationList: stationList ?? this.stationList,
      adminList: adminList ?? this.adminList,
      masterAdminList: masterAdminList ?? this.masterAdminList,
      masterStatusNameMap: masterStatusNameMap ?? this.masterStatusNameMap,
      selectedStatus:
          selectedStatus == _sentinel ? this.selectedStatus : selectedStatus,
      selectedStationId: selectedStationId == _sentinel
          ? this.selectedStationId
          : selectedStationId,
    );
  }

  @override
  List<Object?> get props {
    return [
      blocState,
      status,
      message,
      meta,
      roleAdmin,
      statusNames,
      stationList,
      adminList,
      masterAdminList,
      selectedStatus,
      selectedStationId,
      masterStatusNameMap,
    ];
  }
}
