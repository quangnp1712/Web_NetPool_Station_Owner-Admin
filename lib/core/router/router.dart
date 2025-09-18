import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/Usecase/1.2_Login/pages/login_page.dart';

class RouteGenerator {
  // final AuthenticationBloc authenticationBloc = AuthenticationBloc();

  List<GetPage> routes() {
    return [
      GetPage(
        name: LoginPage.LoginPageRoute,
        page: () => const LoginPage(),
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
