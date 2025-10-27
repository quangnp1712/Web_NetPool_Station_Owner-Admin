import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart'
    as getXTransition;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_netpool_station_owner_admin/core/router/router.dart';
import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/404/error.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/Usecase/1.2_Login/bloc/login_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/Usecase/1.2_Login/pages/login_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/menu_controller.dart'
    as menu_controller;
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/navigation_controller.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SharedPreferencesHelper.instance.init();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.playIntegrity,
  // );
  // _FBSignAnonymous();
  Get.put(menu_controller.MenuController());
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc()),
      ],
      child: GetMaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi'),
        ],
        getPages: RouteGenerator().routes(),
        unknownRoute: GetPage(
            name: '/not-found',
            page: () => const PageNotFound(),
            transition: getXTransition.Transition.fadeIn),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
        ),
        initialRoute: LoginPage.LoginPageRoute,
      ),
    );
  }
}
