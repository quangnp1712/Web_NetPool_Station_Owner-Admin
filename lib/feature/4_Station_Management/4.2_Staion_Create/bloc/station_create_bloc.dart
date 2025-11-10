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
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.2_Staion_Create/model/station_create_model.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.2_Staion_Create/repository/station_create_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/city_controller/city_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/city_controller/city_repository.dart';

part 'station_create_event.dart';
part 'station_create_state.dart';

class StationCreateBloc extends Bloc<StationCreateEvent, StationCreateState> {
  String _captchaText = "";

  StationCreateBloc() : super(StationCreateInitial()) {
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
  }
  FutureOr<void> _stationCreateInitialEvent(
      StationCreateInitialEvent event, Emitter<StationCreateState> emit) {
    emit(StationCreateInitial());
    add(LoadProvincesEvent());
    add(GenerateCaptchaEvent());
    // thêm lấy ds station
  }

  final Random _random = Random();
  FutureOr<void> _generateCaptchaEvent(
      GenerateCaptchaEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    emit(StationCreate_LoadingState(isLoading: true));

    try {
      _generateCaptcha();
      //setState
      // Reset lại trạng thái xác thực
      emit(GenerateCaptchaState(
          captchaText: _captchaText,
          isCaptchaVerified: false,
          isVerifyingCaptcha: false,
          isClearCaptchaController: true));
      emit(StationCreate_ChangeState());
      emit(StationCreate_LoadingState(isLoading: false));
    } catch (e) {
      emit(StationCreate_ChangeState());
      emit(StationCreate_LoadingState(isLoading: false));
      DebugLogger.printLog(e.toString());
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
    }
  }

  FutureOr<void> _handleVerifyCaptchaEvent(
      HandleVerifyCaptchaEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());

