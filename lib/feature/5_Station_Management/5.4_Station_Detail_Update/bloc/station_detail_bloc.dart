import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/models/autocomplete_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/models/autocomplete_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/repository/autocomplete_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/1.station/station_detail_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/1.station/station_detail_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/2_space/space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/2_space/space_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/2_space/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/2_space/station_space_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/3_area/area_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/3_area/area_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/4_resource/resoucre_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/4_resource/resoucre_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/model/4_resource/resoucre_spec_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/repository/station_detail_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/data/city_controller/city_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/city_controller/city_repository.dart';

part 'station_detail_event.dart';
part 'station_detail_state.dart';

class StationDetailBloc extends Bloc<StationDetailEvent, StationDetailState> {
  String _captchaText = "";

  StationDetailBloc() : super(StationDetailState()) {
    on<StationDetailInitialEvent>(_stationDetailInitialEvent);
    on<LoadStationDetailEvent>(_loadStationDetailEvent);
    on<ShowStationListPageEvent>(_showStationListPageEvent);
    on<ToggleEditModeEvent>(_toggleEditModeEvent);
    on<GenerateCaptchaEvent>(_generateCaptchaEvent);
    on<HandleVerifyCaptchaEvent>(_handleVerifyCaptchaEvent);
    on<ResetFormEvent>(_resetFormEvent);
    on<PickImagesEvent>(_pickImagesEvent);
    on<RemoveImageEvent>(_removeImageEvent);
    on<LoadDistrictsEvent>(_loadDistrictsEvent);
    on<LoadCommunesEvent>(_loadCommunesEvent);
    on<SelectedProvinceEvent>(_selectedProvinceEvent);
    on<SelectedDistrictEvent>(_selectedDistrictEvent);
    on<SelectedCommuneEvent>(_selectedCommuneEvent);
    on<UpdateFullAddressEvent>(_updateFullAddressEvent);
    on<StationUpdateEvent>(_stationUpdateEvent);
    on<SearchAddressSuggestionEvent>(_onSearchAddress);
    on<ClearAddressSuggestionsEvent>(_onClearAddress);
    on<ChangeTabEvent>(_onChangeTab);
    on<LoadStationEditDialogEvent>(_onLoadStationEditDialog);
  }

  FutureOr<void> _stationDetailInitialEvent(
      StationDetailInitialEvent event, Emitter<StationDetailState> emit) async {
    emit(StationDetailState());
    add(LoadStationDetailEvent(stationId: event.stationId ?? ""));
  }

  FutureOr<void> _loadStationDetailEvent(
      LoadStationDetailEvent event, Emitter<StationDetailState> emit) async {
    emit(state.copyWith(
      stationDetailStatus: StationDetailStatus.loadingHeader,
    ));

    //$ KHỞI TẠO VÀ BẮT ĐẦU ĐẾM GIỜ
    final stopwatch = Stopwatch()..start();

    StationDetailModelResponse? stationDetailModelResponse;
    //$ check stationID
    try {
      if (event.stationId == "") {
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: "Lỗi vui lòng thử lại",
        ));
        DebugLogger.printLog("Lỗi: không có stationID ");
        return;
      }

      //! call api station + province
      //! _onLoadDetailStation
      //! _onLoadProvinces
      final results = await Future.wait([
        StationDetailRepository().findDetailStation(event.stationId),
        CityRepository().getProvinces(),
      ]);

      final stationResult = results[0];
      final provinceResult = results[1];

