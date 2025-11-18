// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'station_create_bloc.dart';

sealed class StationCreateState {
  final bool isLoading;
  const StationCreateState({this.isLoading = false});
}

final class StationCreateInitial extends StationCreateState {
  const StationCreateInitial({super.isLoading});
}

abstract class StationCreateActionState extends StationCreateState {
  StationCreateActionState({super.isLoading});
}

class StationCreateInitialState extends StationCreateState {
  bool isLoadingProvinces;
  List<ProvinceModel>? provincesList;
  String captchaText;
  bool isCaptchaVerified;
  bool isVerifyingCaptcha;
  bool isClearCaptchaController;
  StationCreateInitialState({
    required this.isLoadingProvinces,
    this.provincesList,
    required this.captchaText,
    required this.isCaptchaVerified,
    required this.isVerifyingCaptcha,
    required this.isClearCaptchaController,
  }) : super(isLoading: false);
}

class StationCreate_ChangeState extends StationCreateActionState {}

class StationCreate_LoadingState extends StationCreateState {
  final bool isLoading;

  StationCreate_LoadingState({required this.isLoading});
}

class StationCreateSuccessState extends StationCreateActionState {
  StationCreateSuccessState() : super(isLoading: false);
}

class StationCreateFailState extends StationCreateState {
  StationCreateFailState() : super(isLoading: false);
}

class ShowSnackBarActionState extends StationCreateActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message})
      : super(isLoading: false);
}

class GenerateCaptchaState extends StationCreateState {
  String captchaText;
  bool isCaptchaVerified;
  bool isVerifyingCaptcha;
  bool isClearCaptchaController;
  GenerateCaptchaState({
    required this.captchaText,
    required this.isCaptchaVerified,
    required this.isVerifyingCaptcha,
    required this.isClearCaptchaController,
  }) : super(isLoading: false);
}

class HandleVerifyCaptchaState extends StationCreateState {
  String? captchaText;
  bool? isCaptchaVerified;
  bool? isVerifyingCaptcha;
  bool? isClearCaptchaController;
  HandleVerifyCaptchaState({
    this.captchaText,
    this.isCaptchaVerified,
    this.isVerifyingCaptcha,
    this.isClearCaptchaController,
  }) : super(isLoading: false);
}

class LoadingCaptchaState extends StationCreateState {
  bool isVerifyingCaptcha;

  LoadingCaptchaState({
    required this.isVerifyingCaptcha,
  }) : super(isLoading: false);
}

class ResetFormState extends StationCreateState {}

class SelectedStationIdState extends StationCreateState {
  int? newValue;
  SelectedStationIdState({
    this.newValue,
  }) : super(isLoading: false);
}

class IsPickingImageState extends StationCreateState {
  bool isPickingImage;
  IsPickingImageState({
    required this.isPickingImage,
  }) : super(isLoading: false);
}

class PickingImagesState extends StationCreateState {
  bool isPickingImage;
  List<String> base64Images;
  PickingImagesState({
    required this.isPickingImage,
    required this.base64Images,
  }) : super(isLoading: false);
}

class RemoveImageState extends StationCreateState {
  List<String> base64Images;
  RemoveImageState({
    required this.base64Images,
  }) : super(isLoading: false);
}

class SelectedProvinceState extends StationCreateState {
  ProvinceModel? newValue;
  SelectedProvinceState({this.newValue}) : super(isLoading: false);
}

class SelectedDistrictState extends StationCreateState {
  DistrictModel? newValue;
  SelectedDistrictState({this.newValue}) : super(isLoading: false);
}

class SelectedCommuneState extends StationCreateState {
  CommuneModel? newValue;
  SelectedCommuneState({this.newValue}) : super(isLoading: false);
}

class LoadProvincesState extends StationCreateState {
  bool isLoadingProvinces;
  List<ProvinceModel>? provincesList;
  LoadProvincesState({
    required this.isLoadingProvinces,
    this.provincesList,
  }) : super(isLoading: false);
}

class LoadDistrictsState extends StationCreateState {
  bool isLoadingDistricts;
  List<DistrictModel>? districtList;
  List<CommuneModel>? communeList;
  DistrictModel? selectedDistrictCode;
  CommuneModel? selectedCommuneCode;
  LoadDistrictsState({
    required this.isLoadingDistricts,
    this.districtList,
    this.communeList,
    this.selectedDistrictCode,
    this.selectedCommuneCode,
  }) : super(isLoading: false);
}

class LoadCommunesState extends StationCreateState {
  bool isLoadingCommunes;
  List<CommuneModel>? communeList;
  CommuneModel? selectedCommuneCode;
  LoadCommunesState({
    required this.isLoadingCommunes,
    this.communeList,
    this.selectedCommuneCode,
  }) : super(isLoading: false);
}

class UpdateFullAddressState extends StationCreateState {
  String fullAddressController;
  UpdateFullAddressState({
    required this.fullAddressController,
  }) : super(isLoading: false);
}