    try {
      if (event.captcha == "") {
        // (Tùy chọn: hiển thị snackbar lỗi "Vui lòng nhập mã")
        emit(ShowSnackBarActionState(
            message: "Vui lòng nhập mã", success: false));
      } else {
        // _isVerifyingCaptcha - Loading

        emit(LoadingCaptchaState(isVerifyingCaptcha: true));

        // --- Giả lập gọi API kiểm tra captcha ---
        await Future.delayed(const Duration(seconds: 1));

        //  So sánh với mã động
        bool isSuccess = event.captcha == _captchaText;

        if (isSuccess) {
          // setState(() {
          //   _isCaptchaVerified = true;
          // });
          emit(HandleVerifyCaptchaState(
              isVerifyingCaptcha: false, isCaptchaVerified: true));
        } else {
          // (Tùy chọn: hiển thị snackbar lỗi "Mã xác thực không đúng")
          emit(ShowSnackBarActionState(
              message: "Mã xác thực không đúng", success: false));
          _generateCaptcha(); //  Tạo mã mới nếu sai
          emit(GenerateCaptchaState(
              captchaText: _captchaText,
              isCaptchaVerified: false,
              isVerifyingCaptcha: false,
              isClearCaptchaController: true));
        }
      }
    } catch (e) {
      emit(StationCreate_ChangeState());
      emit(StationCreate_LoadingState(isLoading: false));
      DebugLogger.printLog(e.toString());
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
    }
  }

  FutureOr<void> _resetFormEvent(
      ResetFormEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    emit(ResetFormState());
  }

  FutureOr<void> _submitStationCreateEvent(
      SubmitStationCreateEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());

    emit(StationCreate_LoadingState(isLoading: true));
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
        emit(StationCreate_LoadingState(isLoading: false));
        emit(StationCreateSuccessState());
        emit(ShowSnackBarActionState(
            message: "Đăng ký thành công", success: responseSuccess));
      } else if (responseStatus == 400) {
        emit(StationCreate_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else if (responseStatus == 404) {
        emit(StationCreate_LoadingState(isLoading: false));
        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else if (responseStatus == 401) {
        emit(StationCreate_LoadingState(isLoading: false));

        emit(ShowSnackBarActionState(
            message: responseMessage, success: responseSuccess));
      } else {
        emit(StationCreate_LoadingState(isLoading: false));
        DebugLogger.printLog("$responseStatus - $responseMessage");
        emit(ShowSnackBarActionState(
            message: "Lỗi! Vui lòng thử lại", success: false));
      }
    } catch (e) {
      emit(StationCreate_LoadingState(isLoading: false));
      DebugLogger.printLog(e.toString());
      emit(ShowSnackBarActionState(
          message: "Lỗi! Vui lòng thử lại", success: false));
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
    emit(StationCreate_ChangeState());
    if (event.isPickingImage) return; // Chống spam

    emit(IsPickingImageState(isPickingImage: true));

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

        emit(
            PickingImagesState(base64Images: newImages, isPickingImage: false));
      } else {
        // Người dùng không chọn gì
        emit(IsPickingImageState(isPickingImage: false));
      }
    } catch (e) {
      emit(ShowSnackBarActionState(message: "Lỗi chọn ảnh", success: false));
      emit(IsPickingImageState(isPickingImage: false));
      DebugLogger.printLog(e.toString());
    }
  }

  FutureOr<void> _removeImageEvent(
      RemoveImageEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    try {
      List<String> currentImages = event.base64Images;
      // Xóa ảnh tại vị trí index
      currentImages.removeAt(event.imageIndex);
      // Emit state mới
      emit(RemoveImageState(base64Images: currentImages));
    } catch (e) {
      emit(
          ShowSnackBarActionState(message: "Lỗi chọn ảnh: $e", success: false));
      DebugLogger.printLog(e.toString());
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

  FutureOr<void> _loadProvincesEvent(
      LoadProvincesEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    emit(LoadProvincesState(isLoadingProvinces: true));
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

        emit(StationCreate_ChangeState());
        emit(LoadProvincesState(
            isLoadingProvinces: false, provincesList: provincesList));
      } else {
        emit(StationCreate_ChangeState());
        emit(LoadProvincesState(isLoadingProvinces: false));
        DebugLogger.printLog("Lỗi tải Tỉnh/TP");
      }
    } catch (e) {
      emit(StationCreate_ChangeState());
      emit(LoadProvincesState(isLoadingProvinces: false));
      DebugLogger.printLog("Lỗi tải Tỉnh/TP: $e");
    }
  }

  FutureOr<void> _loadDistrictsEvent(
      LoadDistrictsEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    emit(LoadDistrictsState(isLoadingDistricts: true));
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

        emit(StationCreate_ChangeState());
        emit(LoadDistrictsState(
          isLoadingDistricts: false,
          districtList: districtsList,
          communeList: [],
          selectedCommuneCode: null,
          selectedDistrictCode: null,
        ));
      } else {
        emit(StationCreate_ChangeState());
        emit(LoadDistrictsState(
          isLoadingDistricts: false,
          districtList: [],
          communeList: [],
          selectedCommuneCode: null,
          selectedDistrictCode: null,
        ));
        DebugLogger.printLog("Lỗi tải Quận/Huyện");
      }
    } catch (e) {
      emit(StationCreate_ChangeState());
      emit(LoadDistrictsState(
        isLoadingDistricts: false,
        districtList: [],
        communeList: [],
        selectedCommuneCode: null,
        selectedDistrictCode: null,
      ));
      DebugLogger.printLog("Lỗi tải Quận/Huyện: $e");
    }
  }

  FutureOr<void> _loadCommunesEvent(
      LoadCommunesEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    emit(LoadCommunesState(isLoadingCommunes: true));
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

        emit(StationCreate_ChangeState());
        emit(LoadCommunesState(
          isLoadingCommunes: false,
          communeList: communesList,
          selectedCommuneCode: null,
        ));
      } else {
        emit(StationCreate_ChangeState());
        emit(LoadCommunesState(
          isLoadingCommunes: false,
          communeList: [],
          selectedCommuneCode: null,
        ));
        DebugLogger.printLog("Lỗi tải Quận/Huyện");
      }
    } catch (e) {
      emit(StationCreate_ChangeState());
      emit(LoadCommunesState(
        isLoadingCommunes: false,
        communeList: [],
        selectedCommuneCode: null,
      ));
      DebugLogger.printLog("Lỗi tải Quận/Huyện: $e");
    }
  }

  FutureOr<void> _selectedProvinceEvent(
      SelectedProvinceEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    emit(SelectedProvinceState(newValue: event.newValue));
  }

  FutureOr<void> _selectedDistrictEvent(
      SelectedDistrictEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    emit(SelectedDistrictState(newValue: event.newValue));
  }

  FutureOr<void> _selectedCommuneEvent(
      SelectedCommuneEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
    emit(SelectedCommuneState(newValue: event.newValue));
  }

  FutureOr<void> _updateFullAddressEvent(
      UpdateFullAddressEvent event, Emitter<StationCreateState> emit) async {
    emit(StationCreate_ChangeState());
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
      emit(UpdateFullAddressState(fullAddressController: fullAddress));
    } catch (e) {}
  }
}
