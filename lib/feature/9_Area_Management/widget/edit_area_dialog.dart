// ==========================================
// 5. DIALOG WIDGET: EDIT/DETAIL AREA
// ==========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/bloc/area_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_model.dart';

class EditAreaDialog extends StatefulWidget {
  final AreaModel area;
  final Function(AreaListEvent)
      onEvent; // Generic event handler for various actions

  const EditAreaDialog({super.key, required this.area, required this.onEvent});

  @override
  State<EditAreaDialog> createState() => _EditAreaDialogState();
}

class _EditAreaDialogState extends State<EditAreaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _areaCodeController;
  late TextEditingController _areaNameController;
  late TextEditingController _priceController;

  // Local state for status name display (Optimistic Update)
  late String _statusName;
  late String _statusCode;

  @override
  void initState() {
    super.initState();
    _areaCodeController = TextEditingController(text: widget.area.areaCode);
    _areaNameController = TextEditingController(text: widget.area.areaName);
    _priceController =
        TextEditingController(text: widget.area.price?.toString() ?? '0');
    _statusName = widget.area.statusName ?? 'Hoạt động';
    _statusCode = widget.area.statusCode ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _areaCodeController.dispose();
    _areaNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Sửa: Thêm hàm hiển thị confirm cho đổi trạng thái
  void _showConfirmToggleStatus(BuildContext context) {
    final isCurrentlyActive = _statusCode == 'ACTIVE';
    final nextStatusName = isCurrentlyActive ? 'Không hoạt động' : 'Hoạt động';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.inputBackground,
        title: const Text("Xác nhận Đổi trạng thái",
            style: TextStyle(color: Colors.white)),
        content: Text(
            "Bạn có chắc chắn muốn chuyển trạng thái sang $nextStatusName không?",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Hủy")),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.menuActive),
            onPressed: () {
              // Send Event
              widget.onEvent(ToggleStatusEvent(widget.area));
              Navigator.pop(dialogContext); // Close confirm
              Navigator.pop(context);
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = _statusCode == 'ACTIVE';
    Color statusColor =
        isActive ? AppColors.statusFree : AppColors.statusInactiveBg;

    return Dialog(
      backgroundColor: AppColors.containerBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chi tiết & Cập nhật Khu vực",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Status & Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text("Trạng thái: $_statusName",
                          style: TextStyle(
                              color: statusColor, fontWeight: FontWeight.w600)),
                    ],
                  ),

                  // Toggle Status Button
                  // Sửa: Gọi _showConfirmToggleStatus khi nhấn
                  OutlinedButton.icon(
                    onPressed: () => _showConfirmToggleStatus(context),
                    icon: const Icon(Icons.sync,
                        size: 16, color: AppColors.menuActive),
                    label: const Text("Đổi trạng thái",
                        style: TextStyle(
                            color: AppColors.menuActive, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.menuActive),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  )
                ],
              ),
              const Divider(color: AppColors.border, height: 32),

              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text("Mã Khu vực",
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextFormField(
                          controller: _areaCodeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              hintText: "Mã",
                              hintStyle:
                                  const TextStyle(color: AppColors.textHint),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.menuActive)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14)),
                          validator: (value) => value == null || value.isEmpty
                              ? "Nhập mã"
                              : null),
                    ])),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text("Tên Khu vực",
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextFormField(
                          controller: _areaNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              hintText: "Tên",
                              hintStyle:
                                  const TextStyle(color: AppColors.textHint),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.menuActive)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14)),
                          validator: (value) => value == null || value.isEmpty
                              ? "Nhập tên"
                              : null),
                    ])),
              ]),
              const SizedBox(height: 16),

              const Text("Đơn giá (VND)",
                  style: TextStyle(color: AppColors.textHint, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _priceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      hintText: "Giá",
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      suffixText: "đ",
                      suffixStyle: const TextStyle(color: AppColors.textWhite),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.menuActive)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14)),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Nhập giá" : null),

              const SizedBox(height: 32),

              // Action Buttons Row
              Row(children: [
                // Delete Button

                const Spacer(),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy / Trở về",
                        style: TextStyle(color: AppColors.textHint))),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updatedArea = AreaModel(
                          areaId: widget.area.areaId,
                          stationSpaceId: widget.area.stationSpaceId,
                          statusCode: _statusCode,
                          statusName: _statusName,
                          areaCode: _areaCodeController.text,
                          areaName: _areaNameController.text,
                          price: int.parse(_priceController.text),
                        );
                        widget.onEvent(UpdateAreaEvent(updatedArea));
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.menuActive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text("Lưu thay đổi")),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
