import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/station_detail_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/repository/station_detail_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/data/city_controller/city_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/city_controller/city_repository.dart';

part 'station_detail_event.dart';
part 'station_detail_state.dart';

class StationDetailBloc extends Bloc<StationDetailEvent, StationDetailState> {
  StationDetailBloc() : super(StationDetailState()) {
    on<StationDetailInitialEvent>(_stationDetailInitialEvent);
    on<LoadStationDetailEvent>(_loadStationDetailEvent);
    on<ShowStationListPageEvent>(_showStationListPageEvent);
    on<ToggleEditModeEvent>(_toggleEditModeEvent);
  }

  FutureOr<void> _stationDetailInitialEvent(
      StationDetailInitialEvent event, Emitter<StationDetailState> emit) async {
    add(LoadStationDetailEvent(stationId: event.stationId ?? ""));
  }

  FutureOr<void> _loadStationDetailEvent(
      LoadStationDetailEvent event, Emitter<StationDetailState> emit) async {
    emit(state.copyWith(
      stationDetailStatus: StationDetailStatus.loading,
    ));

    StationDetailModelResponse? stationDetailModelResponse;
    try {
      if (event.stationId == "") {
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: "Lỗi vui lòng thử lại",
        ));
        DebugLogger.printLog("Lỗi: không có stationID ");
        return;
      }
      //! _onLoadDetailStation
      // bool isLoadDetailStation = await _onLoadDetailStation(event, emit);
      bool isLoadDetailStation = false;
      var results =
          await StationDetailRepository().findDetailStation(event.stationId);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        StationDetailModelResponse resultsBody =
            StationDetailModelResponse.fromJson(responseBody);
        if (resultsBody.data != null) {
          stationDetailModelResponse = resultsBody;
          isLoadDetailStation = true;
        }
      } else {
        DebugLogger.printLog("Lỗi: $responseMessage ");
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: "Lỗi vui lòng thử lại",
        ));
        isLoadDetailStation = false;
        return;
      }

      if (isLoadDetailStation) {
        //! _onLoadProvinces
        ProvinceModel? selectedProvince;
        int? selectedProvinceCode;
        bool isLoadingProvinces = false;
        List<ProvinceModel> provincesList;
        // isLoadingProvinces = await _onLoadProvinces(event, emit);
        try {
          var results = await CityRepository().getProvinces();
          var responseMessage = results['message'];
          var responseStatus = results['status'];
          var responseSuccess = results['success'];
          var responseBody = results['body'];
          if (responseSuccess || responseStatus == 200) {
            provincesList = (responseBody as List)
                .map((e) => ProvinceModel.fromJson(e as Map<String, dynamic>))
                .toList();

            isLoadingProvinces = true;
          } else {
            DebugLogger.printLog("Lỗi tải Tỉnh/TP");
            isLoadingProvinces = false;
            emit(state.copyWith(
              stationDetailStatus: StationDetailStatus.failure,
              message: "Lỗi vui lòng thử lại",
            ));
            return;
          }
        } catch (e) {
          DebugLogger.printLog("Lỗi tải Tỉnh/TP: $e");
          isLoadingProvinces = false;
          emit(state.copyWith(
            stationDetailStatus: StationDetailStatus.failure,
            message: "Lỗi vui lòng thử lại",
          ));
          return;
        }
        if (isLoadingProvinces) {
          for (var province in provincesList) {
            if (province.name.trim().toLowerCase() ==
                stationDetailModelResponse!.data!.province!
                    .trim()
                    .toLowerCase()) {
              selectedProvinceCode = province.code;
              selectedProvince = province;
              break;
            }
          }
        }

        //! _onLoadDistricts
        List<DistrictModel> districtsList = [];
        DistrictModel? selectedDistrict;
        int? selectedDistrictCode;
        bool isLoadingDistricts = false;
        if (selectedProvinceCode != null) {
          // isLoadingDistricts =
          //     await _onLoadDistricts(event, emit, selectedProvinceCode);
          try {
            var results =
                await CityRepository().getDistricts(selectedProvinceCode);

            var responseMessage = results['message'];
            var responseStatus = results['status'];
            var responseSuccess = results['success'];
            var responseBody = results['body'];
            if (responseSuccess || responseStatus == 200) {
              districtsList = (responseBody["districts"] as List)
                  .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
                  .toList();

              isLoadingDistricts = true;
            } else {
              DebugLogger.printLog("Lỗi tải Quận/Huyện");
              isLoadingDistricts = false;
              emit(state.copyWith(
                stationDetailStatus: StationDetailStatus.failure,
                message: "Lỗi vui lòng thử lại",
              ));
              return;
            }
          } catch (e) {
            DebugLogger.printLog("Lỗi tải Quận/Huyện: $e");
            emit(state.copyWith(
              stationDetailStatus: StationDetailStatus.failure,
              message: "Lỗi vui lòng thử lại",
            ));
            isLoadingDistricts = false;
            return;
          }
          if (isLoadingDistricts) {
            for (var district in districtsList) {
              if (district.name.trim().toLowerCase() ==
                  stationDetailModelResponse!.data!.district!
                      .trim()
                      .toLowerCase()) {
                selectedDistrictCode = district.code;
                selectedDistrict = district;
                break;
              }
            }
          }
        }

        //! _onLoadCommunes
        CommuneModel? selectedCommune;
        bool isLoadingCommunes = false;
        int? selectedCommuneCode;
        List<CommuneModel> communesList = [];
        if (selectedDistrictCode != null) {
          // isLoadingCommunes =
          //     await _onLoadCommunes(event, emit, selectedDistrictCode);
          try {
            var results =
                await CityRepository().getCommunes(selectedDistrictCode);
            var responseMessage = results['message'];
            var responseStatus = results['status'];
            var responseSuccess = results['success'];
            var responseBody = results['body'];
            if (responseSuccess || responseStatus == 200) {
              communesList = (responseBody["wards"] as List)
                  .map((e) => CommuneModel.fromJson(e as Map<String, dynamic>))
                  .toList();

              isLoadingCommunes = true;
            } else {
              DebugLogger.printLog("Lỗi tải Quận/Huyện");
              emit(state.copyWith(
                stationDetailStatus: StationDetailStatus.failure,
                message: "Lỗi vui lòng thử lại",
              ));
              isLoadingCommunes = false;
              return;
            }
          } catch (e) {
            DebugLogger.printLog("Lỗi tải Quận/Huyện: $e");
            emit(state.copyWith(
              stationDetailStatus: StationDetailStatus.failure,
              message: "Lỗi vui lòng thử lại",
            ));
            isLoadingCommunes = false;
            return;
          }
          if (isLoadingCommunes) {
            for (var commune in communesList) {
              if (commune.name.trim().toLowerCase() ==
                  stationDetailModelResponse!.data!.commune!
                      .trim()
                      .toLowerCase()) {
                selectedCommuneCode = commune.code;
                selectedCommune = commune;
                break;
              }
            }
          }
        }

        //! Ảnh
        List<String> images = [];
        if (stationDetailModelResponse!.data!.media != null &&
            stationDetailModelResponse.data!.media!.isNotEmpty) {
          images = stationDetailModelResponse.data!.media!
              .map((m) => m.url ?? "")
              .where((url) => url.isNotEmpty)
              .toList();
        } else if (stationDetailModelResponse.data!.avatar != null &&
            stationDetailModelResponse.data!.avatar != "") {
          images.add(stationDetailModelResponse.data!.avatar!.toString());
        }

        //! XỬ LÝ TÁCH ĐỊA CHỈ CHI TIẾT
        String extractedDetail = _extractDetailAddress(
          fullAddress: stationDetailModelResponse.data!.address ?? "",
          province: stationDetailModelResponse.data!.province,
          district: stationDetailModelResponse.data!.district,
          commune: stationDetailModelResponse.data!.commune,
        );

        //! full address
        final fullAddress = [
          extractedDetail,
          selectedCommune?.name ?? "",
          selectedDistrict?.name ?? "",
          selectedProvince?.name ?? "",
        ].where((s) => s.isNotEmpty).join(', ');

        //! trả kết quả
        if (isLoadingProvinces == true &&
            isLoadingDistricts == true &&
            isLoadingCommunes == true) {
          emit(state.copyWith(
            base64Images: images,
            stationName: stationDetailModelResponse.data!.stationName,
            address: extractedDetail,
            phone: stationDetailModelResponse.data!.hotline,
            statusName: stationDetailModelResponse.data!.statusName,
            statusCode: stationDetailModelResponse.data!.statusCode,
            fullAddressController: fullAddress,

            // Data Dropdowns
            provincesList: provincesList,
            districtList: districtsList,
            communeList: communesList,

            // Select
            selectedProvince: selectedProvince,
            selectedDistrict: selectedDistrict,
            selectedCommune: selectedCommune,
          ));
          return;
        }
      }
    } catch (e) {
      emit(state.copyWith(
        stationDetailStatus: StationDetailStatus.failure,
        message: "Lỗi vui lòng thử lại",
      ));
      DebugLogger.printLog("Lỗi : $e");
    }
  }

