import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/menu_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/widget/top_nav_selector_station.dart';

AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState> key,
        String? _roleName, String? _username, String avatarUrl) =>
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
                    style: TextStyle(
                      color: AppColors.bgLight,
                      fontSize: 22,
                      fontFamily: 'SegoeUI Italic Bold',
                    ),
                  ),
                );
              },
            ),
          ),
          Spacer(),
          StationSelectorDropdown(),
          const SizedBox(width: 16),

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
              child: CircleAvatar(
                backgroundColor: light,
                // 1. Nếu có URL thì hiển thị ảnh nền, ngược lại thì null
                backgroundImage:
                    (avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                // 2. Nếu KHÔNG có URL thì hiển thị Icon, nếu có ảnh rồi thì null (để không bị đè lên ảnh)
                child: (avatarUrl.isEmpty)
                    ? const Icon(
                        Icons.person_outline,
                        color: dark,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                _username ?? "",
                style: TextStyle(
                    color: AppColors.textWhite,
                    fontFamily: 'SegoeUI',
                    fontSize: 18),
              ),
              Text(
                _roleName ?? "",
                style: TextStyle(
                    color: AppColors.textHint,
                    fontFamily: 'SegoeUI',
                    fontSize: 14),
              ),
            ],
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: dark),
      elevation: 0,
      backgroundColor: AppColors.bgDark,
    );
