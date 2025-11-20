import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart'
    as getXTransition;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_netpool_station_owner_admin/core/router/router.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/shared_preferences_helper.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/bloc/register_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/shared_preferences/register_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/bloc/valid_email_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/shared_preferences/verify_email_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/7_Account_Player_Management/7.1_Account_List/bloc/account_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/bloc/station_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.2_Staion_Create/bloc/station_create_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/bloc/admin_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/bloc/admin_create_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/404/error.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.2_Login/bloc/login_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/menu_controller.dart'
    as menu_controller;
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SharedPreferencesHelper.instance.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    if (kIsWeb) {
      // Chạy trên Web
      await FirebaseAppCheck.instance.activate(
        // Cung cấp reCAPTCHA v3 site key của bạn ở đây
        // Bạn phải lấy key này từ Google Cloud Console (reCAPTCHA v3)
        webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_V3_SITE_KEY_HERE'),
      );
    } else {
      // Chạy trên Android/iOS
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest, // (Nên thêm cho iOS)
      );
    }
  } catch (e) {
    print('Lỗi Firebase App Check: $e');
  }
  _FBSignAnonymous();
  Get.put(menu_controller.MenuController());
  Get.put(NavigationController());
  // SharedPreferencesHelper.clearAll();
  runApp(const MyApp());
}

Future<void> _FBSignAnonymous() async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    User? user = userCredential.user;
    print('Đăng nhập ẩn danh thành công: ${user!.uid}');
  } catch (e) {
    print('Lỗi không xác định: $e');
  }
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
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => ValidEmailBloc()),
        BlocProvider(create: (_) => AccountListBloc()),
        BlocProvider(create: (_) => AdminListBloc()),
        BlocProvider(create: (_) => AdminCreateBloc()),
        BlocProvider(create: (_) => StationListBloc()),
        BlocProvider(create: (_) => StationCreateBloc()),
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
          transition: getXTransition.Transition.fadeIn,
        ),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          textTheme: GoogleFonts.robotoTextTheme(),
        ),
        initialRoute: loginPageRoute,

        // --- XỬ LÝ KHI RỜI TRANG ---
        routingCallback: (routing) {
          // Định nghĩa các route thuộc luồng Đăng ký / Quên mật khẩu
          // (Đây là các route mà bạn *cần* giữ lại email)
          const authFlowRoutes = [
            validEmailPageRoute,
          ];

          final previousRoute = routing?.previous; // Route vừa rời đi
          final currentRoute = routing?.current; // Route sắp vào

          // KIỂM TRA: Nếu ta vừa rời (previous) 1 trang trong luồng auth
          // VÀ ta sắp vào (current) 1 trang KHÔNG NẰM trong luồng auth
          // (ví dụ: đi từ /register -> /login hoặc /dashboard)
          if (authFlowRoutes.contains(previousRoute)) {
            RegisterSharedPref.clearEmail();
            VerifyEmailPref.clearEmail();
            DebugLogger.printLog("xoa Pref");
          }
        },
      ),
    );
  }
}
