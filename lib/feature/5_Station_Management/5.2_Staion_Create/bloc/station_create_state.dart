// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
part of 'station_create_bloc.dart';

enum StationCreateStatus {
  initial,
  loading,
  success,
  failure,
}

enum StationCreateBlocState {
  Initial,
  StationCreateSuccessState,
  StationCreateFailState,
  ResetFormState,
  RemoveImageState,
  SelectedProvinceState,
  SelectedDistrictState,
  SelectedCommuneState,
  LoadDistrictsState,
  LoadCommunesState
}

class StationCreateState extends Equatable {
  // --- Chia State kiểu cũ ---
  final StationCreateBlocState blocState;

  // --- General Loading & Status ---
  final StationCreateStatus stationCreateStatus;
  final String message; // Dùng để chứa lỗi hoặc thông báo thành công

  // --- Data Lists ---
  final List<ProvinceModel> provincesList;
  final List<DistrictModel> districtList;
  final List<CommuneModel> communeList;
  final List<String> base64Images;

  // --- Form Selections & Inputs ---
  final int? selectedStationId;
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

  const StationCreateState({
    this.blocState = StationCreateBlocState.Initial,
    this.stationCreateStatus = StationCreateStatus.initial,
    this.message = '',
    this.provincesList = const [],
    this.districtList = const [],
    this.communeList = const [],
    this.base64Images = const [],
    this.selectedStationId,
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
  });

  // Hàm copyWith quan trọng để cập nhật state
  StationCreateState copyWith({
    StationCreateBlocState? blocState,
    StationCreateStatus? stationCreateStatus,
    String? message,
    List<ProvinceModel>? provincesList,
    List<DistrictModel>? districtList,
    List<CommuneModel>? communeList,
    List<String>? base64Images,
    int? selectedStationId,
    ProvinceModel? selectedProvince,
    DistrictModel? selectedDistrict,
    CommuneModel? selectedCommune,
    String? fullAddressController,
    bool? isLoadingProvinces,
    bool? isLoadingDistricts,
    bool? isLoadingCommunes,
    bool? isPickingImage,
    String? captchaText,
    bool? isVerifyingCaptcha,
    bool? isCaptchaVerified,
    bool? isClearCaptchaController,
  }) {
    return StationCreateState(
      blocState: blocState ?? StationCreateBlocState.Initial,
      stationCreateStatus: stationCreateStatus ?? StationCreateStatus.initial,
      message: message ?? this.message,
      provincesList: provincesList ?? this.provincesList,
      districtList: districtList ?? this.districtList,
      communeList: communeList ?? this.communeList,
      base64Images: base64Images ?? this.base64Images,
      selectedStationId: selectedStationId ?? this.selectedStationId,
      selectedProvince: selectedProvince ?? this.selectedProvince,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedCommune: selectedCommune ?? this.selectedCommune,
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
    );
  }

  @override
  List<Object?> get props => [
        blocState,
        stationCreateStatus,
        message,
        provincesList,
        districtList,
        communeList,
        base64Images,
        selectedStationId,
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
      ];
}
