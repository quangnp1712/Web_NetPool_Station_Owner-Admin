import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/shared_preferences/landing_page_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/models/role_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/repository/role_repository.dart';

class UserSessionController extends GetxController {
  UserSessionController();
  // Biến state (dùng .obs để UI có thể lắng nghe)
  var isLoading = true.obs;
  var roleName = "".obs;
  var username = "".obs;

  // --- SỬA: State cho Bộ chọn Station ---
  // (Giờ đây dùng StationInfoModel từ login_data_model.dart)
  var stationList = <AuthStationsModel>[].obs;
  var activeStationId = Rxn<String>();
  // SỬA: stationId là String
  // ------------------------------------

  @override
  void onInit() {
    super.onInit();
    // onInit() được gọi 1 lần duy nhất khi controller được put()
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1. Tải dữ liệu
      final role = await _getRole();
      final user = AuthenticationPref.getEmail();
      final String roleCode = AuthenticationPref.getRoleCode();
      final List<String> stationJsonList = AuthenticationPref.getStationsJson();

// 3. Parse (phân tích) danh sách Station từ JSON
      List<AuthStationsModel> stations = stationJsonList
          .map((jsonString) =>
              AuthStationsModel.fromJson(jsonDecode(jsonString)))
          .toList();

      // 2. Cập nhật state
      roleName.value = role;
      username.value = user;
      stationList.value = stations; // Lấy từ constructor

      if (roleCode == "STATION_ADMIN" && stationList.isNotEmpty) {
        activeStationId.value = stationList[0].stationId;
      }
    } catch (e) {
      DebugLogger.printLog("Lỗi tải UserSession: $e");
      // (Xử lý lỗi)
    } finally {
      // 3. Tắt loading
      isLoading.value = false;
    }
  }

  // (Hàm _getRole của bạn, được chuyển từ LandingPage vào đây)
  Future<String> _getRole() async {
    try {
      var results = await RoleRepository().roles();
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        RoleModelResponse roleModelResponse =
            RoleModelResponse.fromJson(responseBody);
        String roleCodeAuthPref = AuthenticationPref.getRoleCode();
        if (roleModelResponse.data != null) {
          for (var dataRole in roleModelResponse.data!) {
            if (dataRole.roleCode == roleCodeAuthPref) {
              return Utf8Encoding().decode(dataRole.roleName ?? "");
            }
          }
        }
      }
      return "";
    } catch (e) {
      DebugLogger.printLog(e.toString());
      return "";
    }
  }

  // --- SỬA: Hàm thay đổi Station (dùng String) ---
  void changeActiveStation(String? newStationId) {
    // SỬA: Dùng String?
    if (activeStationId.value != newStationId) {
      activeStationId.value = newStationId!;
      // (Lưu ID mới này vào SharedPreferences nếu bạn muốn)
      // LandingPageSharedPref.setActiveStation(newStationId);
    }
  }
  // --------------------------------
}
