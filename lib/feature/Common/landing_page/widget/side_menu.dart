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
              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: sideMenuItemRoutes
              //       .map((item) => SideMenuItem(
              //           itemName: item.name,
              //           onTap: () {
              //             if (!menuController.isActive(item.name)) {
              //               menuController.changeActiveItemTo(item.name);
              //               if (ResponsiveWidget.isSmallScreen(context)) {
              //                 Get.back();
              //               }
              //               navigationController.navigateTo(item.route);
              //             }
              //           }))
              //       .toList(),
              // )

              // Mục 1: Tổng quan (Không có con)
              // Sử dụng Widget SideMenuItem đã sửa đổi
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

              // Mục 2: Quản lý Tài khoản (Có con)
              // Sử dụng Widget CustomExpansionItem mới
              CustomExpansionItem(
                parentName: accountParentName, // Dùng hằng số
                icon: Icons.person_outline,
                children: [
                  SideMenuChildItem(
                    itemName: accountListPageName, // Dùng hằng số
                    onTap: () {
                      if (!menuController.isActive(accountListPageName)) {
                        menuController.changeActiveItemTo(
                            accountListPageName, // Dùng hằng số
                            parentName: accountParentName // Dùng hằng số
                            );
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController
                            .navigateAndSyncURL(accountListPageRoute);
                      }
                    },
                  )
                ],
              ),

              // Mục 3: Quản lý Station
              CustomExpansionItem(
                parentName: stationParentName, // Dùng hằng số
                icon: Icons.store_outlined,
                children: [
                  SideMenuChildItem(
                    itemName: stationListPageName, // Dùng hằng số
                    onTap: () {
                      if (!menuController.isActive(stationListPageName)) {
                        menuController.changeActiveItemTo(stationListPageName,
                            parentName: stationParentName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController
                            .navigateAndSyncURL(stationPageRoute);
                      }
                    },
                  ),
                  SideMenuChildItem(
                    itemName: stationCreatePageName, // Dùng hằng số
                    onTap: () {
                      if (!menuController.isActive(stationCreatePageName)) {
                        menuController.changeActiveItemTo(stationCreatePageName,
                            parentName: stationParentName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController
                            .navigateAndSyncURL(stationPageRoute);
                      }
                    },
                  ),
                  SideMenuChildItem(
                    itemName: stationUpdatePageName, // Dùng hằng số
                    onTap: () {
                      if (!menuController.isActive(stationUpdatePageName)) {
                        menuController.changeActiveItemTo(stationUpdatePageName,
                            parentName: stationParentName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController
                            .navigateAndSyncURL(stationPageRoute);
                      }
                    },
                  ),
                ],
              ),

              // Mục 4: Quản lý Loại hình
              CustomExpansionItem(
                parentName: spaceParentName, // Dùng hằng số
                icon: Icons.category_outlined,
                children: [
                  SideMenuChildItem(
                      itemName: spaceListPageName, // Dùng hằng số
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
                      itemName: spaceCreatePageName, // Dùng hằng số
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
                      itemName: spaceUpdatePageName, // Dùng hằng số
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
            // ... Xử lý Đăng xuất ...
          },
        ),
      ]),
    );
  }
}
