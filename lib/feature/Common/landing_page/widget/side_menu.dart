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
      child: Column(
        children: [
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
                      navigationController.navigateTo(dashboardPageRoute);
                    }
                  },
                ),

                // Mục 2: Quản lý Tài khoản (Có con)
                // Sử dụng Widget CustomExpansionItem mới
                CustomExpansionItem(
                  parentName: "Quản lý Tài khoản Người chơi",
                  icon: Icons.person_outline, // Icon từ ảnh
                  children: [
                    SideMenuChildItem(
                      // Widget mới cho mục con
                      itemName: "Danh sách tài khoản",
                      onTap: () {
                        if (!menuController.isActive(accountListPageName)) {
                          menuController.changeActiveItemTo(
                              "Danh sách tài khoản",
                              parentName: "Quản lý Tài khoản Người chơi");
                          if (ResponsiveWidget.isSmallScreen(context))
                            Get.back();
                          navigationController.navigateTo(accountListPageRoute);
                        }
                      },
                    )
                  ],
                ),

                // Mục 3: Quản lý Station
                CustomExpansionItem(
                  parentName: "Quản lý Station",
                  icon: Icons.store_outlined,
                  children: [
                    SideMenuChildItem(
                      itemName: "Danh sách Station",
                      onTap: () {
                        menuController.changeActiveItemTo("Danh sách Station",
                            parentName: "Quản lý Station");
                      },
                    ),
                    SideMenuChildItem(
                      itemName: "Tạo Station",
                      onTap: () {
                        menuController.changeActiveItemTo("Tạo Station",
                            parentName: "Quản lý Station");
                      },
                    ),
                    SideMenuChildItem(
                      itemName: "Cập nhật Station",
                      onTap: () {
                        menuController.changeActiveItemTo("Cập nhật Station",
                            parentName: "Quản lý Station");
                      },
                    ),
                  ],
                ),

                // Mục 4: Quản lý Loại hình
                CustomExpansionItem(
                  parentName: "Quản lý Loại hình",
                  icon: Icons.category_outlined,
                  children: [
                    SideMenuChildItem(
                        itemName: "Danh sách Loại hình",
                        onTap: () {
                          menuController.changeActiveItemTo(
                              "Danh sách Loại hình",
                              parentName: "Quản lý Loại hình");
                        }),
                    SideMenuChildItem(
                        itemName: "Tạo Loại hình",
                        onTap: () {
                          menuController.changeActiveItemTo("Tạo Loại hình",
                              parentName: "Quản lý Loại hình");
                        }),
                    SideMenuChildItem(
                        itemName: "Cập nhật Station - Loại hình",
                        onTap: () {
                          menuController.changeActiveItemTo(
                              "Cập nhật Station - Loại hình",
                              parentName: "Quản lý Loại hình");
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
        ],
      ),
    );
  }
}
