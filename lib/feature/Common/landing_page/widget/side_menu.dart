import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/menu_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/widget/side_menu_item.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      color: AppColors.bgDark,
      child: Column(children: [
        if (ResponsiveWidget.isSmallScreen(context))
          Container(
            height: 80,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/logo_no_bg.png",
                    width: 270,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView(
            children: [
              //! Mục 1: Tổng quan (Không có con)
              SideMenuItem(
                itemName: dashboardPageName,
                icon: Icons.pie_chart, // Icon từ ảnh
                onTap: () {
                  if (!menuController.isActive(dashboardPageName)) {
                    menuController.changeActiveItemTo(dashboardPageName);
                    if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                    navigationController.navigateAndSyncURL(dashboardPageRoute);
                  }
                },
              ),

              //! Mục 2: Quản lý Tài khoản
              CustomExpansionItem(
                parentName: accountParentName,
                icon: Icons.person_outline,
                children: [
                  //$ 2.1 Danh sách tài khoản - con
                  SideMenuChildItem(
                    itemName: accountListPageName,
                    onTap: () {
                      if (!menuController.isActive(accountListPageName)) {
                        menuController.changeActiveItemTo(accountListPageName,
                            parentName: accountParentName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController
                            .navigateAndSyncURL(accountListPageRoute);
                      }
                    },
                  )
                ],
              ),

              //! Mục 3: Quản lý Station
              CustomExpansionItem(
                parentName: stationParentName,
                icon: Icons.store_outlined,
                children: [
                  //$ 3.1 Danh sách station - con
                  SideMenuChildItem(
                    itemName: stationListPageName,
                    onTap: () {
                      if (!menuController.isActive(stationListPageName)) {
                        menuController.changeActiveItemTo(stationListPageName,
                            parentName: stationParentName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController
                            .navigateAndSyncURL(stationListPageRoute);
                      }
                    },
                  ),

                  //$ 3.2 Tạo station - con
                  SideMenuChildItem(
                    itemName: stationCreatePageName,
                    onTap: () {
                      if (!menuController.isActive(stationCreatePageName)) {
                        menuController.changeActiveItemTo(stationCreatePageName,
                            parentName: stationParentName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController
                            .navigateAndSyncURL(stationCreatePageRoute);
                      }
                    },
                  ),

                  //$ 3.3 Câp nhập station - con
                  SideMenuChildItem(
                    itemName: stationUpdatePageName,
                    onTap: () {
                      if (!menuController.isActive(stationUpdatePageName)) {
                        menuController.changeActiveItemTo(stationUpdatePageName,
                            parentName: stationParentName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController
                            .navigateAndSyncURL(stationUpdatePageRoute);
                      }
                    },
                  ),
                ],
              ),

              //! Mục 4: Quản lý Loại hình
              CustomExpansionItem(
                parentName: spaceParentName,
                icon: Icons.category_outlined,
                children: [
                  SideMenuChildItem(
                      itemName: spaceListPageName,
                      onTap: () {
                        if (!menuController.isActive(spaceListPageName)) {
                          menuController.changeActiveItemTo(spaceListPageName,
                              parentName: spaceParentName);
                          if (ResponsiveWidget.isSmallScreen(context))
                            Get.back();
                          navigationController
                              .navigateAndSyncURL(spacePageRoute);
                        }
                      }),
                  SideMenuChildItem(
                      itemName: spaceCreatePageName,
                      onTap: () {
                        if (!menuController.isActive(spaceCreatePageName)) {
                          menuController.changeActiveItemTo(spaceCreatePageName,
                              parentName: spaceParentName);
                          if (ResponsiveWidget.isSmallScreen(context))
                            Get.back();
                          navigationController
                              .navigateAndSyncURL(spacePageRoute);
                        }
                      }),
                  SideMenuChildItem(
                      itemName: spaceUpdatePageName,
                      onTap: () {
                        if (!menuController.isActive(spaceUpdatePageName)) {
                          menuController.changeActiveItemTo(spaceUpdatePageName,
                              parentName: spaceParentName);
                          if (ResponsiveWidget.isSmallScreen(context))
                            Get.back();
                          navigationController
                              .navigateAndSyncURL(spacePageRoute);
                        }
                      }),
                ],
              ),

              //! TEST
              SideMenuItem(
                itemName: "TEST",
                icon: Icons.pie_chart, // Icon từ ảnh
                onTap: () {
                  if (!menuController.isActive("TEST")) {
                    menuController.changeActiveItemTo("TEST");
                    if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                    navigationController.navigateAndSyncURL(testRoute);
                  }
                },
              ),
            ],
          ),
        ),

        // MỤC ĐĂNG XUẤT (Ở DƯỚI CÙNG)
        Divider(color: Colors.grey[800]),
        SideMenuItem(
          itemName: logoutName,
          icon: Icons.logout, // Icon từ ảnh
          isLogout: true, // Flag để tô màu đỏ
          onTap: () {
            menuController.logout();
          },
        ),
      ]),
    );
  }
}
