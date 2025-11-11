// Menu route render main body
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Player_Management/1.1_Account_List/bloc/account_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Player_Management/1.1_Account_List/pages/account_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.1_Station_List/bloc/station_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.1_Station_List/pages/station_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.2_Staion_Create/bloc/station_create_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/4_Station_Management/4.2_Staion_Create/pages/station_create_page.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.1_Account_Admin_List/bloc/admin_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.1_Account_Admin_List/pages/admin_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.2_Account_Admin_Create/bloc/admin_create_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.2_Account_Admin_Create/pages/admin_create_page.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Dashboard/dashboard.dart';

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
      return MaterialPageRoute(
        builder: (context) {
          // 'context' ở đây là context của localNavigator,
          // nó có thể tìm thấy BLoC đã được cung cấp ở main.dart
          return BlocProvider<AccountListBloc>.value(
            // Lấy BLoC instance đã tồn tại
            value: BlocProvider.of<AccountListBloc>(context),
            // Cung cấp nó cho trang con
            child: const AccountListPage(),
          );
        },
      );

    //! QUẢN LÝ STATION $//
    case stationListPageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<StationListBloc>.value(
            value: BlocProvider.of<StationListBloc>(context),
            child: const StationListPage(),
          );
        },
      );
    case stationCreatePageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<StationCreateBloc>.value(
            value: BlocProvider.of<StationCreateBloc>(context),
            child: const StationCreatePage(),
          );
        },
      );
    case stationUpdatePageRoute:
      return getPageRoute(const AdminCreatePage());

    //! QUẢN LÝ STATION ADMIN $//
    case adminListPageRoute:
      return MaterialPageRoute(
        builder: (context) {
          // 'context' ở đây là context của localNavigator,
          // nó có thể tìm thấy BLoC đã được cung cấp ở main.dart
          return BlocProvider<AdminListBloc>.value(
            // Lấy BLoC instance đã tồn tại
            value: BlocProvider.of<AdminListBloc>(context),
            // Cung cấp nó cho trang con
            child: const AdminListPage(),
          );
        },
      );
    case adminCreatePageRoute:
      return MaterialPageRoute(
        builder: (context) {
          // 'context' ở đây là context của localNavigator,
          // nó có thể tìm thấy BLoC đã được cung cấp ở main.dart
          return BlocProvider<AdminCreateBloc>.value(
            // Lấy BLoC instance đã tồn tại
            value: BlocProvider.of<AdminCreateBloc>(context),
            // Cung cấp nó cho trang con
            child: const AdminCreatePage(),
          );
        },
      );

    //! TEST $//
    // case testRoute:
    //   return getPageRoute(const TestPage());

    default:
      return getPageRoute(const DashboardPage());
  }
}
