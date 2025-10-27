import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/widget/side_menu.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/widget/top_navigation_bar.dart';

class LandingPage extends StatefulWidget {
  LandingPage({super.key});
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: topNavigationBar(context, widget.scaffoldKey),
      drawer: const Drawer(
        child: SideMenu(),
      ),
      body: ResponsiveWidget(
          // Large Screen //
          largeScreen: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // nav bar
              Container(width: 280, child: SideMenu()),

              // main body
              Expanded(
                flex: 5,
                child: Container(
                  color: AppColors.bgDark,
                  child: localNavigator(),
                ),
              )
            ],
          ),
          smallScreen: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.blue,
            child: localNavigator(),
          )),
    );
  }
}
