// Menu route render main body
import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/pages/account_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/pages/test.dart';
import 'package:web_netpool_station_owner_admin/feature/2_Station_Management/station_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Dashboard/dashboard.dart';

PageRoute getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}

Route<dynamic> menuRoute(RouteSettings settings) {
  switch (settings.name) {
    //! DASHBOARD $//
    case dashboardPageRoute:
      return getPageRoute(const DashboardPage());

    //! QUẢN LÝ NGƯỜI CHƠI $//
    case accountListPageRoute:
      return getPageRoute(const AccountListPage());

    //! QUẢN LÝ STATION $//
    case stationListPageRoute:
      return getPageRoute(const StationListPage());
    case stationCreatePageRoute:
      return getPageRoute(const StationListPage());
    case stationUpdatePageRoute:
      return getPageRoute(const StationListPage());

    //! TEST $//
    case testRoute:
      return getPageRoute(const TestPage());

    default:
      return getPageRoute(const DashboardPage());
  }
}
