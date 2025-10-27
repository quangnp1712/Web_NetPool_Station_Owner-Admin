import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';

AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState> key) =>
    AppBar(
      toolbarHeight: 80.0,
      leadingWidth: !ResponsiveWidget.isSmallScreen(context) ? 300 : null,
      leading: Container(
        child: !ResponsiveWidget.isSmallScreen(context)
            ? Row(
                children: [
                  Center(
                    child: Image.asset(
                      "assets/images/logo_no_bg.png",
                      width: 270,
                    ),
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  key.currentState?.openDrawer();
                }),
      ),
      title: Row(
        children: [
          Expanded(
            child: Container(),
          ),
          Stack(
            children: [
              IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: AppColors.bgLight.withOpacity(.7),
                  ),
                  onPressed: () {}),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 12,
                  height: 12,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.menuDisable,
                  ),
                ),
              )
            ],
          ),
          Container(
            width: 1,
            height: 22,
            color: lightGrey,
          ),
          const SizedBox(
            width: 24,
          ),
          Container(
            decoration: BoxDecoration(
                color: active.withOpacity(.5),
                borderRadius: BorderRadius.circular(30)),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.all(2),
              child: const CircleAvatar(
                backgroundColor: light,
                child: Icon(
                  Icons.person_outline,
                  color: dark,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            "Santos Enoque",
            style: TextStyle(color: lightGrey, fontFamily: 'SegoeUI'),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: dark),
      elevation: 0,
      backgroundColor: AppColors.bgDark,
    );
