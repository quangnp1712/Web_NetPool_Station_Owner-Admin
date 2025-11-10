import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';

/// Cấu hình cho nút "Tạo mới" (Tùy chọn)
class CreateButtonConfig {
  final String text; // Text động (vd: "TẠO TÀI KHOẢN")
  final VoidCallback onPressed; // Hàm gọi khi bấm

  CreateButtonConfig({
    required this.text,
    required this.onPressed,
  });
}

/// Cấu hình cho mỗi Dropdown filter (Tùy chọn)
class FilterDropdownConfig {
  final String hint; // vd: "Tình trạng"
  final String? selectedValue; // Giá trị đang được chọn
  final List<String> items; // Danh sách items
  final void Function(String?) onChanged; // Hàm gọi khi đổi

  FilterDropdownConfig({
    required this.hint,
    this.selectedValue,
    required this.items,
    required this.onChanged,
  });
}

/// Widget Filter Bar (Thanh Lọc) có thể tái sử dụng
///
/// Chấp nhận controller, hint, 0-n dropdowns, và 1 nút tạo (tùy chọn)
class CommonFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHintText;
  final void Function(String) onSearchSubmitted;
  final List<FilterDropdownConfig> dropdowns;
  final CreateButtonConfig? createButtonConfig;

  const CommonFilterBar({
    super.key,
    required this.searchController,
    required this.searchHintText,
    required this.onSearchSubmitted,
    this.dropdowns = const [], // Mặc định là list rỗng (không có dropdown)
    this.createButtonConfig, // Mặc định là null (không có nút tạo)
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nhóm bên trái: Các bộ lọc
          Expanded(
            // SỬA: Bọc trong Expanded để Wrap hoạt động tốt
            child: Wrap(
              spacing: 16.0, // Khoảng cách ngang
              runSpacing: 16.0, // Khoảng cách dọc khi xuống hàng
              children: [
                // --- 1. Ô tìm kiếm (Luôn có) ---
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: AppColors.textWhite),
                    // Kích hoạt khi bấm Enter
                    onSubmitted: onSearchSubmitted,
                    decoration: InputDecoration(
                      hintText: searchHintText, // Dùng hint động
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      prefixIcon: IconButton(
                        // SỬA: Dùng IconButton
                        icon:
                            const Icon(Icons.search, color: AppColors.textHint),
                        onPressed: () {
                          // Kích hoạt khi bấm icon Search
                          onSearchSubmitted(searchController.text);
                        },
                      ),
                    ),
                  ),
                ),

                // --- 2. Các Dropdowns (Động) ---
                // Dùng Spread Operator (...) để trải list widget vào
                ...dropdowns.map((config) {
                  return _buildDropdown(
                    config.hint,
                    config.selectedValue,
                    config.items,
                    config.onChanged,
                  );
                }).toList(),
              ],
            ),
          ),

          // --- 3. Nút Tạo (Tùy chọn) ---
          if (createButtonConfig != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ElevatedButton.icon(
                onPressed: createButtonConfig!.onPressed, // Dùng config
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  createButtonConfig!.text, // Dùng config
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGlow,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET CON: TẠO DROPDOWN (Chuyển vào đây) ---
  Widget _buildDropdown(
    String hint,
    String? selectedValue, // THÊM: Giá trị đang chọn
    List<String> items,
    void Function(String?) onChanged, // THÊM: Hàm callback
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue, // SỬA
          hint: Text(hint, style: const TextStyle(color: AppColors.textHint)),
          dropdownColor: AppColors.inputBackground,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textWhite),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: const TextStyle(color: AppColors.textWhite)),
            );
          }).toList(),
          onChanged: onChanged, // SỬA
        ),
      ),
    );
  }
}