// --- HELPER FUNCTION: TÁCH ĐỊA CHỈ CHI TIẾT ---
  String _extractDetailAddress({
    required String fullAddress,
    String? province,
    String? district,
    String? commune,
  }) {
    if (fullAddress.isEmpty) return "";

    String processed = fullAddress;

    // Hàm xóa một thành phần khỏi chuỗi địa chỉ (không phân biệt hoa thường)
    String removeComponent(String source, String? component) {
      if (component == null || component.isEmpty) return source;
      // Tạo regex để replace (case insensitive)
      return source.replaceAll(
          RegExp(RegExp.escape(component), caseSensitive: false), "");
    }

    // Lần lượt xóa Tỉnh, Huyện, Xã khỏi chuỗi gốc
    processed = removeComponent(processed, province);
    processed = removeComponent(processed, district);
    processed = removeComponent(processed, commune);

    // Xử lý làm sạch dấu phẩy thừa
    // Ví dụ: "12 ABC, , , " -> "12 ABC"
    List<String> parts = processed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty) // Loại bỏ phần tử rỗng
        .toList();

    return parts.join(', '); // Ghép lại bằng dấu phẩy chuẩn
  }

  // --- HELPER FUNCTION: LÀM SẠCH TÊN HÀNH CHÍNH (Nếu bạn cần dùng để hiển thị) ---
  // Ví dụ: "Tỉnh Điện Biên" -> "Điện Biên"
  // String _cleanAdministrativeName(String name) {
  //   String cleaned = name;
  //   // Danh sách các tiền tố cần xóa
  //   const prefixes = [
  //     "Tỉnh ",
  //     "Thành phố ",
  //     "Thị xã ",
  //     "Quận ",
  //     "Huyện ",
  //     "Phường ",
  //     "Xã ",
  //     "Thị trấn "
  //   ];

  //   for (var prefix in prefixes) {
  //     if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
  //       // Cắt bỏ tiền tố (giữ nguyên case của phần tên riêng)
  //       return cleaned.substring(prefix.length).trim();
  //     }
  //   }
  //   return cleaned;
  // }

  FutureOr<void> _showStationListPageEvent(
      ShowStationListPageEvent event, Emitter<StationDetailState> emit) async {
    emit(state.copyWith(
        blocState: StationDetailBlocState.ShowStationListPageState));
  }

  Future<void> _toggleEditModeEvent(
      ToggleEditModeEvent event, Emitter<StationDetailState> emit) async {
    // Cập nhật screenMode dựa trên enableEdit
    // Nếu enableEdit = true -> ScreenMode.edit (Cho phép sửa)
    // Nếu enableEdit = false -> ScreenMode.view (Chỉ xem)

    emit(state.copyWith(
      screenMode: event.enableEdit ? ScreenMode.edit : ScreenMode.view,

      // Khi chuyển sang Edit, có thể cần tạo Captcha mới để sẵn sàng cho việc Lưu
      captchaText: event.enableEdit
          ? DateTime.now().millisecondsSinceEpoch.toString().substring(9)
          : state.captchaText,
      isCaptchaVerified: false, // Reset captcha verification khi chuyển mode
    ));
  }
}
