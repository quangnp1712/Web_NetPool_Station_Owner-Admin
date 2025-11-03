// Menu route render main body
import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/acc_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/2_Station_Management/station_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Dashboard/dashboard.dart';

PageRoute getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}

Route<dynamic> menuRoute(RouteSettings settings) {
  switch (settings.name) {
    case dashboardPageRoute:
      return getPageRoute(const DashboardPage());
    case accountListPageRoute:
      return getPageRoute(const AccountListPage());
    case stationPageRoute:
      return getPageRoute(const StationListPage());
    default:
      return getPageRoute(const DashboardPage());
  }
}
