import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/account_info_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_stations_model.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/repository/authentication_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/shared_preferences/landing_page_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/data/role/models/role_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/data/role/repository/role_repository.dart';

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
  var activeAdminId = Rxn<String>();
  var activePlayerId = Rxn<String>();
  // SỬA: stationId là String
  // ------------------------------------

  @override
  void onInit() {
    super.onInit();
    // onInit() được gọi 1 lần duy nhất khi controller được put()
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      List<AuthStationsModel> _stations = [];

      // 1. Tải dữ liệu
      final String roleCode = AuthenticationPref.getRoleCode();
      final user = AuthenticationPref.getUsername();
      final int accountId = AuthenticationPref.getAcountId();

      // 2. Tải Tên Role (Bất đồng bộ)
      final roleNameResult = await _getRole(roleCode);

      // 3. Tải TOÀN BỘ danh sách Station (Master List)
      final stationsResult =
          await AuthenticationRepository().listStationStationOwner(accountId);
      var responseMessage = stationsResult['message'];
      var responseStatus = stationsResult['status'];
      var responseSuccess = stationsResult['success'];
      var responseBody = stationsResult['body'];

      // 4. Xử lý kết quả Station
      if (responseSuccess) {
        AccountInfoModelResponse stationResponse =
            AccountInfoModelResponse.fromJson(stationsResult['body']);

        if (stationResponse.data != null) {
          if (stationResponse.data!.stations != null) {
            for (var station in stationResponse.data!.stations!) {
              // Decode UTF-8
              station.stationName =
                  Utf8Encoding().decode(station.stationName ?? "");
            }
          }
        }
        _stations = stationResponse.data!.stations ?? [];
        // _stations = _stations.where((station) {
        //   return station.stationCode == "ACTIVE";
        // }).toList();
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
      // 2. Cập nhật state
      roleName.value = roleNameResult;
      username.value = user;
      stationList.value = _stations; // Lấy từ constructor

      if (roleCode == "STATION_ADMIN" && stationList.isNotEmpty) {
        activeStationId.value = stationList[0].stationId;
      }
      if (roleCode == "STATION_OWNER" && stationList.length == 1) {
        activeStationId.value = stationList[0].stationId;
        AuthenticationPref.setStationId(activeStationId.value ?? "");
      }
      try {
        List<String>? stationJsonList =
            _stations.map((s) => s.toJson()).toList();

        AuthenticationPref.setStationsJson(stationJsonList.toList());
      } catch (e) {
        AuthenticationPref.setStationsJson([]);
        DebugLogger.printLog("Lỗi: $e");
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
  Future<String> _getRole(String roleCodeAuthPref) async {
    try {
      var results = await RoleRepository().roles();
      var responseSuccess = results['success'];
      var responseBody = results['body'];
      if (responseSuccess) {
        RoleModelResponse roleModelResponse =
            RoleModelResponse.fromJson(responseBody);

        if (roleModelResponse.data != null) {
          for (var dataRole in roleModelResponse.data!) {
            if (dataRole.roleCode == roleCodeAuthPref) {
              return Utf8Encoding().decode(dataRole.roleName ?? "");
            }
          }
        }
      }
      return roleCodeAuthPref;
    } catch (e) {
      DebugLogger.printLog(e.toString());
      return roleCodeAuthPref;
    }
  }

  // ---  Hàm thay đổi Station (dùng String) ---
  void changeActiveStation(String? newStationId) {
    //
    if (activeStationId.value != newStationId) {
      activeStationId.value = newStationId!;
      // (Lưu ID mới này vào SharedPreferences nếu bạn muốn)
      LandingPageSharedPref.setActiveStation(newStationId);
    }
  }

  // --------------------------------
  // ---  Hàm thay đổi Admin (dùng String) ---
  // void changeActiveAdmin(String? newAdminId) {
  //   //
  //   if (activeAdminId.value != newAdminId) {
  //     activeAdminId.value = newAdminId!;
  //   }
  // }

  // // --------------------------------
  // // ---  Hàm thay đổi Player (dùng String) ---
  // void changeActivePlayer(String? newPlayerId) {
  //   //
  //   if (activePlayerId.value != newPlayerId) {
  //     activePlayerId.value = newPlayerId!;
  //     // (Lưu ID mới này vào SharedPreferences nếu bạn muốn)
  //   }
  // }
  // // --------------------------------
}
