import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/menu_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/user_session_controller.dart';

class StationSelectorDropdown extends StatelessWidget {
  const StationSelectorDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Tìm controller
    final UserSessionController sessionController = Get.find();

    // 2. Lắng nghe thay đổi
    return Obx(() {
      // Nếu không có station (hoặc đang tải), không hiển thị gì
      if (sessionController.stationList.isEmpty) {
        return const SizedBox.shrink();
      }

      // Nếu chỉ có 1 station, hiển thị tên (không cần dropdown)
      if (sessionController.stationList.length == 1) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.store_outlined, color: AppColors.textHint, size: 20),
              SizedBox(width: 8),
              Text(
                sessionController.stationList[0].stationName ?? "",
                style: TextStyle(color: AppColors.textWhite, fontSize: 16),
              ),
            ],
          ),
        );
      }

      // Nếu có > 1 station, hiển thị Dropdown
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.inputBackground, // Màu nền
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            // Giá trị đang chọn (từ controller)
            value: sessionController.activeStationId.value,

            // Style
            style: const TextStyle(color: AppColors.textWhite),
            dropdownColor: AppColors.inputBackground, // Nền của menu
            icon: const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textHint),

            // Danh sách items (từ controller)
            items: sessionController.stationList.map((station) {
              return DropdownMenuItem<String>(
                value: station.stationId, // (Giả sử StationModel có 'id')
                child: Text(station.stationName ??
                    ""), // (Giả sử StationModel có 'name')
              );
            }).toList(),

            // Hàm gọi khi thay đổi
            onChanged: (String? newStationId) {
              if (newStationId != null) {
                // 1. Cập nhật Station trong controller
                sessionController.changeActiveStation(newStationId);
                if (!menuController.isActive(dashboardPageName)) {
                  menuController.changeActiveItemTo(dashboardPageName);
                  if (ResponsiveWidget.isSmallScreen(context)) Get.back();
                  navigationController.navigateAndSyncURL(dashboardPageRoute);
                }
              }
            },
          ),
        ),
      );
    });
  }
}
