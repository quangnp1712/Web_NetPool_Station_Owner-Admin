import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';

MenuController menuController = MenuController.instance;

class MenuController extends GetxController {
  static MenuController instance = Get.find();
  var activeItem = dashboardPageName.obs;
  var hoverItem = "".obs;

  // MỚI: Thêm biến theo dõi mục cha đang active
  var activeParent = "".obs;

  changeActiveItemTo(String itemName, {String parentName = ""}) {
    activeItem.value = itemName;

    // Cập nhật mục cha đang active
    activeParent.value = parentName;
  }

  onHover(String itemName) {
    if (!isActive(itemName)) hoverItem.value = itemName;
  }

  isHovering(String itemName) => hoverItem.value == itemName;

  isActive(String itemName) => activeItem.value == itemName;

  // MỚI: Hàm kiểm tra xem mục cha có active không
  isParentActive(String parentName) => activeParent.value == parentName;

  Widget returnIconFor(String itemName) {
    switch (itemName) {
      case dashboardPageName:
        return _customIcon(Icons.trending_up, itemName);
      case accountListPageName:
        return _customIcon(Icons.drive_eta, itemName);
      default:
        return _customIcon(Icons.exit_to_app, itemName);
    }
  }

  Widget _customIcon(IconData icon, String itemName) {
    if (isActive(itemName))
      return Icon(icon, size: 22, color: AppColors.menuActive);

    return Icon(
      icon,
      color: isHovering(itemName) ? AppColors.bgLight : AppColors.menuDisable,
    );
  }
}
