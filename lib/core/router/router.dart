import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/bloc/login_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/bloc/register_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/bloc/valid_email_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/pages/send_verify_page.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/pages/verify_email_page.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Player_Management/1.1_Account_List/bloc/account_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Player_Management/1.1_Account_List/pages/account_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/home_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/landing_page.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/pages/register_page.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/pages/login_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Dashboard/dashboard.dart';

class RouteGenerator {
  final LoginBloc loginPageBloc = LoginBloc();
  final RegisterBloc registerPageBloc = RegisterBloc();
  final ValidEmailBloc validEmailPageBloc = ValidEmailBloc();
  final AccountListBloc accountListBloc = AccountListBloc();

  List<GetPage> routes() {
    return [
      GetPage(
        name: loginPageRoute,
        page: () => BlocProvider<LoginBloc>.value(
            value: loginPageBloc, child: LoginPage()),
      ),

      GetPage(
        name: registerPageRoute,
        page: () => BlocProvider<RegisterBloc>.value(
            value: registerPageBloc, child: RegisterPage()),
      ),

      GetPage(
        name: validEmailPageRoute,
        page: () => BlocProvider<ValidEmailBloc>.value(
            value: validEmailPageBloc, child: ValidEmailPage()),
      ),
      GetPage(
        name: sendValidCodePageRoute,
        page: () => BlocProvider<ValidEmailBloc>.value(
            value: validEmailPageBloc, child: SendValidPage()),
      ),
      GetPage(
        name: HomePage.HomePageRoute,
        page: () => const HomePage(),
      ),

      // MENU //
      // rootRoute ("/") sẽ tự động chuyển hướng đến dashboard

      GetPage(
        name: rootRoute, // "/"
        page: () => LandingPage(),
      ),
    ];
  }
}
