import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/bloc/login_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/bloc/register_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/bloc/valid_email_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/pages/send_verify_page.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/pages/verify_email_page.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/acc_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/2_Station_Management/station_list_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/home_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/landing_page.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/pages/register_page.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/pages/login_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Dashboard/dashboard.dart';

class RouteGenerator {
  final LoginBloc loginPageBloc = LoginBloc();
  final RegisterBloc registerPageBloc = RegisterBloc();
  final ValidEmailBloc validEmailPageBloc = ValidEmailBloc();

  List<GetPage> routes() {
    return [
      GetPage(
        name: loginPageRoute,
        page: () => BlocProvider<LoginBloc>.value(
            value: loginPageBloc, child: LoginPage()),
      ),
      // GetPage(
      //   name: loginPageRoute,
      //   page: () => LoginPage(),
      // ),

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
        page: () => LandingPage(), // Chỉ render LandingPage (layout) 1 LẦN
        // Định nghĩa các trang con sẽ được render BÊN TRONG LandingPage
        // children: [
        //   GetPage(
        //     name: dashboardPageRoute, // "/dashboard"
        //     page: () => const DashboardPage(), // Chỉ render trang con
        //   ),
        //   GetPage(
        //     name: accountListPageRoute,
        //     page: () => const AccountListPage(),
        //   ),
        //   GetPage(
        //     name: stationPageRoute,
        //     page: () => const StationListPage(),
        //   ),
        // ],
      ),

      // GetPage(
      //   name: LandingNavBottomWidget.LandingNavBottomWidgetRoute,
      //   page: () => BlocProvider<LandingNavigationBottomBloc>.value(
      //       value: landingNavigationBottomBloc,
      //       child: const LandingNavBottomWidget()),
      // ),
      // GetPage(
      //   name: AuthenticationPage.AuthenticationPageRoute,
      //   page: () => BlocProvider<AuthenticationBloc>.value(
      //       value: authenticationBloc, child: AuthenticationPage()),
      // ),
      // GetPage(
      //   name: ProfilePage.ProfilePageRoute,
      //   page: () => BlocProvider<ProfilePageBloc>.value(
      //       value: profilePageBloc, child: const ProfilePage()),
      // ),
      // GetPage(
      //   name: ChangePassPage.ChangePassPageRoute,
      //   page: () => BlocProvider<ChangePassPageBloc>.value(
      //       value: changePassPageBloc, child: const ChangePassPage()),
      // ),
      // GetPage(
      //   name: ChangeEmailPage.ChangeEmailPageRoute,
      //   page: () => BlocProvider<ChangeEmailPageBloc>.value(
      //       value: changeEmailPageBloc, child: const ChangeEmailPage()),
      // ),
      // GetPage(
      //   name: ShelterPage.ShelterPageRoute,
      //   page: () {
      //     callback(int index) {} // Hàm callback rỗng hoặc hàm cụ thể của bạn
      //     return BlocProvider<ShelterPageBloc>.value(
      //         value: shelterPageBloc, child: ShelterPage(callback));
      //   },
      // ),
      // GetPage(
      //   name: HomePage.HomePageRoute,
      //   page: () {
      //     callback(int index) {} // Hàm callback rỗng hoặc hàm cụ thể của bạn
      //     return BlocProvider<HomePageBloc>.value(
      //         value: homePageBloc, child: HomePage(callback));
      //   },
      // ),
      // GetPage(
      //   name: MenuPage.MenuPageRoute,
      //   page: () {
      //     callback(int index) {} // Hàm callback rỗng hoặc hàm cụ thể của bạn
      //     return BlocProvider<MenuPageBloc>.value(
      //         value: menuPageBloc, child: MenuPage(callback));
      //   },
      // ),
      // GetPage(
      //   name: ShelterDetailPage.ShelterDetailPageRoute,
      //   page: () {
      //     final shelterPageBloc =
      //         BlocProvider.of<ShelterPageBloc>(Get.context!);
      //     final ShelterModel shelter = ShelterModel();
      //     return ShelterDetailPage(bloc: shelterPageBloc, shelter: shelter);
      //   },
      // ),
    ];
  }
}
