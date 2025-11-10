// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'station_create_bloc.dart';

sealed class StationCreateState extends Equatable {
  const StationCreateState();

  @override
  List<Object> get props => [];
}

final class StationCreateInitial extends StationCreateState {}

abstract class StationCreateActionState extends StationCreateState {}

class StationCreate_ChangeState extends StationCreateActionState {}

class StationCreate_LoadingState extends StationCreateActionState {
  final bool isLoading;

  StationCreate_LoadingState({required this.isLoading});
}

class StationCreateSuccessState extends StationCreateActionState {}

class ShowSnackBarActionState extends StationCreateActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
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
  });
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
  });
}

class LoadingCaptchaState extends StationCreateState {
  bool isVerifyingCaptcha;

  LoadingCaptchaState({
    required this.isVerifyingCaptcha,
  });
}

class ResetFormState extends StationCreateState {}

class SelectedStationIdState extends StationCreateState {
  int? newValue;
  SelectedStationIdState({
    this.newValue,
  });
}

class IsPickingImageState extends StationCreateState {
  bool isPickingImage;
  IsPickingImageState({
    required this.isPickingImage,
  });
}

class PickingImagesState extends StationCreateState {
  bool isPickingImage;
  List<String> base64Images;
  PickingImagesState({
    required this.isPickingImage,
    required this.base64Images,
  });
}

class RemoveImageState extends StationCreateState {
  List<String> base64Images;
  RemoveImageState({
    required this.base64Images,
  });
}

class SelectedProvinceState extends StationCreateState {
  ProvinceModel? newValue;
  SelectedProvinceState({this.newValue});
}

class SelectedDistrictState extends StationCreateState {
  DistrictModel? newValue;
  SelectedDistrictState({this.newValue});
}

class SelectedCommuneState extends StationCreateState {
  CommuneModel? newValue;
  SelectedCommuneState({this.newValue});
}

class LoadProvincesState extends StationCreateState {
  bool isLoadingProvinces;
  List<ProvinceModel>? provincesList;
  LoadProvincesState({
    required this.isLoadingProvinces,
    this.provincesList,
  });
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
  });
}

class LoadCommunesState extends StationCreateState {
  bool isLoadingCommunes;
  List<CommuneModel>? communeList;
  CommuneModel? selectedCommuneCode;
  LoadCommunesState({
    required this.isLoadingCommunes,
    this.communeList,
    this.selectedCommuneCode,
  });
}

class UpdateFullAddressState extends StationCreateState {
  String fullAddressController;
  UpdateFullAddressState({
    required this.fullAddressController,
  });
}