      //! 1. Xử lý dữ liệu Station - stationResult
      var responseMessage = stationResult['message'];
      var responseStatus = stationResult['status'];
      var responseSuccess = stationResult['success'];
      var responseBody = stationResult['body'];
      if (responseSuccess || responseStatus == 200) {
        StationDetailModelResponse resultsBody =
            StationDetailModelResponse.fromJson(responseBody);
        if (resultsBody.data != null) {
          stationDetailModelResponse = resultsBody;
        }
      } else {
        DebugLogger.printLog("Lỗi: $responseMessage ");
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: "Lỗi vui lòng thử lại",
        ));
        return;
      }

      //! 2. Xử lý dữ liệu Tỉnh/TP - provinceResult
      bool isLoadingProvinces = false;
      List<ProvinceModel> provincesList;
      try {
        var responseMessage = provinceResult['message'];
        var responseStatus = provinceResult['status'];
        var responseSuccess = provinceResult['success'];
        var responseBody = provinceResult['body'];
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

      //! 3. Chuyển sang Loading Content (Skeleton UI) ngay khi có Header
      emit(state.copyWith(
        station: stationDetailModelResponse.data,
        base64Images: images,
        currentStationId: event.stationId,
        stationDetailStatus: StationDetailStatus.loadingContent,
        provincesList: provincesList,
      ));

      //! Lấy thông tin cho trạng thái khu vực
      //! 4. Call API Space
      //! 4.1 API STATION SPACE
      //$ emit state.areas : stationSpaces
      List<StationSpaceModel> stationSpaces = [];
      var resultsSpace = await StationDetailRepository()
          .getStationSpace(event.stationId.toString());
      var responseMessageSpace = resultsSpace['message'];
      var responseStatusSpace = resultsSpace['status'];
      var responseSuccessSpace = resultsSpace['success'];
      var responseBodySpace = resultsSpace['body'];
      if (responseSuccessSpace || responseStatusSpace == 200) {
        StationSpaceListModelResponse resultsBodySpace =
            StationSpaceListModelResponse.fromJson(responseBodySpace);
        if (resultsBodySpace.data != null) {
          try {
            stationSpaces = resultsBodySpace.data!;
          } catch (e) {
            stationSpaces = [];
          }
        }
      }

      //! 4.2 API PLATFORM SPACE
      List<PlatformSpaceModel> platformSpaces = [];
      var resultsPlatformSpaces =
          await StationDetailRepository().getPlatformSpace();
      var responseMessagePlatformSpaces = resultsPlatformSpaces['message'];
      var responseStatusPlatformSpaces = resultsPlatformSpaces['status'];
      var responseSuccessPlatformSpaces = resultsPlatformSpaces['success'];
      var responseBodyPlatformSpaces = resultsPlatformSpaces['body'];

      if (responseSuccessPlatformSpaces ||
          responseStatusPlatformSpaces == 200) {
        SpaceListModelResponse resultsBodyPlatformSpaces =
            SpaceListModelResponse.fromJson(responseBodyPlatformSpaces);

        if (resultsBodyPlatformSpaces.data != null) {
          try {
            platformSpaces = resultsBodyPlatformSpaces.data!;
          } catch (e) {
            platformSpaces = [];
          }
        }
      }

      //! 4.3 Gắn platform space vào staion space
      if (platformSpaces.isNotEmpty && stationSpaces.isNotEmpty) {
        final platformMap = {for (var p in platformSpaces) p.spaceId: p};

        for (var space in stationSpaces) {
          // Tìm kiếm trong Map cực nhanh
          final platform = platformMap[space.spaceId];

          if (platform != null) {
            space.space = platform;
          }
        }
      }

      //! 5. Call API Areas
      List<AreaModel> areas = [];
      for (var space in stationSpaces) {
        var resultsAreas = await StationDetailRepository().getArea(
          "",
          event.stationId.toString(),
          space.spaceId.toString(),
          "ACTIVE",
          "0",
          "10",
        );
        var responseMessageAreas = resultsAreas['message'];
        var responseStatusAreas = resultsAreas['status'];
        var responseSuccessAreas = resultsAreas['success'];
        var responseBodyAreas = resultsAreas['body'];

        if (responseSuccessAreas || responseStatusAreas == 200) {
          AreaListModelResponse resultsBodyAreas =
              AreaListModelResponse.fromJson(responseBodyAreas);

          //! Lọc dữ liệu
          if (resultsBodyAreas.data != null) {
            try {
              for (var area in resultsBodyAreas.data!) {
                area.spaceName = space.spaceName;
              }
              areas.addAll(resultsBodyAreas.data!);
              space.areas = resultsBodyAreas.data ?? [];
            } catch (e) {
              areas;
            }
          }
        }
      }

      //! XỬ LÝ TÁCH ĐỊA CHỈ CHI TIẾT
      String extractedDetail = _extractDetailAddress(
        fullAddress: stationDetailModelResponse.data!.address ?? "",
        province: stationDetailModelResponse.data!.province,
        district: stationDetailModelResponse.data!.district,
        commune: stationDetailModelResponse.data!.commune,
      );

      //$ 2. DỪNG ĐỒNG HỒ VÀ LOG KẾT QUẢ
      stopwatch.stop();
      final elapsed = stopwatch.elapsed;
      final minutes = elapsed.inMinutes;
      final seconds =
          elapsed.inSeconds % 60; // Lấy phần dư giây sau khi trừ phút
      final milliseconds = elapsed.inMilliseconds % 1000; // Lấy phần lẻ ms
      DebugLogger.printLog(
          "🚀 [Performance] Hoàn tất sau: $minutes phút $seconds giây $milliseconds ms "
          "(Tổng: ${stopwatch.elapsedMilliseconds}ms)");

      //! trả kết quả
      emit(state.copyWith(
        address: extractedDetail,
        areas: areas,
        spaces: stationSpaces,
      ));
      return;
    } catch (e) {
      emit(state.copyWith(
        stationDetailStatus: StationDetailStatus.failure,
        message: "Lỗi vui lòng thử lại",
      ));
      DebugLogger.printLog("Lỗi : $e");
    }
  }

  FutureOr<void> _onLoadStationEditDialog(LoadStationEditDialogEvent event,
      Emitter<StationDetailState> emit) async {
    emit(
        state.copyWith(stationDetailStatus: StationDetailStatus.loadingDialog));
    try {
      //! 3. Tìm Tỉnh trùng khớp để lấy ID
      ProvinceModel? selectedProvince;
      int? selectedProvinceCode;

      // Helper tìm kiếm nhanh hơn loop thủ công
      try {
        selectedProvince = state.provincesList.firstWhere((p) =>
            p.name.trim().toLowerCase() ==
            state.station!.province!.trim().toLowerCase());
        selectedProvinceCode = selectedProvince.code;
      } catch (_) {
        DebugLogger.printLog("Không tìm thấy tỉnh matching");
        // Không tìm thấy tỉnh matching
      }

      //! 4 _onLoadDistricts
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
          try {
            selectedDistrict = districtsList.firstWhere((d) =>
                d.name.trim().toLowerCase() ==
                state.station!.district!.trim().toLowerCase());
            selectedDistrictCode = selectedDistrict.code;
          } catch (_) {}
        }
      }

      //! _onLoadCommunes
      CommuneModel? selectedCommune;
      bool isLoadingCommunes = false;
      int? selectedCommuneCode;
      List<CommuneModel> communesList = [];
      if (selectedDistrictCode != null) {
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
          try {
            selectedCommune = communesList.firstWhere((c) =>
                c.name.trim().toLowerCase() ==
                state.station!.commune!.trim().toLowerCase());
          } catch (_) {}
        }
      }
      //! full address
      final fullAddress = [
        state.address,
        selectedCommune?.name ?? "",
        selectedDistrict?.name ?? "",
        selectedProvince?.name ?? "",
      ].where((s) => s.isNotEmpty).join(', ');

      //! generateCaptcha
      _generateCaptcha();

      emit(state.copyWith(
          stationName: state.station!.stationName,
          address: state.station!.address,
          phone: state.station!.hotline,
          fullAddressController: fullAddress,

          // Data Dropdowns
          districtList: districtsList,
          communeList: communesList,

          // Select
          selectedProvince: selectedProvince,
          selectedDistrict: selectedDistrict,
          selectedCommune: selectedCommune,
          screenMode: ScreenMode.edit,

          // generateCaptcha
          captchaText: _captchaText,
          isCaptchaVerified: false,
          isVerifyingCaptcha: false,
          isClearCaptchaController: true));
    } catch (e) {}
  }

  // Hàm phụ trợ để check status response cho gọn code
  bool _isSuccess(Map<String, dynamic> result) {
    return result['success'] == true || result['status'] == 200;
  }

