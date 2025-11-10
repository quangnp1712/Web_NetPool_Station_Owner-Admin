// ignore_for_file: unused_field

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/core/utils/utf8_encoding.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/shared_preferences/landing_page_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/widget/side_menu.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/widget/top_navigation_bar.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/models/role_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/role/repository/role_repository.dart';

class LandingPage extends StatefulWidget {
  LandingPage({super.key});
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserSessionController>()) {
      Get.put(UserSessionController());
    }
    final sessionController = Get.find<UserSessionController>();

    return Obx(() {
      return Stack(
        children: [
          Scaffold(
            key: widget.scaffoldKey,
            extendBodyBehindAppBar: true,
            appBar: topNavigationBar(
                context,
                widget.scaffoldKey,
                sessionController.roleName.value,
                sessionController.username.value),
            drawer: const Drawer(
              child: SideMenu(),
            ),
            body: ResponsiveWidget(
                //* Large Screen *//
                largeScreen: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //$ nav bar
                    Container(width: 280, child: SideMenu()),

                    //$ main body
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: AppColors.bgDark,
                        child: Container(
                          margin: EdgeInsets.only(top: 80),
                          decoration: BoxDecoration(
                            color: AppColors.bgDark,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: AppColors.primaryGlow, // MÀU VIỀN TRÊN
                                width: 1.0, // ĐỘ DÀY VIỀN
                              ),
                              left: BorderSide(
                                color: AppColors.primaryGlow, // MÀU VIỀN TRÁI
                                width: 1.0, // ĐỘ DÀY VIỀN
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                            ),
                            child: localNavigator(),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                smallScreen: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.primaryGlow, // MÀU VIỀN TRÊN
                        width: 1.0, // ĐỘ DÀY VIỀN
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                    ),
                    child: localNavigator(),
                  ),
                )),
          ),
          // --- WIDGET LOADING TRONG STACK ---
          if (sessionController.isLoading.value)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.containerBackground
                      .withOpacity(0.8), // Màu nền mờ
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryGlow),
                  ),
                ),
              ),
            ),
          // ------------------------------------
        ],
      );
    });
  }
}
