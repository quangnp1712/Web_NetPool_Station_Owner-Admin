// ignore_for_file: constant_identifier_names

part of 'station_detail_bloc.dart';

// Dùng để phân biệt giữa "không truyền" (giữ cũ) và "truyền null" (xóa).
const _sentinel = Object();

// stationDetailStatus
enum StationDetailStatus {
  initial,
  loadingHeader,
  loadingContent,
  loadingDialog,
  success,
  failure,
}

// blocState
enum StationDetailBlocState {
  Initial,
  SelectedProvinceState,
  SelectedDistrictState,
  SelectedCommuneState,
  StationUpdateSuccessState,
  StationUpdateFailState,
  ResetFormState,
  PickImagesState,
  RemoveImageState,
  LoadDistrictsState,
  LoadCommunesState,
  ShowStationListPageState,
  ToggleEditModeState,
  VerifyCaptchaSuccessState,
}

//  xác định chế độ màn hình
enum ScreenMode { view, edit }

class StationDetailState extends Equatable {
  // --- Chia State kiểu cũ ---
  final StationDetailBlocState blocState;

  // --- General Loading & Status ---
  final StationDetailStatus stationDetailStatus;
  final String message; // Dùng để chứa lỗi hoặc thông báo thành công

  // --- chế độ xem / sửa ---
  final ScreenMode screenMode;

  // Getter tiện ích
  bool get isReadOnly => screenMode == ScreenMode.view;
  bool get isEditMode => screenMode == ScreenMode.edit;

  // --- Data ---
  final StationDetailModel? station;
  final String currentStationId;
  final String stationName;
  final String address;
  final String phone;
  final String statusName;
  final String statusCode;
  final String? placeId;

  // --- Data Lists ---
  final List<ProvinceModel> provincesList;
  final List<DistrictModel> districtList;
  final List<CommuneModel> communeList;
  final List<String> base64Images;

  // --- Form Selections & Inputs ---
  final ProvinceModel? selectedProvince;
  final DistrictModel? selectedDistrict;
  final CommuneModel? selectedCommune;
  final String fullAddressController;

  // --- Specific Loadings (Loading cục bộ cho từng dropdown) ---
  final bool isLoadingProvinces;
  final bool isLoadingDistricts;
  final bool isLoadingCommunes;
  final bool isPickingImage;

  // --- Captcha State ---
  final String captchaText;
  final bool isVerifyingCaptcha;
  final bool isCaptchaVerified;
  final bool isClearCaptchaController;

  // [THÊM] Loading và List gợi ý địa chỉ
  final bool isLoadingAddressSuggestions;
  final List<AutocompleteModel> addressSuggestions;

  final String activeTab;
  final List<StationSpaceModel> spaces;
  final List<AreaModel> areas;
  final List<StationResourceModel> resources;

  const StationDetailState({
    this.blocState = StationDetailBlocState.Initial,
    this.stationDetailStatus = StationDetailStatus.initial,
    this.station,
    this.message = '',
    this.provincesList = const [],
    this.districtList = const [],
    this.communeList = const [],
    this.base64Images = const [],
    this.selectedProvince,
    this.selectedDistrict,
    this.selectedCommune,
    this.fullAddressController = '',
    this.isLoadingProvinces = false,
    this.isLoadingDistricts = false,
    this.isLoadingCommunes = false,
    this.isPickingImage = false,
    this.captchaText = '',
    this.isVerifyingCaptcha = false,
    this.isCaptchaVerified = false,
    this.isClearCaptchaController = false,
    this.isLoadingAddressSuggestions = false,
    this.addressSuggestions = const [],
    this.stationName = '',
    this.address = '',
    this.phone = '',
    this.statusName = '',
    this.statusCode = '',
    this.placeId = '',
    this.screenMode = ScreenMode.view,
    this.currentStationId = '',
    this.activeTab = 'overview',
    this.spaces = const [],
    this.areas = const [],
    this.resources = const [],
  });

  bool get isHeaderLoading =>
      stationDetailStatus == StationDetailStatus.loadingHeader;
  bool get isContentLoading =>
      stationDetailStatus == StationDetailStatus.loadingContent;

