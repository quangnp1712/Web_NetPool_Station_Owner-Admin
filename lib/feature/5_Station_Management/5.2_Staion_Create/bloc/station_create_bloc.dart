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
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.2_Staion_Create/model/station_create_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.2_Staion_Create/repository/station_create_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/models/autocomplete_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/models/autocomplete_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/repository/autocomplete_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/data/city_controller/city_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/city_controller/city_repository.dart';

part 'station_create_event.dart';
part 'station_create_state.dart';

class StationCreateBloc extends Bloc<StationCreateEvent, StationCreateState> {
  String _captchaText = "";

  StationCreateBloc() : super(StationCreateState()) {
    on<StationCreateInitialEvent>(_stationCreateInitialEvent);
    on<GenerateCaptchaEvent>(_generateCaptchaEvent);
    on<HandleVerifyCaptchaEvent>(_handleVerifyCaptchaEvent);
    on<ResetFormEvent>(_resetFormEvent);
    on<SubmitStationCreateEvent>(_submitStationCreateEvent);
    on<PickImagesEvent>(_pickImagesEvent);
    on<RemoveImageEvent>(_removeImageEvent);
    on<LoadProvincesEvent>(_loadProvincesEvent);
    on<LoadDistrictsEvent>(_loadDistrictsEvent);
    on<LoadCommunesEvent>(_loadCommunesEvent);
    on<SelectedProvinceEvent>(_selectedProvinceEvent);
    on<SelectedDistrictEvent>(_selectedDistrictEvent);
    on<SelectedCommuneEvent>(_selectedCommuneEvent);
    on<UpdateFullAddressEvent>(_updateFullAddressEvent);

    on<SearchAddressSuggestionEvent>(_searchAddressSuggestionEvent);
    on<ClearAddressSuggestionsEvent>(_clearAddressSuggestionsEvent);
  }
  FutureOr<void> _stationCreateInitialEvent(
      StationCreateInitialEvent event, Emitter<StationCreateState> emit) async {
    emit(state.copyWith(
      stationCreateStatus: StationCreateStatus.initial,
      blocState: StationCreateBlocState.Initial,
    ));
    add(GenerateCaptchaEvent());
    add(LoadProvincesEvent());
  }

