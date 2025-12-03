import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/bloc/area_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/services/hex_color_extension.dart';

class CreateAreaDialog extends StatefulWidget {
  final List<StationSpaceModel> availableSpaces;
  final Function(AreaListCreateEvent) onSubmit;

  const CreateAreaDialog(
      {super.key, required this.availableSpaces, required this.onSubmit});

  @override
  State<CreateAreaDialog> createState() => _CreateAreaDialogState();
}

class _CreateAreaDialogState extends State<CreateAreaDialog> {
  final _formKey = GlobalKey<FormState>();

  final _areaCodeController = TextEditingController();
  final _areaNameController = TextEditingController();
  final _priceController = TextEditingController();

  StationSpaceModel? _selectedSpace;

  @override
  void dispose() {
    _areaCodeController.dispose();
    _areaNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Widget _buildDropdownItem(StationSpaceModel item) {
    final itemColor =
        item.space?.metadata?.bgColor.toColor(fallback: Colors.grey);
    IconData iconData;
    switch (item.space?.metadata?.icon) {
      case 'PS5':
      case 'PS':
      case 'PLAYSTATION':
        iconData = Icons.gamepad_outlined;
        break;
      case 'PC':
      case 'NET':
        iconData = Icons.computer_outlined;
        break;
      case 'BILLIARD':
      case 'BIDA':
        iconData = Icons.sports_baseball_outlined;
        break;
      case 'SOCCER':
        iconData = Icons.sports_soccer_outlined;
        break;
      default:
        iconData = Icons.category_outlined;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: itemColor, borderRadius: BorderRadius.circular(6)),
          child: Icon(iconData, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.spaceName ?? "",
                style: const TextStyle(
                    color: AppColors.textWhite, fontWeight: FontWeight.w500)),
            Text(item.spaceCode ?? "",
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const Text("Thêm Khu vực mới",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // 1. Station Space Dropdown
              const Text("Loại hình dịch vụ (Space) *",
                  style: TextStyle(color: AppColors.textHint, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonFormField<StationSpaceModel>(
                  value: _selectedSpace,
                  dropdownColor: AppColors.inputBackground,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: InputBorder.none,
                    errorStyle: TextStyle(height: 0),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textHint),
                  hint: const Text("Chọn Space",
                      style: TextStyle(color: AppColors.textHint)),
                  validator: (value) =>
                      value == null ? "Vui lòng chọn Space" : null,
                  selectedItemBuilder: (context) {
                    return widget.availableSpaces.map((item) {
                      return Text(item.spaceName ?? "",
                          style: const TextStyle(color: Colors.white));
                    }).toList();
                  },
                  items: widget.availableSpaces.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: _buildDropdownItem(item),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSpace = val),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Area Code & Area Name Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mã Khu vực *",
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _areaCodeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.inputBackground,
                            hintText: "VD: VIP3",
                            hintStyle:
                                const TextStyle(color: AppColors.textHint),
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
                                borderSide: const BorderSide(
                                    color: AppColors.primaryBlue)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Nhập mã" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tên Khu vực *",
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _areaNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.inputBackground,
                            hintText: "VD: VIP 2",
                            hintStyle:
                                const TextStyle(color: AppColors.textHint),
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
                                borderSide: const BorderSide(
                                    color: AppColors.primaryBlue)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "Nhập tên"
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Price
              const Text("Đơn giá (VND) *",
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
                  hintText: "VD: 10000",
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  suffixText: "đ",
                  suffixStyle: const TextStyle(color: AppColors.textWhite),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.primaryBlue)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nhập giá" : null,
              ),

              const SizedBox(height: 32),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy",
                        style: TextStyle(color: AppColors.textHint)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(AreaListCreateEvent(
                          stationSpace: _selectedSpace!,
                          areaCode: _areaCodeController.text,
                          areaName: _areaNameController.text,
                          price: int.parse(_priceController.text),
                        ));
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Tạo Khu vực"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