  // Hàm copyWith quan trọng để cập nhật state
  StationDetailState copyWith({
    StationDetailBlocState? blocState,
    StationDetailStatus? stationDetailStatus,
    String? message,
    String? placeId,
    List<ProvinceModel>? provincesList,
    List<DistrictModel>? districtList,
    List<CommuneModel>? communeList,
    List<String>? base64Images,
    Object? selectedProvince = _sentinel,
    Object? selectedDistrict = _sentinel,
    Object? selectedCommune = _sentinel,
    String? fullAddressController,
    bool? isLoadingProvinces,
    bool? isLoadingDistricts,
    bool? isLoadingCommunes,
    bool? isPickingImage,
    String? captchaText,
    bool? isVerifyingCaptcha,
    bool? isCaptchaVerified,
    bool? isClearCaptchaController,
    bool? isLoadingAddressSuggestions,
    List<AutocompleteModel>? addressSuggestions,
    String? stationName,
    String? address,
    String? phone,
    String? statusName,
    String? statusCode,
    ScreenMode? screenMode,
    String? currentStationId,
    StationDetailModel? station,
    String? activeTab,
    List<StationSpaceModel>? spaces,
    List<AreaModel>? areas,
    List<StationResourceModel>? resources,
  }) {
    return StationDetailState(
      blocState: blocState ?? StationDetailBlocState.Initial,
      stationDetailStatus: stationDetailStatus ?? StationDetailStatus.initial,
      message: message ?? this.message,
      placeId: placeId ?? this.placeId,
      provincesList: provincesList ?? this.provincesList,
      districtList: districtList ?? this.districtList,
      communeList: communeList ?? this.communeList,
      base64Images: base64Images ?? this.base64Images,
      selectedProvince: selectedProvince == _sentinel
          ? this.selectedProvince
          : selectedProvince as ProvinceModel?,
      selectedDistrict: selectedDistrict == _sentinel
          ? this.selectedDistrict
          : selectedDistrict as DistrictModel?,
      selectedCommune: selectedCommune == _sentinel
          ? this.selectedCommune
          : selectedCommune as CommuneModel?,
      fullAddressController:
          fullAddressController ?? this.fullAddressController,
      isLoadingProvinces: isLoadingProvinces ?? this.isLoadingProvinces,
      isLoadingDistricts: isLoadingDistricts ?? this.isLoadingDistricts,
      isLoadingCommunes: isLoadingCommunes ?? this.isLoadingCommunes,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      captchaText: captchaText ?? this.captchaText,
      isVerifyingCaptcha: isVerifyingCaptcha ?? this.isVerifyingCaptcha,
      isCaptchaVerified: isCaptchaVerified ?? this.isCaptchaVerified,
      isClearCaptchaController:
          isClearCaptchaController ?? this.isClearCaptchaController,
      isLoadingAddressSuggestions:
          isLoadingAddressSuggestions ?? this.isLoadingAddressSuggestions,
      addressSuggestions: addressSuggestions ?? this.addressSuggestions,
      stationName: stationName ?? this.stationName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      statusName: statusName ?? this.statusName,
      statusCode: statusCode ?? this.statusCode,
      screenMode: screenMode ?? this.screenMode,
      currentStationId: currentStationId ?? this.currentStationId,
      station: station ?? this.station,
      activeTab: activeTab ?? this.activeTab,
      spaces: spaces ?? this.spaces,
      areas: areas ?? this.areas,
      resources: resources ?? this.resources,
    );
  }

  @override
  List<Object?> get props => [
        blocState,
        stationDetailStatus,
        message,
        provincesList,
        districtList,
        communeList,
        base64Images,
        selectedProvince,
        selectedDistrict,
        selectedCommune,
        fullAddressController,
        isLoadingProvinces,
        isLoadingDistricts,
        isLoadingCommunes,
        isPickingImage,
        captchaText,
        isVerifyingCaptcha,
        isCaptchaVerified,
        isClearCaptchaController,
        isLoadingAddressSuggestions,
        addressSuggestions,
        screenMode,
        currentStationId,
        station,
        statusCode,
        statusName,
        placeId,
        activeTab,
        spaces,
        areas,
        resources,
      ];
}
