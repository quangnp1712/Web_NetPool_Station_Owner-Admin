import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_spec_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/widget/resource_spec_input_form.dart';

class EditResourceDialog extends StatefulWidget {
  final String spaceName;
  final StationResourceModel resource;
  final Function(StationResourceModel) onSave;
  final Function(StationResourceModel) onToggleStatus;

  const EditResourceDialog(
      {super.key,
      required this.spaceName,
      required this.resource,
      required this.onSave,
      required this.onToggleStatus});

  @override
  State<EditResourceDialog> createState() => _EditResourceDialogState();
}

class _EditResourceDialogState extends State<EditResourceDialog> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  ResourceSpecModel? _currentSpec;
  late String _statusCode;
  late String _statusName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.resource.resourceName);
    _codeController = TextEditingController(text: widget.resource.resourceCode);
    _statusCode = widget.resource.statusCode ?? "ACTIVE";
    _statusName = widget.resource.statusName ?? "";
    _currentSpec = widget.resource.spec;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = _statusCode == "ACTIVE";
    Color statusColor =
        isActive ? AppColors.statusActiveText : AppColors.statusInactiveText;

    return Dialog(
      backgroundColor: AppColors.containerBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Chi tiết & Cập nhật Máy",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(_statusName,
                          style: TextStyle(
                              color: statusColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Gọi callback Toggle Status và đóng popup
                      widget.onToggleStatus(widget.resource);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.sync,
                        size: 16, color: AppColors.primaryBlue),
                    label: const Text("Đổi trạng thái",
                        style: TextStyle(color: AppColors.primaryBlue)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue)),
                  )
                ],
              ),
              const Divider(color: AppColors.border, height: 32),
              _buildTextField("Tên máy", _nameController),
              const SizedBox(height: 16),
              _buildTextField("Mã máy", _codeController),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.inputBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border)),
                child: SpecInputForm(
                  spaceName: widget.spaceName,
                  initialSpec: _currentSpec,
                  onSpecChanged: (newSpec) => _currentSpec = newSpec,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Hủy",
                          style: TextStyle(color: AppColors.textHint))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Update object with new values
                      final updatedResource = widget.resource.copyWith(
                          resourceName: _nameController.text,
                          resourceCode: _codeController.text,
                          spec: _currentSpec);
                      widget.onSave(updatedResource);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Lưu thay đổi",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
            width: 80,
            child: Text(label,
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 12))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500))),
      ],
    );
  }
}
