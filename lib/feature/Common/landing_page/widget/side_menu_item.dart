import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/menu_controller.dart';

// class SideMenuItem extends StatelessWidget {
//   final String itemName;
//   final Function() onTap;

//   const SideMenuItem({Key? key, required this.itemName, required this.onTap})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;

//     return InkWell(
//         onTap: onTap,
//         onHover: (value) {
//           value
//               ? menuController.onHover(itemName)
//               : menuController.onHover("not hovering");
//         },
//         child: Obx(() => Container(
//               color: menuController.isHovering(itemName)
//                   ? AppColors.menuOnHover
//                   : Colors.transparent,
//               child: Row(
//                 children: [
//                   Visibility(
//                     visible: menuController.isHovering(itemName) ||
//                         menuController.isActive(itemName),
//                     maintainSize: true,
//                     maintainAnimation: true,
//                     maintainState: true,
//                     child: Container(
//                       width: 6,
//                       height: 40,
//                       color: AppColors.menuActive,
//                     ),
//                   ),
//                   SizedBox(width: width / 88),
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: menuController.returnIconFor(itemName),
//                   ),
//                   if (!menuController.isActive(itemName))
//                     Flexible(
//                       child: Text(
//                         itemName,
//                         style: TextStyle(
//                             color: menuController.isHovering(itemName)
//                                 ? AppColors.bgLight
//                                 : AppColors.menuDisable,
//                             fontFamily: 'SegoeUI'),
//                       ),
//                     )
//                   else
//                     Flexible(
//                       child: Text(
//                         itemName,
//                         style: TextStyle(
//                             color: AppColors.menuActive,
//                             fontFamily: 'SegoeUI Bold',
//                             fontSize: 18),
//                       ),
//                     )
//                 ],
//               ),
//             )));
//   }
// }

class SideMenuItem extends StatelessWidget {
  final String itemName;
  final IconData icon; // THAY ĐỔI: Nhận IconData trực tiếp
  final Function() onTap;
  final bool isLogout; // MỚI: Flag cho Đăng xuất

  const SideMenuItem({
    Key? key,
    required this.itemName,
    required this.icon, // THAY ĐỔI
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onHover: (value) {
        value
            ? menuController.onHover(itemName)
            : menuController.onHover("not hovering");
      },
      child: Obx(() {
        final bool isActive = menuController.isActive(itemName);
        final bool isHovering = menuController.isHovering(itemName);

        Color itemColor;
        FontWeight fontWeight = FontWeight.normal;

        if (isLogout) {
          itemColor = Colors.red;
          if (isHovering) itemColor = Colors.red[300]!;
        } else if (isActive) {
          itemColor = AppColors.menuActive;
          fontWeight = FontWeight.bold;
        } else if (isHovering) {
          itemColor = AppColors.bgLight;
        } else {
          itemColor = AppColors.menuDisable;
        }

        return Container(
          color: isHovering ? AppColors.menuOnHover : Colors.transparent,
          padding: EdgeInsets.symmetric(
              horizontal: 24, vertical: 16), // Padding cho mục cha
          child: Row(
            children: [
              Icon(icon, size: 20, color: itemColor),
              SizedBox(width: 16),
              Flexible(
                child: Text(
                  itemName,
                  style: TextStyle(
                    color: itemColor,
                    fontWeight: fontWeight,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}

class CustomExpansionItem extends StatelessWidget {
  final String parentName;
  final IconData icon;
  final List<Widget> children;

  const CustomExpansionItem({
    Key? key,
    required this.parentName,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Kiểm tra xem mục cha này có đang active không (vì con của nó active)
      final bool isParentActive = menuController.isParentActive(parentName);

      return ExpansionTile(
        key: PageStorageKey(parentName), // Giữ trạng thái đóng/mở
        shape: const Border(),
        collapsedShape: const Border(),
        // Dùng `leading` cho icon và `title` cho text
        leading: Icon(
          icon,
          size: 20,
          color: isParentActive ? AppColors.menuActive : AppColors.menuDisable,
        ),
        title: Text(
          parentName,
          style: TextStyle(
            color:
                isParentActive ? AppColors.menuActive : AppColors.menuDisable,
            fontSize: 16,
            fontWeight: isParentActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        // Tùy chỉnh icon mũi tên
        trailing: Icon(
          Icons.expand_more,
          size: 20,
          color: isParentActive ? AppColors.menuActive : AppColors.menuDisable,
        ),
        childrenPadding: EdgeInsets.zero, // Bỏ padding mặc định
        tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: children, // Hiển thị các mục con
      );
    });
  }
}

class SideMenuChildItem extends StatelessWidget {
  final String itemName;
  final Function() onTap;

  const SideMenuChildItem({
    Key? key,
    required this.itemName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onHover: (value) {
        value
            ? menuController.onHover(itemName)
            : menuController.onHover("not hovering");
      },
      child: Obx(() {
        final bool isActive = menuController.isActive(itemName);
        final bool isHovering = menuController.isHovering(itemName);

        // Đây là style từ ảnh "image_eb1e3f.png" (có nền tím khi active)
        // Nó rõ ràng hơn là chỉ đổi màu chữ
        Color bgColor = Colors.transparent;
        if (isActive) {
          bgColor = AppColors.menuActive.withOpacity(0.2);
        } else if (isHovering) {
          bgColor = AppColors.menuOnHover;
        }

        return Container(
          color: bgColor,
          padding: EdgeInsets.only(left: 68, top: 16, bottom: 16), // Thụt lề
          child: Row(
            children: [
              // Mũi tên nhỏ bên cạnh mục active (từ ảnh "image_eb1e3f.png")
              Visibility(
                visible: isActive,
                child: Icon(Icons.arrow_right,
                    color: AppColors.menuActive, size: 20),
              ),
              if (isActive) SizedBox(width: 5),

              Text(
                itemName,
                style: TextStyle(
                  color: isActive
                      ? AppColors.menuActive
                      : (isHovering
                          ? AppColors.bgLight
                          : AppColors.menuDisable),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
