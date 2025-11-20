import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/menu_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';

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

      // --- SỬA LỖI: XỬ LÝ STATION ADMIN (CHỈ CÓ 1 STATION) ---
      // Nếu là Station Admin (chỉ có 1 station VÀ nó đã được chọn)
      if (sessionController.stationList.length == 1 &&
          sessionController.activeStationId != null) {
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
      // --- KẾT THÚC SỬA ---

      // Nếu có > 1 station (hoặc 1 station nhưng chưa chọn), hiển thị Dropdown
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.inputBackground, // Màu nền
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          // --- SỬA LỖI: ĐỔI 'int' THÀNH 'String?' (nullable) ---
          child: DropdownButton<String>(
            // SỬA: Dùng String?

            // SỬA: 'value' giờ đây có thể là null
            value: sessionController.activeStationId.value,

            // SỬA: Thêm 'hint' (hiển thị khi value là null)
            hint: Text(
              "Chọn Station...",
              style: TextStyle(
                  color: AppColors.textHint, fontStyle: FontStyle.italic),
            ),

            // Style
            style: const TextStyle(color: AppColors.textWhite),
            dropdownColor: AppColors.inputBackground, // Nền của menu
            icon: const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textHint),

            // Danh sách items (từ controller)
            items: sessionController.stationList.map((station) {
              return DropdownMenuItem<String>(
                value: station.stationId, // SỬA: Dùng stationId (String)
                child: Text(station.stationName ?? ""), // SỬA: Dùng stationName
              );
            }).toList(),

            // Hàm gọi khi thay đổi
            onChanged: (String? newStationId) {
              // SỬA: Dùng String?
              // (Không cần 'if (newStationId != null)' vì chúng ta MUỐN set null)

              // 1. Cập nhật Station trong controller (kể cả khi là null)
              sessionController.changeActiveStation(newStationId);

              // 2. Tải lại (reload) trang về Dashboard
              // (Vì nếu chọn null, các trang khác sẽ bị ẩn)
              NavigationController.instance
                  .navigateAndSyncURL(dashboardPageRoute);
            },
          ),
          // --- KẾT THÚC SỬA LỖI ---
        ),
      );
    });
  }
}