// Hàm phụ trợ emit lỗi
  void _emitFailure(Emitter<StationDetailState> emit, String msg) {
    DebugLogger.printLog(msg);
    emit(state.copyWith(
      stationDetailStatus: StationDetailStatus.failure,
      message: msg,
    ));
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
        blocState: StationDetailBlocState.ToggleEditModeState,
        stationDetailStatus: StationDetailStatus.loadingHeader));
  }

  final Random _random = Random();
  FutureOr<void> _generateCaptchaEvent(
      GenerateCaptchaEvent event, Emitter<StationDetailState> emit) async {
    try {
      _generateCaptcha();
      //setState
      // Reset lại trạng thái xác thực
      emit(state.copyWith(
          captchaText: _captchaText,
          isCaptchaVerified: false,
          isVerifyingCaptcha: false,
          isClearCaptchaController: true));
    } catch (e) {
      DebugLogger.printLog(e.toString());
      emit(state.copyWith(
        stationDetailStatus: StationDetailStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
    }
  }

  void _generateCaptcha() {
    String newCaptcha = "";
    // Tạo 5 số ngẫu nhiên
    for (int i = 0; i < 5; i++) {
      newCaptcha += _random.nextInt(10).toString();
    }
    _captchaText = newCaptcha;
  }

  FutureOr<void> _handleVerifyCaptchaEvent(
      HandleVerifyCaptchaEvent event, Emitter<StationDetailState> emit) async {
    try {
      if (event.captcha == "") {
        // (Tùy chọn: hiển thị snackbar lỗi "Vui lòng nhập mã")
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: "Vui lòng nhập mã",
        ));
      } else {
        // _isVerifyingCaptcha - Loading

        emit(state.copyWith(
          isVerifyingCaptcha: true,
        ));
        // --- Giả lập gọi API kiểm tra captcha ---
        await Future.delayed(const Duration(seconds: 1));

        //  So sánh với mã động
        bool isSuccess = event.captcha == _captchaText;

        if (isSuccess) {
          emit(state.copyWith(
            isVerifyingCaptcha: false,
            isCaptchaVerified: true,
            blocState: StationDetailBlocState.VerifyCaptchaSuccessState,
          ));
        } else {
          // (Tùy chọn: hiển thị snackbar lỗi "Mã xác thực không đúng")
          emit(state.copyWith(
            stationDetailStatus: StationDetailStatus.failure,
            message: "Mã xác thực không đúng",
          ));

          _generateCaptcha(); //  Tạo mã mới nếu sai
          emit(state.copyWith(
            captchaText: _captchaText,
            isCaptchaVerified: false,
            isVerifyingCaptcha: false,
            isClearCaptchaController: true,
          ));
        }
      }
    } catch (e) {
      DebugLogger.printLog(e.toString());
      emit(state.copyWith(
        stationDetailStatus: StationDetailStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
    }
  }

  FutureOr<void> _resetFormEvent(
      ResetFormEvent event, Emitter<StationDetailState> emit) async {
    emit(StationDetailState(
      // Bạn có thể giữ lại một số thông tin nếu cần, ví dụ list tỉnh đã load
      blocState: StationDetailBlocState.ResetFormState,
      provincesList: state.provincesList,
      // Các trường còn lại sẽ tự động về null/false/empty theo constructor mặc định
    ));
  }

  Future<void> _pickImagesEvent(
      PickImagesEvent event, Emitter<StationDetailState> emit) async {
    if (event.isPickingImage) return; // Chống spam
    // 1. Bật loading (ngăn user bấm liên tục)
    emit(state.copyWith(isPickingImage: true));

    try {
      // 2. Gọi File Picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<String> newPickedImages = [];

        // 3. Duyệt qua các file vừa chọn và convert sang Base64
        for (var file in result.files) {
          if (file.bytes != null) {
            String base64String = base64Encode(file.bytes!);
            String extension = file.extension ?? 'png';
            String dataUri = "data:image/$extension;base64,$base64String";
            newPickedImages.add(dataUri);
          }
        }

        // 4. QUAN TRỌNG: Nối ảnh mới vào danh sách cũ
        // state.base64Images chứa Avatar (URL) cũ, ta giữ nguyên nó
        final List<String> updatedList = [
          ...state.base64Images, // Giữ lại ảnh cũ (URL hoặc Base64 cũ)
          ...newPickedImages // Thêm ảnh mới vào sau
        ];

        emit(state.copyWith(
          blocState: StationDetailBlocState.PickImagesState,
          isPickingImage: false,
          base64Images: updatedList,
        ));
      } else {
        // User hủy chọn -> Tắt loading
        emit(state.copyWith(isPickingImage: false));
      }
    } catch (e) {
      emit(state.copyWith(
        stationDetailStatus: StationDetailStatus.failure,
        message: "Lỗi chọn ảnh",
      ));

      emit(state.copyWith(
        isPickingImage: false,
      ));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _removeImageEvent(
      RemoveImageEvent event, Emitter<StationDetailState> emit) async {
    try {
      final List<String> currentImages =
          List<String>.from(state.base64Images ?? []);

      // Kiểm tra an toàn index để tránh RangeError
      if (event.imageIndex >= 0 && event.imageIndex < currentImages.length) {
        // Xóa trên danh sách bản sao
        currentImages.removeAt(event.imageIndex);

        // Emit danh sách mới
        emit(state.copyWith(
          blocState: StationDetailBlocState.RemoveImageState,
          base64Images: currentImages,
        ));
      } else {
        DebugLogger.printLog(
            "Lỗi xóa ảnh: Index ${event.imageIndex} không hợp lệ. Độ dài list: ${currentImages.length}");
      }
    } catch (e) {
      emit(state.copyWith(
        stationDetailStatus: StationDetailStatus.failure,
        message: "Lỗi xóa ảnh: $e",
      ));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _loadDistrictsEvent(
      LoadDistrictsEvent event, Emitter<StationDetailState> emit) async {
    emit(state.copyWith(isLoadingDistricts: true));
    try {
      var results = await CityRepository().getDistricts(event.provinceCode);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        List<DistrictModel> districtsList = (responseBody["districts"] as List)
            .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
            .toList();
        districtsList.map((name) => Utf8Encoding().decode(name as String));

        emit(state.copyWith(
          blocState: StationDetailBlocState.LoadDistrictsState,
          isLoadingDistricts: false,
          districtList: districtsList,
          communeList: [],
          selectedCommune: null,
          selectedDistrict: null,
        ));
      } else {
        emit(state.copyWith(
          isLoadingDistricts: false,
          districtList: [],
          communeList: [],
          selectedCommune: null,
          selectedDistrict: null,
        ));

        DebugLogger.printLog("Lỗi tải Quận/Huyện");
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingDistricts: false,
        districtList: [],
        communeList: [],
        selectedCommune: null,
        selectedDistrict: null,
      ));

      DebugLogger.printLog("Lỗi tải Quận/Huyện: $e");
    }
  }

  FutureOr<void> _loadCommunesEvent(
      LoadCommunesEvent event, Emitter<StationDetailState> emit) async {
    emit(state.copyWith(isLoadingCommunes: true));
    try {
      var results = await CityRepository().getCommunes(event.districtCode);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        List<CommuneModel> communesList = (responseBody["wards"] as List)
            .map((e) => CommuneModel.fromJson(e as Map<String, dynamic>))
            .toList();
        communesList.map((name) => Utf8Encoding().decode(name as String));

        emit(state.copyWith(
          blocState: StationDetailBlocState.LoadCommunesState,
          isLoadingCommunes: false,
          communeList: communesList,
          selectedCommune: null,
        ));
      } else {
        emit(state.copyWith(
          isLoadingCommunes: false,
          communeList: [],
          selectedCommune: null,
        ));

        DebugLogger.printLog("Lỗi tải Quận/Huyện");
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingCommunes: false,
        communeList: [],
        selectedCommune: null,
      ));

      DebugLogger.printLog("Lỗi tải Quận/Huyện: $e");
    }
  }

  FutureOr<void> _selectedProvinceEvent(
      SelectedProvinceEvent event, Emitter<StationDetailState> emit) async {
    emit(state.copyWith(
      blocState: StationDetailBlocState.SelectedProvinceState,
      selectedProvince: event.newValue,
      selectedDistrict: null,
      selectedCommune: null,
      districtList: [],
      communeList: [],
    ));
  }

  FutureOr<void> _selectedDistrictEvent(
      SelectedDistrictEvent event, Emitter<StationDetailState> emit) async {
    emit(state.copyWith(
      blocState: StationDetailBlocState.SelectedDistrictState,
      selectedDistrict: event.newValue,
      selectedCommune: null,
      communeList: [],
    ));
  }

  FutureOr<void> _selectedCommuneEvent(
      SelectedCommuneEvent event, Emitter<StationDetailState> emit) async {
    emit(state.copyWith(
        blocState: StationDetailBlocState.SelectedCommuneState,
        selectedCommune: event.newValue));
  }

  FutureOr<void> _updateFullAddressEvent(
      UpdateFullAddressEvent event, Emitter<StationDetailState> emit) async {
    try {
      final String address =
          event.address != null ? event.address!.trim().toString() : "";
      final String commune = event.commune?.name ?? "";
      final String district = event.district?.name ?? "";
      final String province = event.province?.name ?? "";

      // Ghép chuỗi, lọc bỏ các phần rỗng
      final fullAddress = [address, commune, district, province]
          .where((s) => s.isNotEmpty)
          .join(', ');
      emit(state.copyWith(
          fullAddressController: fullAddress, placeId: event.placeId));
    } catch (e) {
      DebugLogger.printLog("Lỗi: $e");
    }
  }

  FutureOr<void> _stationUpdateEvent(
      StationUpdateEvent event, Emitter<StationDetailState> emit) async {
    emit(
        state.copyWith(stationDetailStatus: StationDetailStatus.loadingDialog));

    try {
      List<MediaModel> media = event.media != null
          ? await _uploadImagesToFirebase(event.media!)
          : [];
      StationDetailModel stationDetailModel = StationDetailModel(
          stationName: event.stationName,
          address: event.address,
          province: event.province,
          commune: event.commune,
          hotline: event.hotline,
          district: event.district,
          avatar: media.isNotEmpty ? media[0].url : null,
          media: media,
          placeId: event.placeId);
      var results = await StationDetailRepository()
          .updateStation(state.currentStationId, stationDetailModel);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          blocState: StationDetailBlocState.StationUpdateSuccessState,
          stationDetailStatus: StationDetailStatus.success,
          message: "Cập nhập thành công",
        ));

        return;
      } else if (responseStatus == 409) {
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: responseMessage,
        ));

        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else if (responseStatus == 404) {
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: responseMessage,
        ));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else if (responseStatus == 401) {
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: responseMessage,
        ));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(state.copyWith(
          stationDetailStatus: StationDetailStatus.failure,
          message: "Lỗi! Vui lòng thử lại",
        ));
      }
      emit(state.copyWith(
        blocState: StationDetailBlocState.StationUpdateFailState,
      ));
    } catch (e) {
      DebugLogger.printLog(e.toString());
      emit(state.copyWith(
        stationDetailStatus: StationDetailStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));

      emit(state.copyWith(
        blocState: StationDetailBlocState.StationUpdateFailState,
      ));
    }
  }

  // --- THÊM: HÀM HELPER UPLOAD ẢNH ---
  Future<List<MediaModel>> _uploadImagesToFirebase(
      List<String> base64Images) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    List<MediaModel> uploadedUrls = [];

    // (Chúng ta dùng `for` thay vì `forEach` vì `forEach` không hỗ trợ `await`)
    for (String dataUri in base64Images) {
      if (dataUri.startsWith('http')) {
        uploadedUrls.add(MediaModel(url: dataUri));
        continue;
      }
      try {
        // 1. Tách chuỗi Base64
        // (data:image/png;base64,iVBOR...)
        final String base64String = dataUri.split(',').last;
        // 2. Decode thành bytes
        final Uint8List imageBytes = base64Decode(base64String);

        // 3. Tạo tên file ngẫu nhiên
        final String fileName =
            'station_media/station_media_${DateTime.now().millisecondsSinceEpoch}.png';

        // 4. Tạo reference (tham chiếu)
        final Reference ref = storage.ref().child(fileName);

        // 5. Upload (dùng putData)
        // (Set metadata để trình duyệt hiển thị đúng)
        final SettableMetadata metadata =
            SettableMetadata(contentType: 'image/png');
        await ref.putData(imageBytes, metadata);

        // 6. Lấy URL
        final String downloadURL = await ref.getDownloadURL();

        // 7. Thêm vào danh sách (dưới dạng MediaModel)
        uploadedUrls.add(MediaModel(url: downloadURL));
      } catch (e) {
        DebugLogger.printLog("Lỗi upload 1 ảnh: $e");
        // (Bỏ qua ảnh này và tiếp tục)
      }
    }

    DebugLogger.printLog("Đã upload xong ${uploadedUrls.length} ảnh.");
    return uploadedUrls;
  }
  // ------------------------------------

  Future<void> _onSearchAddress(SearchAddressSuggestionEvent event,
      Emitter<StationDetailState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(addressSuggestions: []));
      return;
    }

    emit(state.copyWith(isLoadingAddressSuggestions: true));
    try {
      List<AutocompleteModel> autocompletes = [];

      //! full address
      String _query = [
        event.query,
        state.selectedCommune?.name,
        state.selectedDistrict?.name,
        state.selectedProvince?.name,
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      //! call api
      var results = await AutocompleteRepository().autocomplete(_query);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        AutocompleteModelResponse autocompleteModelResponse =
            AutocompleteModelResponse.fromJson(responseBody);
        if (autocompleteModelResponse.data != null ||
            autocompleteModelResponse.data!.isNotEmpty) {
          if (autocompleteModelResponse.data!.isNotEmpty) {
            autocompletes = autocompleteModelResponse.data!;
          }
        }
      }

      emit(state.copyWith(
          addressSuggestions: autocompletes,
          isLoadingAddressSuggestions: false));
    } catch (e) {
      emit(state.copyWith(
          addressSuggestions: [], isLoadingAddressSuggestions: false));
      DebugLogger.printLog("Lỗi $e");
    }
  }

  void _onClearAddress(
      ClearAddressSuggestionsEvent event, Emitter<StationDetailState> emit) {
    emit(state.copyWith(addressSuggestions: []));
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<StationDetailState> emit) {
    emit(state.copyWith(activeTab: event.newTab));
  }
}
