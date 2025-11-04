import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/menu_controller.dart';

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
            child: Obx(
              () {
                // 1. Lấy giá trị .value từ controller
                final String parent = menuController.activeParent.value;
                final String child = menuController.activeItem.value;

                // 2. Xây dựng chuỗi breadcrumb
                String breadcrumbText;
                if (parent.isEmpty) {
                  breadcrumbText = child; // vd: "Tổng quan"
                } else {
                  // vd: "Quản lý Tài khoản / Danh sách tài khoản"
                  breadcrumbText = "$parent / $child";
                }

                // 3. Hiển thị Text với nội dung động
                return Container(
                  color: AppColors.bgDark,
                  // Thêm padding cho đẹp (giống hình)
                  // margin:
                  //     EdgeInsets.only(top: 40, left: 24, bottom: 20),
                  child: Text(
                    breadcrumbText, // <-- SỬA Ở ĐÂY
                    style: const TextStyle(
                      color: AppColors.bgLight,
                      fontSize: 22,
                      fontFamily: 'SegoeUI Italic Bold',
                    ),
                  ),
                );
              },
            ),
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

          //$ USER
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
