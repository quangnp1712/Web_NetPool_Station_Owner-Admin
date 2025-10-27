import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/acc_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/2_Station_Management/station_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Dashboard/dashboard.dart';

NavigationController navigationController = NavigationController.instance;

class NavigationController extends GetxController {
  static NavigationController instance = Get.find();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  goBack() => navigatorKey.currentState?.pop();
}

Navigator localNavigator() => Navigator(
      key: navigationController.navigatorKey,
      onGenerateRoute: menuRoute,
      initialRoute: dashboardPageRoute,
    );

Route<dynamic> menuRoute(RouteSettings settings) {
  switch (settings.name) {
    case dashboardPageRoute:
      return _getPageRoute(const DashboardPage());
    case accountListPageRoute:
      return _getPageRoute(const AccountListPage());
    case stationPageRoute:
      return _getPageRoute(const StationListPage());
    default:
      return _getPageRoute(const DashboardPage());
  }
}

PageRoute _getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}
