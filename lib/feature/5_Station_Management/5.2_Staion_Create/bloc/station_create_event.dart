// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'station_create_bloc.dart';

sealed class StationCreateEvent extends Equatable {
  const StationCreateEvent();

  @override
  List<Object> get props => [];
}

class StationCreateInitialEvent extends StationCreateEvent {}

class SubmitStationCreateEvent extends StationCreateEvent {
  final String? avatar;
  final String stationName;
  final String address;
  final String province;
  final String commune;
  final String district;
  final String hotline;
  final List<String>? media;
  SubmitStationCreateEvent({
    this.avatar,
    required this.stationName,
    required this.address,
    required this.province,
    required this.commune,
    required this.district,
    required this.hotline,
    this.media,
  });
}

class GenerateCaptchaEvent extends StationCreateEvent {}

class HandleVerifyCaptchaEvent extends StationCreateEvent {
  String captcha;
  HandleVerifyCaptchaEvent({
    required this.captcha,
  });
}

class ResetFormEvent extends StationCreateEvent {}

class SelectedStationIdEvent extends StationCreateEvent {
  int? newValue;
  SelectedStationIdEvent({
    this.newValue,
  });
}

class PickImagesEvent extends StationCreateEvent {
  bool isPickingImage;
  PickImagesEvent({
    required this.isPickingImage,
  });
}

class RemoveImageEvent extends StationCreateEvent {
  final int imageIndex;
  List<String> base64Images;
  RemoveImageEvent({
    required this.imageIndex,
    required this.base64Images,
  });
}

class LoadProvincesEvent extends StationCreateEvent {}

class LoadDistrictsEvent extends StationCreateEvent {
  int provinceCode;
  LoadDistrictsEvent({
    required this.provinceCode,
  });
}

class LoadCommunesEvent extends StationCreateEvent {
  int districtCode;
  LoadCommunesEvent({
    required this.districtCode,
  });
}

class SelectedProvinceEvent extends StationCreateEvent {
  ProvinceModel newValue;
  SelectedProvinceEvent({
    required this.newValue,
  });
}

class SelectedDistrictEvent extends StationCreateEvent {
  DistrictModel newValue;
  SelectedDistrictEvent({
    required this.newValue,
  });
}

class SelectedCommuneEvent extends StationCreateEvent {
  CommuneModel newValue;
  SelectedCommuneEvent({
    required this.newValue,
  });
}

class UpdateFullAddressEvent extends StationCreateEvent {
  String? address;
  CommuneModel? commune;
  DistrictModel? district;
  ProvinceModel? province;
  UpdateFullAddressEvent({
    this.address,
    this.commune,
    this.district,
    this.province,
  });
}
