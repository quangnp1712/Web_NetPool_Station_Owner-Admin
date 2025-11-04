// Menu route render main body
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/bloc/account_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/pages/account_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/pages/test.dart';
import 'package:web_netpool_station_owner_admin/feature/2_Station_Management/station_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Dashboard/dashboard.dart';

PageRoute getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}

Route<dynamic> menuRoute(RouteSettings settings) {
  final AccountListBloc accountListBloc = AccountListBloc();

  switch (settings.name) {
    //! DASHBOARD $//
    case dashboardPageRoute:
      return getPageRoute(const DashboardPage());

    //! QUẢN LÝ NGƯỜI CHƠI $//
    case accountListPageRoute:
      return MaterialPageRoute(
        builder: (context) {
          // 'context' ở đây là context của localNavigator,
          // nó có thể tìm thấy BLoC đã được cung cấp ở main.dart
          return BlocProvider<AccountListBloc>.value(
            // Lấy BLoC instance đã tồn tại
            value: accountListBloc,
            // Cung cấp nó cho trang con
            child: const AccountListPage(),
          );
        },
      );

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
