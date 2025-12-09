import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_spec_model.dart';

class SpecInputForm extends StatefulWidget {
  final String spaceName;
  final ResourceSpecModel? initialSpec;
  final Function(ResourceSpecModel) onSpecChanged;

  const SpecInputForm(
      {super.key,
      required this.spaceName,
      this.initialSpec,
      required this.onSpecChanged});

  @override
  State<SpecInputForm> createState() => _SpecInputFormState();
}

class _SpecInputFormState extends State<SpecInputForm> {
  // PC Controllers
  late TextEditingController _pcCpu,
      _pcGpu,
      _pcRam,
      _pcMonitor,
      _pcKeyboard,
      _pcMouse,
      _pcHeadphone;
  // Bida Controllers
  late TextEditingController _btTable, _btCue, _btBall;
  // PS Controllers
  late TextEditingController _csConsole,
      _csTv,
      _csControllerType,
      _csControllerCount;

  @override
  void initState() {
    super.initState();
    // Init all controllers with initial data or empty
    final s = widget.initialSpec;
    _pcCpu = TextEditingController(text: s?.pcCpu);
    _pcGpu = TextEditingController(text: s?.pcGpuModel);
    _pcRam = TextEditingController(text: s?.pcRam);
    _pcMonitor = TextEditingController(text: s?.pcMonitor);
    _pcKeyboard = TextEditingController(text: s?.pcKeyboard);
    _pcMouse = TextEditingController(text: s?.pcMouse);
    _pcHeadphone = TextEditingController(text: s?.pcHeadphone);

    _btTable = TextEditingController(text: s?.btTableDetail);
    _btCue = TextEditingController(text: s?.btCueDetail);
    _btBall = TextEditingController(text: s?.btBallDetail);

    _csConsole = TextEditingController(text: s?.csConsoleModel);
    _csTv = TextEditingController(text: s?.csTvModel);
    _csControllerType = TextEditingController(text: s?.csControllerType);
    _csControllerCount =
        TextEditingController(text: s?.csControllerCount?.toString());

    // Add listeners to notify parent
    void listener() {
      widget.onSpecChanged(ResourceSpecModel(
          pcCpu: _pcCpu.text,
          pcGpuModel: _pcGpu.text,
          pcRam: _pcRam.text,
          pcMonitor: _pcMonitor.text,
          pcKeyboard: _pcKeyboard.text,
          pcMouse: _pcMouse.text,
          pcHeadphone: _pcHeadphone.text,
          btTableDetail: _btTable.text,
          btCueDetail: _btCue.text,
          btBallDetail: _btBall.text,
          csConsoleModel: _csConsole.text,
          csTvModel: _csTv.text,
          csControllerType: _csControllerType.text,
          csControllerCount: int.tryParse(_csControllerCount.text)));
    }

    for (var c in [
      _pcCpu,
      _pcGpu,
      _pcRam,
      _pcMonitor,
      _pcKeyboard,
      _pcMouse,
      _pcHeadphone,
      _btTable,
      _btCue,
      _btBall,
      _csConsole,
      _csTv,
      _csControllerType,
      _csControllerCount
    ]) {
      c.addListener(listener);
    }
  }

  @override
  void dispose() {
    for (var c in [
      _pcCpu,
      _pcGpu,
      _pcRam,
      _pcMonitor,
      _pcKeyboard,
      _pcMouse,
      _pcHeadphone,
      _btTable,
      _btCue,
      _btBall,
      _csConsole,
      _csTv,
      _csControllerType,
      _csControllerCount
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spaceName == "NET") return _buildNetForm();
    if (widget.spaceName == "BIDA") return _buildBidaForm();
    if (widget.spaceName == "PLAYSTATION") return _buildPsForm();
    return const Center(
        child: Text("Chọn Space để nhập cấu hình",
            style: TextStyle(color: Colors.grey)));
  }

  Widget _buildNetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Cấu hình PC",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField(
          "CPU",
          _pcCpu,
          isReadOnly: true,
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _buildTextField(
            "RAM",
            _pcRam,
            isReadOnly: true,
          )),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
            "GPU",
            _pcGpu,
            isReadOnly: true,
          ))
        ]),
        const SizedBox(height: 16),
        _buildTextField(
          "Màn hình",
          _pcMonitor,
          isReadOnly: true,
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _buildTextField(
            "Phím",
            _pcKeyboard,
            isReadOnly: true,
          )),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
            "Chuột",
            _pcMouse,
            isReadOnly: true,
          ))
        ]),
      ],
    );
  }

  Widget _buildBidaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thông tin Bàn Bida",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField(
          "Loại bàn",
          _btTable,
          isReadOnly: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "Loại cơ (Gậy)",
          _btCue,
          isReadOnly: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "Loại bóng",
          _btBall,
          isReadOnly: true,
        ),
      ],
    );
  }

  Widget _buildPsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thiết bị Console",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField(
          "Hệ máy (Console)",
          _csConsole,
          isReadOnly: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "TV / Màn hình",
          _csTv,
          isReadOnly: true,
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _buildTextField(
            "Loại tay cầm",
            _csControllerType,
            isReadOnly: true,
          )),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
            "Số lượng tay",
            _csControllerCount,
            isNumber: true,
            isReadOnly: true,
          ))
        ]),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          style: const TextStyle(color: Colors.white),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBackground,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF333333))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF333333))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
      ],
    );
  }
}