  final Random _random = Random();
  FutureOr<void> _generateCaptchaEvent(
      GenerateCaptchaEvent event, Emitter<StationCreateState> emit) async {
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
        stationCreateStatus: StationCreateStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
    }
  }

  FutureOr<void> _handleVerifyCaptchaEvent(
      HandleVerifyCaptchaEvent event, Emitter<StationCreateState> emit) async {
    try {
      if (event.captcha == "") {
        // (Tùy chọn: hiển thị snackbar lỗi "Vui lòng nhập mã")
        emit(state.copyWith(
          stationCreateStatus: StationCreateStatus.failure,
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
          // setState(() {
          //   _isCaptchaVerified = true;
          // });
          emit(state.copyWith(
            isVerifyingCaptcha: false,
            isCaptchaVerified: true,
          ));
        } else {
          // (Tùy chọn: hiển thị snackbar lỗi "Mã xác thực không đúng")
          emit(state.copyWith(
            stationCreateStatus: StationCreateStatus.failure,
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
        stationCreateStatus: StationCreateStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));
    }
  }

  FutureOr<void> _resetFormEvent(
      ResetFormEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreateState(
      // Bạn có thể giữ lại một số thông tin nếu cần, ví dụ list tỉnh đã load
      blocState: StationCreateBlocState.ResetFormState,
      provincesList: state.provincesList,
      // Các trường còn lại sẽ tự động về null/false/empty theo constructor mặc định
    ));
  }

  FutureOr<void> _submitStationCreateEvent(
      SubmitStationCreateEvent event, Emitter<StationCreateState> emit) async {
    emit(state.copyWith(stationCreateStatus: StationCreateStatus.loading));

    try {
      List<MediaModel> media = event.media != null
          ? await _uploadImagesToFirebase(event.media!)
          : [];
      StationCreateModel stationCreateModel = StationCreateModel(
          stationName: event.stationName,
          address: event.address,
          province: event.province,
          commune: event.commune,
          hotline: event.hotline,
          district: event.district,
          avatar: media.isNotEmpty ? media[0].url : null,
          media: media);
      var results =
          await StationCreateRepository().createStation(stationCreateModel);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          blocState: StationCreateBlocState.StationCreateSuccessState,
        ));
        emit(state.copyWith(
          stationCreateStatus: StationCreateStatus.success,
          message: "Đăng ký thành công",
        ));

        return;
      } else if (responseStatus == 409) {
        emit(state.copyWith(
          stationCreateStatus: StationCreateStatus.failure,
          message: responseMessage,
        ));

        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else if (responseStatus == 404) {
        emit(state.copyWith(
          stationCreateStatus: StationCreateStatus.failure,
          message: responseMessage,
        ));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else if (responseStatus == 401) {
        emit(state.copyWith(
          stationCreateStatus: StationCreateStatus.failure,
          message: responseMessage,
        ));
        DebugLogger.printLog("$responseStatus - $responseMessage");
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(state.copyWith(
          stationCreateStatus: StationCreateStatus.failure,
          message: "Lỗi! Vui lòng thử lại",
        ));
      }
      emit(state.copyWith(
        blocState: StationCreateBlocState.StationCreateFailState,
      ));
    } catch (e) {
      DebugLogger.printLog(e.toString());
      emit(state.copyWith(
        stationCreateStatus: StationCreateStatus.failure,
        message: "Lỗi! Vui lòng thử lại",
      ));

      emit(state.copyWith(
        blocState: StationCreateBlocState.StationCreateFailState,
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

  FutureOr<void> _pickImagesEvent(
      PickImagesEvent event, Emitter<StationCreateState> emit) async {
    if (event.isPickingImage) return; // Chống spam
    emit(state.copyWith(isPickingImage: true));

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<String> newImages = [];
        for (var file in result.files) {
          if (file.bytes != null) {
            String base64String = base64Encode(file.bytes!);
            String dataUri =
                "data:image/${file.extension ?? 'png'};base64,$base64String";
            newImages.add(dataUri);
          }
        }

        // Cập nhật state: Lấy danh sách cũ + thêm danh sách mới
        final List<String> updatedList = [
          ...state.base64Images, // Giữ lại ảnh cũ (URL hoặc Base64 cũ)
          ...newImages // Thêm ảnh mới vào sau
        ];
        emit(state.copyWith(
          blocState: StationCreateBlocState.PickImagesState,
          base64Images: updatedList,
          isPickingImage: false,
        ));
      } else {
        // Người dùng không chọn gì
        emit(state.copyWith(isPickingImage: false));
      }
    } catch (e) {
      emit(state.copyWith(
        stationCreateStatus: StationCreateStatus.failure,
        message: "Lỗi chọn ảnh",
      ));

      emit(state.copyWith(
        isPickingImage: false,
      ));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _removeImageEvent(
      RemoveImageEvent event, Emitter<StationCreateState> emit) async {
    try {
      final List<String> currentImages =
          List<String>.from(state.base64Images ?? []);
      if (event.imageIndex >= 0 && event.imageIndex < currentImages.length) {
        // Xóa ảnh tại vị trí index
        currentImages.removeAt(event.imageIndex);
        // Emit state mới
        emit(state.copyWith(
          blocState: StationCreateBlocState.RemoveImageState,
          base64Images: currentImages,
        ));
      } else {
        DebugLogger.printLog(
            "Lỗi xóa ảnh: Index ${event.imageIndex} không hợp lệ. Độ dài list: ${currentImages.length}");
      }
    } catch (e) {
      emit(state.copyWith(
        stationCreateStatus: StationCreateStatus.failure,
        message: "Lỗi chọn ảnh: $e",
      ));
      DebugLogger.printLog(e.toString());
    }
  }

  Future<void> _searchAddressSuggestionEvent(SearchAddressSuggestionEvent event,
      Emitter<StationCreateState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(addressSuggestions: []));
      return;
    }

    // Không set loading toàn màn hình, chỉ update list ngầm
    emit(state.copyWith(isLoadingAddressSuggestions: true));

    try {
      List<AutocompleteModel> autocompletes = [];
      // Giả lập delay API BE
      await Future.delayed(const Duration(milliseconds: 300));

      // var results = await AutocompleteRepository().autocomplete(event.query);
      // var responseMessage = results['message'];
      // var responseStatus = results['status'];
      // var responseSuccess = results['success'];
      // var responseBody = results['body'];
      // if (responseSuccess || responseStatus == 200) {
      //   AutocompleteModelResponse autocompleteModelResponse =
      //       AutocompleteModelResponse.fromJson(responseBody);
      //   if (autocompleteModelResponse.data != null ||
      //       autocompleteModelResponse.data!.isNotEmpty) {
      //     if (autocompleteModelResponse.data!.isNotEmpty) {
      //       autocompletes = autocompleteModelResponse.data!;
      //     }
      //   }
      // }

      // Giả lập kết quả trả về từ BE (Chỉ lấy phần Số nhà + Tên đường)
      // API thực tế sẽ lấy query + provinceId + districtId để search chính xác hơn
      final List<String> mockResults = [
        "${event.query} Nguyễn Văn Lượng",
        "${event.query} Quang Trung",
        "${event.query}/2A Phan Văn Trị",
        "${event.query} Lê Đức Thọ",
        "Hẻm ${event.query} Thống Nhất",
      ];

      emit(state.copyWith(
          addressSuggestions: mockResults, isLoadingAddressSuggestions: false));
      // emit(state.copyWith(
      //       addressSuggestions: autocompletes,
      //       isLoadingAddressSuggestions: false));
    } catch (e) {
      emit(state.copyWith(
          addressSuggestions: [], isLoadingAddressSuggestions: false));
      DebugLogger.printLog("Lỗi $e");
    }
  }

  FutureOr<void> _clearAddressSuggestionsEvent(
      ClearAddressSuggestionsEvent event,
      Emitter<StationCreateState> emit) async {
    emit(state.copyWith(addressSuggestions: []));
  }

  void _generateCaptcha() {
    String newCaptcha = "";
    // Tạo 5 số ngẫu nhiên
    for (int i = 0; i < 5; i++) {
      newCaptcha += _random.nextInt(10).toString();
    }
    _captchaText = newCaptcha;
  }

  FutureOr<void> _loadProvincesEvent(
      LoadProvincesEvent event, Emitter<StationCreateState> emit) async {
    emit(state.copyWith(
      isLoadingProvinces: true,
    ));
    try {
      var results = await CityRepository().getProvinces();
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess || responseStatus == 200) {
        List<ProvinceModel> provincesList = (responseBody as List)
            .map((e) => ProvinceModel.fromJson(e as Map<String, dynamic>))
            .toList();
        provincesList.map((name) => Utf8Encoding().decode(name as String));

        emit(state.copyWith(
            isLoadingProvinces: false, provincesList: provincesList));
      } else {
        emit(state.copyWith(
          isLoadingProvinces: false,
        ));
        DebugLogger.printLog("Lỗi tải Tỉnh/TP");
      }
    } catch (e) {
      emit(state.copyWith(isLoadingProvinces: false));
      DebugLogger.printLog("Lỗi tải Tỉnh/TP: $e");
    }
  }

  FutureOr<void> _loadDistrictsEvent(
      LoadDistrictsEvent event, Emitter<StationCreateState> emit) async {
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
          blocState: StationCreateBlocState.LoadDistrictsState,
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
      LoadCommunesEvent event, Emitter<StationCreateState> emit) async {
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
          blocState: StationCreateBlocState.LoadCommunesState,
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
      SelectedProvinceEvent event, Emitter<StationCreateState> emit) async {
    emit(state.copyWith(
        blocState: StationCreateBlocState.SelectedProvinceState,
        selectedProvince: event.newValue));
  }

  FutureOr<void> _selectedDistrictEvent(
      SelectedDistrictEvent event, Emitter<StationCreateState> emit) async {
    emit(state.copyWith(
        blocState: StationCreateBlocState.SelectedDistrictState,
        selectedDistrict: event.newValue));
  }

  FutureOr<void> _selectedCommuneEvent(
      SelectedCommuneEvent event, Emitter<StationCreateState> emit) async {
    emit(state.copyWith(
        blocState: StationCreateBlocState.SelectedCommuneState,
        selectedCommune: event.newValue));
  }

  FutureOr<void> _updateFullAddressEvent(
      UpdateFullAddressEvent event, Emitter<StationCreateState> emit) async {
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
      emit(state.copyWith(fullAddressController: fullAddress));
    } catch (e) {
      DebugLogger.printLog("Lỗi: $e");
    }
  }
}
