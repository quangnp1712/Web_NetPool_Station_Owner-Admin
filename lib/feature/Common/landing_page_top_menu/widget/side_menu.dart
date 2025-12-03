import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/shared_preferences/admin_detail_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/menu_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/widget/side_menu_item.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    // 1. Lấy role code của người dùng (giả sử là "STATION_OWNER" hoặc "STATION_ADMIN")
    final String userRole = AuthenticationPref.getRoleCode();

    // 2. Tạo biến bool helper
    final bool isOwner = (userRole == "STATION_OWNER");

    // 1. Lấy controller
    final sessionController = Get.find<UserSessionController>();

    return Obx(() {
      final bool isStationSelected;
      if (sessionController.activeStationId.value != null) {
        isStationSelected = true;
      } else {
        isStationSelected = false;
      }

      // final bool isPlayerSelected;
      // if (sessionController.activePlayerId.value != null) {
      //   isPlayerSelected = true;
      // } else {
      //   isPlayerSelected = false;
      // }
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
                //! Mục 1: Tổng quan (Không có con) (Cả 2 đều thấy) ---
                SideMenuItem(
                  itemName: dashboardPageName,
                  icon: Icons.pie_chart, // Icon từ ảnh
                  onTap: () {
                    if (!menuController.isActive(dashboardPageName)) {
                      menuController.changeActiveItemTo(dashboardPageName);
                      if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                      navigationController
                          .navigateAndSyncURL(dashboardPageRoute);
                    }
                  },
                ),

                //! Mục 2: QL GIAO DỊCH (Cả 2 đều thấy) ---
                CustomExpansionItem(
                  parentName: paymentParentName,
                  icon: Icons.attach_money_outlined,
                  children: [
                    //$ 2.1 Tổng quan - con
                    SideMenuChildItem(
                      itemName: paymentOverviewPageName,
                      onTap: () {
                        if (!menuController.isActive(paymentOverviewPageName)) {
                          menuController.changeActiveItemTo(
                              paymentOverviewPageName,
                              parentName: paymentParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(paymentOverviewPageRoute);
                        }
                      },
                    ),
                    //$ 2.2 Lịch sử Giao dịch - con
                    SideMenuChildItem(
                      itemName: paymentHistoryPageName,
                      onTap: () {
                        if (!menuController.isActive(paymentHistoryPageName)) {
                          menuController.changeActiveItemTo(
                              paymentHistoryPageName,
                              parentName: paymentParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(paymentHistoryPageRoute);
                        }
                      },
                    ),
                  ],
                ),

                //! Mục 3: QL ĐẶT LỊCH (Cả 2 đều thấy) ---
                CustomExpansionItem(
                  parentName: bookingParentName,
                  icon: Icons.calendar_today_outlined,
                  children: [
                    //$ 3.1 Tổng quan - con
                    SideMenuChildItem(
                      itemName: bookingOverviewPageName,
                      onTap: () {
                        if (!menuController.isActive(bookingOverviewPageName)) {
                          menuController.changeActiveItemTo(
                              bookingOverviewPageName,
                              parentName: bookingParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(bookingOverviewPageRoute);
                        }
                      },
                    ),
                    //$ 3.2 Lịch đặt - con
                    SideMenuChildItem(
                      itemName: bookingCalendarPageName,
                      onTap: () {
                        if (!menuController.isActive(bookingCalendarPageName)) {
                          menuController.changeActiveItemTo(
                              bookingCalendarPageName,
                              parentName: bookingParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(bookingCalendarPageRoute);
                        }
                      },
                    ),
                    //$ 3.3 Duyệt Đặt lịch - con
                    SideMenuChildItem(
                      itemName: bookingApprovePageName,
                      onTap: () {
                        if (!menuController.isActive(bookingApprovePageName)) {
                          menuController.changeActiveItemTo(
                              bookingApprovePageName,
                              parentName: bookingParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(bookingApprovePageRoute);
                        }
                      },
                    ),
                  ],
                ),

                //! Mục 4: QL GHÉP ĐỘI (Cả 2 đều thấy) ---
                CustomExpansionItem(
                  parentName: matchParentName,
                  icon: Icons.groups_outlined,
                  children: [
                    //$ 4.1 Danh sách Ghép đội - con
                    SideMenuChildItem(
                      itemName: matchListPageName,
                      onTap: () {
                        if (!menuController.isActive(matchListPageName)) {
                          menuController.changeActiveItemTo(matchListPageName,
                              parentName: matchParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(matchListPageRoute);
                        }
                      },
                    ),
                    //$ 4.2 Duyệt Ghép đội - con
                    SideMenuChildItem(
                      itemName: matchApprovePageName,
                      onTap: () {
                        if (!menuController.isActive(matchApprovePageName)) {
                          menuController.changeActiveItemTo(
                              matchApprovePageName,
                              parentName: matchParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(matchApprovePageRoute);
                        }
                      },
                    ),
                    //$ 4.3 Cập nhật Ghép đội - con
                    SideMenuChildItem(
                      itemName: matchUpdatePageName,
                      onTap: () {
                        if (!menuController.isActive(matchUpdatePageName)) {
                          menuController.changeActiveItemTo(matchUpdatePageName,
                              parentName: matchParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(matchUpdatePageRoute);
                        }
                      },
                    ),
                  ],
                ),

                //! ---  TIÊU ĐỀ PHÂN NHÓM ---
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 24, bottom: 8),
                  child: Text(
                    "QUẢN LÝ CÀI ĐẶT", // (Tên phân nhóm theo yêu cầu)
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                //! Mục 5: Quản lý Station (Owner mới thấy "Tạo") ---
                CustomExpansionItem(
                  parentName: stationParentName,
                  icon: Icons.store_outlined,
                  children: [
                    //$ 5.1 Danh sách station - con
                    SideMenuChildItem(
                      itemName: stationListPageName,
                      onTap: () {
                        if (!menuController.isActive(stationListPageName)) {
                          menuController.changeActiveItemTo(stationListPageName,
                              parentName: stationParentName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController
                              .navigateAndSyncURL(stationListPageRoute);
                        }
                      },
                    ),

                    //$ 5.2 Tạo station - con
                    if (isOwner)
                      SideMenuChildItem(
                        itemName: stationCreatePageName,
                        onTap: () {
                          if (!menuController.isActive(stationCreatePageName)) {
                            menuController.changeActiveItemTo(
                                stationCreatePageName,
                                parentName: stationParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(stationCreatePageRoute);
                          }
                        },
                      ),

                    //$ 5.3 Câp nhập station - con - Station Owner
                    if (isStationSelected && isOwner)
                      SideMenuChildItem(
                        itemName: stationUpdatePageName,
                        onTap: () {
                          if (!menuController.isActive(stationUpdatePageName)) {
                            menuController.changeActiveItemTo(
                                stationUpdatePageName,
                                parentName: stationParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(stationUpdatePageRoute);
                          }
                        },
                      ),
                    //$ 5.3 Xem chi tiết station - con - Station Admin
                    if (!isOwner)
                      SideMenuChildItem(
                        itemName: stationDetailPageName,
                        onTap: () {
                          if (!menuController.isActive(stationDetailPageName)) {
                            menuController.changeActiveItemTo(
                                stationDetailPageName,
                                parentName: stationParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(stationDetailPageRoute);
                          }
                        },
                      ),
                  ],
                ),

                //! Mục 6: Quản lý Admin - Nhaan vieen
                if (isOwner)
                  CustomExpansionItem(
                    parentName: adminParentName,
                    icon: Icons.person_outline,
                    children: [
                      //$ 6.1 Danh sách admin - con
                      SideMenuChildItem(
                        itemName: adminListPageName,
                        onTap: () {
                          if (!menuController.isActive(adminListPageName)) {
                            menuController.changeActiveItemTo(adminListPageName,
                                parentName: adminParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(adminListPageRoute);
                          }
                        },
                      ),

                      //$ 6.2 Tạo admin - con
                      SideMenuChildItem(
                        itemName: adminCreatePageName,
                        onTap: () {
                          if (!menuController.isActive(adminCreatePageName)) {
                            menuController.changeActiveItemTo(
                                adminCreatePageName,
                                parentName: adminParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(adminCreatePageRoute);
                          }
                        },
                      ),

                      //$ 6.3 Update admin - con
                      // if (isAdminSelected) ...[

                      SideMenuChildItem(
                        itemName: adminUpdatePageName,
                        onTap: () {
                          if (!menuController.isActive(adminUpdatePageName)) {
                            menuController.changeActiveItemTo(
                                adminUpdatePageName,
                                parentName: adminParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(adminUpdatePageRoute);
                          }
                        },
                      )
                    ],
                  ),

                if (isStationSelected) ...[
                  //! Mục 7: Quản lý Tài khoản người chơi (Cả 2 đều thấy) ---
                  CustomExpansionItem(
                    parentName: accountParentName,
                    icon: Icons.person_outline,
                    children: [
                      //$ 7.1 Danh sách tài khoản người chơi - con
                      SideMenuChildItem(
                        itemName: accountListPageName,
                        onTap: () {
                          if (!menuController.isActive(accountListPageName)) {
                            menuController.changeActiveItemTo(
                                accountListPageName,
                                parentName: accountParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(accountListPageRoute);
                          }
                        },
                      )
                    ],
                  ),

                  //! Mục 8: Quản lý Loại hình
                  SideMenuItem(
                    itemName: spacePageName,
                    icon: Icons.category_outlined, // Icon từ ảnh
                    onTap: () {
                      if (!menuController.isActive(spacePageName)) {
                        menuController.changeActiveItemTo(spacePageName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController.navigateAndSyncURL(spacePageRoute);
                      }
                    },
                  ),

                  //! Mục 9: QL KHU VỰC (Owner mới thấy "Tạo") ---
                  SideMenuItem(
                    itemName: areaPageName,
                    icon: Icons.map_outlined, // Icon từ ảnh
                    onTap: () {
                      if (!menuController.isActive(areaPageName)) {
                        menuController.changeActiveItemTo(areaPageName);
                        if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                        navigationController.navigateAndSyncURL(areaPageRoute);
                      }
                    },
                  ),

                  //! Mục 10: QL TÀI NGUYÊN (Owner mới thấy "Tạo") ---
                  CustomExpansionItem(
                    parentName: resourceParentName,
                    icon: Icons.devices_other_outlined,
                    children: [
                      //$ 10.1 Danh sách Tài nguyên - con
                      SideMenuChildItem(
                        itemName: resourceListPageName,
                        onTap: () {
                          if (!menuController.isActive(resourceListPageName)) {
                            menuController.changeActiveItemTo(
                                resourceListPageName,
                                parentName: resourceParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(resourceListPageRoute);
                          }
                        },
                      ),
                      //$ 10.2 Tạo Tài nguyên - con
                      // --- PHÂN QUYỀN ---
                      if (isOwner)
                        SideMenuChildItem(
                          itemName: resourceCreatePageName,
                          onTap: () {
                            if (!menuController
                                .isActive(resourceCreatePageName)) {
                              menuController.changeActiveItemTo(
                                  resourceCreatePageName,
                                  parentName: resourceParentName);
                              if (ResponsiveWidget.isSmallScreen(context)) {
                                Get.back();
                              }
                              navigationController
                                  .navigateAndSyncURL(resourceCreatePageRoute);
                            }
                          },
                        ),
                      //$ 10.3 Cập nhật Station - Tài nguyên - con
                      // ------------------
                      SideMenuChildItem(
                        itemName: resourceUpdatePageName,
                        onTap: () {
                          if (!menuController
                              .isActive(resourceUpdatePageName)) {
                            menuController.changeActiveItemTo(
                                resourceUpdatePageName,
                                parentName: resourceParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(resourceUpdatePageRoute);
                          }
                        },
                      ),
                    ],
                  ),

                  //! Mục 11: QL DỊCH VỤ ĂN UỐNG (Cả 2 đều thấy) ---
                  CustomExpansionItem(
                    parentName: menuParentName,
                    icon: Icons.fastfood_outlined,
                    children: [
                      //$ 11.1 Danh sách Dịch vụ - con
                      SideMenuChildItem(
                        itemName: menuListPageName,
                        onTap: () {
                          if (!menuController.isActive(menuListPageName)) {
                            menuController.changeActiveItemTo(menuListPageName,
                                parentName: menuParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(menuListPageRoute);
                          }
                        },
                      ),
                      //$ 11.2 Tạo Dịch vụ - con
                      SideMenuChildItem(
                        itemName: menuCreatePageName,
                        onTap: () {
                          if (!menuController.isActive(menuCreatePageName)) {
                            menuController.changeActiveItemTo(
                                menuCreatePageName,
                                parentName: menuParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(menuCreatePageRoute);
                          }
                        },
                      ),
                      //$ 11.3 Cập nhật Station - Dịch vụ - con
                      SideMenuChildItem(
                        itemName: menuUpdatePageName,
                        onTap: () {
                          if (!menuController.isActive(menuUpdatePageName)) {
                            menuController.changeActiveItemTo(
                                menuUpdatePageName,
                                parentName: menuParentName);
                            if (ResponsiveWidget.isSmallScreen(context)) {
                              Get.back();
                            }
                            navigationController
                                .navigateAndSyncURL(menuUpdatePageRoute);
                          }
                        },
                      ),
                    ],
                  )
                ]
                // --- THÊM MỚI: THÔNG BÁO KHI CHƯA CHỌN STATION ---
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.textHint, size: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Vui lòng chọn Station từ thanh trên cùng để xem các mục quản lý.",
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.4, // Thêm chiều cao dòng
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // --- KẾT THÚC THÊM MỚI ---
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
    });
  }
}
