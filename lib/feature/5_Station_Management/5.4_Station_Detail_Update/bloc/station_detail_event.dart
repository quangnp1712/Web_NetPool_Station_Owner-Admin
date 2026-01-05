// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'station_detail_bloc.dart';

sealed class StationDetailEvent {
  const StationDetailEvent();
}

class StationDetailInitialEvent extends StationDetailEvent {
  String? stationId;
  bool isEdit;
  StationDetailInitialEvent({this.stationId, this.isEdit = false});
}

class ToggleEditModeEvent extends StationDetailEvent {
  final bool enableEdit; // true = bật sửa, false = tắt sửa (chỉ xem)
  ToggleEditModeEvent(this.enableEdit);
}

class LoadStationDetailEvent extends StationDetailEvent {
  String stationId;
  LoadStationDetailEvent({
    required this.stationId,
  });
}

class SubmitStationDetailEvent extends StationDetailEvent {
  final String? avatar;
  final String stationName;
  final String address;
  final String province;
  final String commune;
  final String district;
  final String hotline;
  final List<String>? media;
  SubmitStationDetailEvent({
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

class GenerateCaptchaEvent extends StationDetailEvent {}

class HandleVerifyCaptchaEvent extends StationDetailEvent {
  String captcha;
  HandleVerifyCaptchaEvent({
    required this.captcha,
  });
}

class ResetFormEvent extends StationDetailEvent {}

class SelectedStationIdEvent extends StationDetailEvent {
  int? newValue;
  SelectedStationIdEvent({
    this.newValue,
  });
}

class PickImagesEvent extends StationDetailEvent {
  bool isPickingImage;
  PickImagesEvent({
    required this.isPickingImage,
  });
}

class RemoveImageEvent extends StationDetailEvent {
  final int imageIndex;
  List<String> base64Images;
  RemoveImageEvent({
    required this.imageIndex,
    required this.base64Images,
  });
}

class LoadProvincesEvent extends StationDetailEvent {}

class LoadDistrictsEvent extends StationDetailEvent {
  int provinceCode;
  LoadDistrictsEvent({
    required this.provinceCode,
  });
}

class LoadCommunesEvent extends StationDetailEvent {
  int districtCode;
  LoadCommunesEvent({
    required this.districtCode,
  });
}

class SelectedProvinceEvent extends StationDetailEvent {
  ProvinceModel newValue;
  SelectedProvinceEvent({
    required this.newValue,
  });
}

class SelectedDistrictEvent extends StationDetailEvent {
  DistrictModel newValue;
  SelectedDistrictEvent({
    required this.newValue,
  });
}

class SelectedCommuneEvent extends StationDetailEvent {
  CommuneModel newValue;
  SelectedCommuneEvent({
    required this.newValue,
  });
}

class UpdateFullAddressEvent extends StationDetailEvent {
  String? address;
  String? placeId;
  CommuneModel? commune;
  DistrictModel? district;
  ProvinceModel? province;
  UpdateFullAddressEvent({
    this.address,
    this.placeId,
    this.commune,
    this.district,
    this.province,
  });
}

class SearchAddressSuggestionEvent extends StationDetailEvent {
  final String query;
  SearchAddressSuggestionEvent(this.query);
}

class ClearAddressSuggestionsEvent extends StationDetailEvent {}

class ShowStationListPageEvent extends StationDetailEvent {}

class StationUpdateEvent extends StationDetailEvent {
  final String stationName;
  final String address;
  final String province;
  final String commune;
  final String district;
  final String hotline;
  final String placeId;
  final List<String>? media;
  StationUpdateEvent({
    required this.stationName,
    required this.address,
    required this.province,
    required this.commune,
    required this.district,
    required this.hotline,
    required this.placeId,
    this.media,
  });
}

class ChangeTabEvent extends StationDetailEvent {
  final String newTab;
  const ChangeTabEvent(this.newTab);
  @override
  List<Object?> get props => [newTab];
}

class LoadStationEditDialogEvent extends StationDetailEvent {}
