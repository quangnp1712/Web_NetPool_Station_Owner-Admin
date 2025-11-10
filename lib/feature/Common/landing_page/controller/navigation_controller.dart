import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/router/menu_router.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Dashboard/dashboard.dart';

/// Controller này quản lý (State) của Local Navigator (Navigator lồng nhau).
/// Nó giữ GlobalKey để điều khiển Navigator đó từ bên ngoài (ví dụ: từ SideMenu).
class NavigationController extends GetxController {
  static NavigationController instance = Get.find();

  /// GlobalKey này được gán cho `localNavigator()` trong LandingPage
  /// để chúng ta có thể điều khiển nó.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Hàm này thực hiện 2 việc:
  /// 1. Cập nhật URL trên thanh địa chỉ của trình duyệt (dùng Get.offNamed).
  /// 2. Đẩy trang mới vào Local Navigator (dùng navigatorKey).
  Future<dynamic>? navigateAndSyncURL(String routeName) {
    // 1. Cập nhật URL của trình duyệt
    // Dùng offNamed (thay thế) thay vì toNamed (đẩy) để lịch sử trình duyệt sạch hơn
    Get.offNamed(routeName);

    // 2. Đẩy trang mới vào Navigator lồng nhau (main body)
    // Dùng pushNamed để thay đổi nội dung bên trong localNavigator
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  /// Chỉ "Back" bên trong Navigator lồng nhau.
  goBack() => navigatorKey.currentState?.pop();
}

NavigationController navigationController = NavigationController.instance;
Navigator localNavigator() => Navigator(
      key: navigationController.navigatorKey,
      onGenerateRoute: menuRoute,
      initialRoute: dashboardPageRoute,
    );
