// Menu route render main body
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/bloc/station_resource_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/pages/resoucre_page.dart';
import 'package:web_netpool_station_owner_admin/feature/12_Schedule_Timeslot_Management/schedule_timeslot.dart';
import 'package:web_netpool_station_owner_admin/feature/2_Payment_Managemment/dashboard_payment.dart';
import 'package:web_netpool_station_owner_admin/feature/3_Booking_Management/dashboard_booking.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/bloc/station_detail_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/pages/station_detail_page.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/bloc/admin_detail_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/pages/admin_detail_page.dart';
import 'package:web_netpool_station_owner_admin/feature/7_Account_Player_Management/7.1_Account_List/bloc/account_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/7_Account_Player_Management/7.1_Account_List/pages/account_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/bloc/station_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/pages/station_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.2_Staion_Create/bloc/station_create_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.2_Staion_Create/pages/station_create_page.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/bloc/admin_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/pages/admin_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/bloc/admin_create_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/pages/admin_create_page.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Dashboard/dashboard.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/bloc/space_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/pages/space_page.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/bloc/area_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/pages/area_list_page.dart';

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
    case stationDetailPageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<StationDetailBloc>.value(
            value: BlocProvider.of<StationDetailBloc>(context),
            child: StationDetailPage(),
          );
        },
      );

    //! QUẢN LÝ STATION ADMIN $//
    case adminListPageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<AdminListBloc>.value(
            value: BlocProvider.of<AdminListBloc>(context),
            child: const AdminListPage(),
          );
        },
      );
    case adminCreatePageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<AdminCreateBloc>.value(
            value: BlocProvider.of<AdminCreateBloc>(context),
            child: const AdminCreatePage(),
          );
        },
      );
    case adminUpdatePageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<AdminDetailBloc>.value(
            value: BlocProvider.of<AdminDetailBloc>(context),
            child: const AdminDetailPage(),
          );
        },
      );

    //! QUẢN LÝ SPACE $//
    case spacePageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<SpaceBloc>.value(
            value: BlocProvider.of<SpaceBloc>(context),
            child: const StationSpacePage(),
          );
        },
      );

    //! QUẢN LÝ AREA $//
    case areaPageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<AreaListBloc>.value(
            value: BlocProvider.of<AreaListBloc>(context),
            child: const AreaListPage(),
          );
        },
      );

    //! QUẢN LÝ RESOUCRE  $//
    case resourcePageRoute:
      return MaterialPageRoute(
        builder: (context) {
          return BlocProvider<StationResourceBloc>.value(
            value: BlocProvider.of<StationResourceBloc>(context),
            child: const StationResourcePage(),
          );
        },
      );

    //! QUẢN LÝ LỊCH + TIMESLOT $//
    case schedulePageRoute:
      return getPageRoute(const ScheduleManagerPage());

    //! QUẢN LÝ thanh toán $//
    case paymentOverviewPageRoute:
      return getPageRoute(const StationPaymentOverviewPage());

    //! QUẢN LÝ đặt lịch $//
    case bookingOverviewPageRoute:
      return getPageRoute(const StationBookingOverviewPage());

    //! TEST $//
    // case testRoute:
    //   return getPageRoute(const TestPage());

    default:
      return getPageRoute(const DashboardPage());
  }
}
