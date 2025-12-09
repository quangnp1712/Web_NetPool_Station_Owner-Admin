// ==========================================
// 2. WIDGET: BULK CREATE DIALOG (Core UX)
// ==========================================

// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_spec_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';

class BulkCreateResourceDialog extends StatefulWidget {
  final int areaId;
  final StationSpaceModel selectedSpace;
  final Function(List<StationResourceModel>) onSave;

  const BulkCreateResourceDialog(
      {super.key,
      required this.areaId,
      required this.onSave,
      required this.selectedSpace});

  @override
  State<BulkCreateResourceDialog> createState() =>
      _BulkCreateResourceDialogState();
}

class _BulkCreateResourceDialogState extends State<BulkCreateResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  TextEditingController _resourceNameController = TextEditingController();
  final _startNumController = TextEditingController(text: "1");
  final _countController = TextEditingController(text: "1");
  List<String> _previewNames = [];

  bool _useExistingSpec = false;

  // PC
  final _cpuController = TextEditingController();
  final _ramController = TextEditingController();
  final _gpuController = TextEditingController();

  final _monitorController = TextEditingController();
  final _keyboardController = TextEditingController();
  final _mouseController = TextEditingController();
  final _headphoneController = TextEditingController();

  // bida
  final _btTable = TextEditingController();
  final _btCue = TextEditingController();
  final _btBall = TextEditingController();

  // ps
  final _csConsole = TextEditingController();
  final _csTv = TextEditingController();
  final _csControllerType = TextEditingController();
  final _csControllerCount = TextEditingController();

  final Map<String, List<ResourceSpecModel>> _savedSpecs = {
    "NET": [
      ResourceSpecModel(
          pcCpu: "i5-12400F",
          pcRam: "16GB",
          pcGpuModel: "GTX 1660S",
          pcMonitor: "LG 24 144Hz",
          pcKeyboard: "DareU",
          pcMouse: "Logitech",
          pcHeadphone: "DareU"),
      ResourceSpecModel(
          pcCpu: "i7-12700K",
          pcRam: "32GB",
          pcGpuModel: "RTX 3060",
          pcMonitor: "Samsung 27 240Hz",
          pcKeyboard: "Corsair",
          pcMouse: "Logitech Pro",
          pcHeadphone: "HyperX"),
    ],
    "BIDA": [
      ResourceSpecModel(
          btTableDetail: "KKKing Empire",
          btCueDetail: "Carbon Cue",
          btBallDetail: "Dynaspheres"),
    ],
    "PLAYSTATION": [
      ResourceSpecModel(
          csConsoleModel: "PS5 Standard",
          csTvModel: "Sony 55 4K",
          csControllerType: "DualSense",
          csControllerCount: 2),
    ]
  };
  ResourceSpecModel? _selectedSpec;

  @override
  void initState() {
    super.initState();
    _resourceNameController =
        TextEditingController(text: "${widget.selectedSpace.spaceName}-VIP");
    _updatePreview();
    _resourceNameController.addListener(_updatePreview);
    _startNumController.addListener(_updatePreview);
    _countController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _resourceNameController.dispose();
    _startNumController.dispose();
    _countController.dispose();

    _cpuController.dispose();
    _ramController.dispose();
    _gpuController.dispose();
    _monitorController.dispose();
    _keyboardController.dispose();
    _mouseController.dispose();
    _headphoneController.dispose();

    _btTable.dispose();
    _btCue.dispose();
    _btBall.dispose();

    _csConsole.dispose();
    _csTv.dispose();
    _csControllerType.dispose();
    _csControllerCount.dispose();

    super.dispose();
  }

  void _updatePreview() {
    final resourceName = _resourceNameController.text;
    final start = int.tryParse(_startNumController.text) ?? 1;
    final count = int.tryParse(_countController.text) ?? 1;

    List<String> temp = [];
    int displayCount = count > 50 ? 50 : count;

    for (int i = 0; i < displayCount; i++) {
      int currentNum = start + i;
      String numStr = currentNum < 10 ? "0$currentNum" : "$currentNum";
      temp.add("$resourceName-$numStr");
    }

    if (count > 50) temp.add("... và ${count - 50} máy nữa");

    setState(() {
      _previewNames = temp;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ResourceSpecModel? finalSpec;

      if (_useExistingSpec) {
        if (_selectedSpec == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Vui lòng chọn một cấu hình cũ"),
              backgroundColor: Colors.red));
          return;
        }
        finalSpec = _selectedSpec;
      } else {
        finalSpec = ResourceSpecModel(
          pcCpu: _cpuController.text,
          pcRam: _ramController.text,
          pcGpuModel: _gpuController.text,
          pcMonitor: _monitorController.text,
          pcKeyboard: _keyboardController.text,
          pcMouse: _mouseController.text,
          pcHeadphone: _headphoneController.text,
        );
      }

      List<StationResourceModel> newResources = [];
      final start = int.parse(_startNumController.text);
      final count = int.parse(_countController.text);
      final resourceName = _resourceNameController.text;

      for (int i = 0; i < count; i++) {
        int currentNum = start + i;
        String numStr = currentNum < 10 ? "0$currentNum" : "$currentNum";
        String name = "$resourceName-$numStr";

        newResources.add(StationResourceModel(
          areaId: widget.areaId,
          resourceName: name,
          resourceCode: name,
          typeCode: widget.selectedSpace.spaceCode,
          typeName: widget.selectedSpace.spaceName,
          statusCode: "ENABLE",
          statusName: "Hoạt động",
          spec: finalSpec,
        ));
      }

      widget.onSave(newResources);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E1E1E),
      child: Container(
        width: 700,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Thêm Tài Nguyên (${widget.selectedSpace.spaceName})",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white54))
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStepHeader(0, "1. Định danh & Số lượng"),
                  Container(
                      width: 40,
                      height: 1,
                      color: Colors.grey.shade700,
                      margin: const EdgeInsets.symmetric(horizontal: 10)),
                  _buildStepHeader(1, "2. Cấu hình & Gear"),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child:
                    _currentStep == 0 ? _buildNamingStep() : _buildSpecStep(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text("Quay lại",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep == 0) {
                        setState(() => _currentStep++);
                      } else {
                        _handleSubmit();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                        _currentStep == 0 ? "Tiếp tục" : "Hoàn tất & Tạo máy",
                        style: const TextStyle(
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

  Widget _buildStepHeader(int index, String title) {
    bool isActive = _currentStep == index;
    bool isCompleted = _currentStep > index;
    Color color = isActive || isCompleted
        ? const Color(0xFF2563EB)
        : Colors.grey.shade700;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text("${index + 1}",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                color: isActive || isCompleted ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildNamingStep() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Thiết lập tên hàng loạt",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          "Tên ${widget.selectedSpace.spaceName}",
                          _resourceNameController,
                          "VD: PC-")),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          "Số bắt đầu", _startNumController, "1",
                          isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          "Số lượng tạo", _countController, "10",
                          isNumber: true)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Color(0xFF333333)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Xem trước tên máy",
                          style: TextStyle(color: Colors.grey)),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text("${_previewNames.length} máy",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _previewNames.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3C),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(_previewNames[index],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSpecStep() {
    List<ResourceSpecModel> templates =
        _savedSpecs[widget.selectedSpace.spaceName] ?? [];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleBtn("Tạo cấu hình mới", !_useExistingSpec,
                    () => setState(() => _useExistingSpec = false)),
                _buildToggleBtn("Chọn cấu hình cũ", _useExistingSpec,
                    () => setState(() => _useExistingSpec = true)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!_useExistingSpec) ...[
            _buildFormBasedOnSpace(),
          ] else ...[
            const Text("Chọn mẫu cấu hình đã lưu",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ResourceSpecModel>(
                  value: _selectedSpec,
                  hint: const Text("Chọn cấu hình...",
                      style: TextStyle(color: AppColors.textHint)),
                  dropdownColor: AppColors.inputBackground,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textHint),
                  isExpanded: true,
                  items: templates.map((spec) {
                    // Generate a simple label based on space
                    String label = "Unknown Spec";
                    if (widget.selectedSpace.spaceName == "NET")
                      label = "${spec.pcCpu} / ${spec.pcGpuModel}";
                    else if (widget.selectedSpace.spaceName == "BIDA")
                      label = "${spec.btTableDetail}";
                    else if (widget.selectedSpace.spaceName == "PLAYSTATION")
                      label = "${spec.csConsoleModel}";
                    return DropdownMenuItem(
                      value: spec,
                      child: Text(label,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSpec = val),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedSpec != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                ),
                child: _buildReadOnlyDetail(_selectedSpec!),
              ),
          ]
        ],
      ),
    );
  }

  Widget _buildFormBasedOnSpace() {
    if (widget.selectedSpace.spaceName == "NET") return _buildNetForm();
    if (widget.selectedSpace.spaceName == "BIDA") return _buildBidaForm();
    if (widget.selectedSpace.spaceName == "PLAYSTATION") return _buildPsForm();
    return const SizedBox.shrink();
  }

  Widget _buildNetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thông số kỹ thuật (PC Components)",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildTextField(
            "CPU / Processor", _cpuController, "VD: Intel Core i7-12700K"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    "RAM Memory", _ramController, "VD: 32GB DDR5")),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField("Card đồ họa (GPU)", _gpuController,
                    "VD: NVIDIA GeForce RTX 3070 Ti")),
          ],
        ),
        const SizedBox(height: 24),
        const Text("Gaming Gear & Màn hình",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField("Màn hình (Monitor)", _monitorController,
                    "VD: Samsung Odyssey 27\" 240Hz")),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField("Bàn phím (Keyboard)",
                    _keyboardController, "VD: DareU EK810")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    "Chuột (Mouse)", _mouseController, "VD: Logitech G102")),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField("Tai nghe (Headphone)",
                    _headphoneController, "VD: HyperX Cloud II")),
          ],
        ),
      ],
    );
  }

  Widget _buildBidaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thông số kỹ thuật (BIDA - Billiard)",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildTextField("Bàn (Table)", _btTable, "VD: KKKing Empire Series 2"),
        const SizedBox(height: 16),
        _buildTextField("Cơ (Cue)", _btCue, "VD: Cơ CLB Carbon"),
        const SizedBox(height: 16),
        _buildTextField("Bi (Ball)", _btBall, "VD: Dynaspheres Palladium"),
      ],
    );
  }

  Widget _buildPsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thông số kỹ thuật (PLAYSTATION )",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildTextField(
            "Dòng máy (Console)", _csConsole, "VD: PlayStation 5 Standard"),
        const SizedBox(height: 16),
        _buildTextField("TV / Màn hình", _csTv, "VD: Sony Bravia 4K 55 inch"),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _buildTextField(
                  "Loại tay cầm", _csControllerType, "VD: DualSense White")),
          const SizedBox(width: 12),
          Expanded(
              child: _buildTextField("Số lượng", _csControllerCount, "VD: 2",
                  isNumber: true))
        ]),
      ],
    );
  }

  Widget _buildReadOnlyDetail(ResourceSpecModel spec) {
    if (widget.selectedSpace.spaceName == "NET") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chi tiết cấu hình:",
              style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                children: [
                  _buildSpecRow("CPU", _selectedSpec?.pcCpu ?? ""),
                  const SizedBox(height: 8),
                  _buildSpecRow("RAM", _selectedSpec?.pcRam ?? ""),
                  const SizedBox(height: 8),
                  _buildSpecRow("GPU", _selectedSpec?.pcGpuModel ?? ""),
                ],
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                children: [
                  _buildSpecRow("Monitor", _selectedSpec?.pcMonitor ?? ""),
                  const SizedBox(height: 8),
                  _buildSpecRow("Keyboard", _selectedSpec?.pcKeyboard ?? ""),
                  const SizedBox(height: 8),
                  _buildSpecRow("Mouse", _selectedSpec?.pcMouse ?? ""),
                ],
              )),
            ],
          ),
        ],
      );
    } else if (widget.selectedSpace.spaceName == "BIDA") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chi tiết cấu hình:",
              style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 12),
          _buildSpecRow("Bàn", spec.btTableDetail ?? ""),
          const SizedBox(height: 8),
          _buildSpecRow("Cơ", spec.btCueDetail ?? ""),
          const SizedBox(height: 8),
          _buildSpecRow("Bóng", spec.btBallDetail ?? ""),
        ],
      );
    } else {
      // PS
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chi tiết cấu hình:",
              style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 12),
          _buildSpecRow("Console", spec.csConsoleModel ?? ""),
          const SizedBox(height: 8),
          _buildSpecRow("TV", spec.csTvModel ?? ""),
          const SizedBox(height: 8),
          _buildSpecRow("Tay cầm",
              "${spec.csControllerCount} x ${spec.csControllerType}"),
        ],
      );
    }
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2C2C2E),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF333333))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF333333))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2563EB))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (val) => val == null || val.isEmpty ? "Bắt buộc" : null,
        ),
      ],
    );
  }
}
