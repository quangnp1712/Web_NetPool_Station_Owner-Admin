import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/bloc/space_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';

class StationSpacePage extends StatefulWidget {
  const StationSpacePage({super.key});

  @override
  State<StationSpacePage> createState() => _StationSpacePageState();
}

class _StationSpacePageState extends State<StationSpacePage> {
  final SpaceBloc _bloc = SpaceBloc();
  late int _currentStationId;
  bool isLoading = true;

  // Map Icon local (Fallback nếu BE trả về chuỗi code)
  final Map<String, IconData> _iconMap = {
    "BILLIARD": Icons.sports_baseball_outlined,
    "NET": Icons.computer_outlined,
    "PS5": Icons.gamepad_outlined,
    "SOCCER": Icons.sports_soccer_outlined,
    "OTHER": Icons.category_outlined,
  };

  @override
  void initState() {
    super.initState();
    final session = Get.find<UserSessionController>();
    _currentStationId = int.tryParse(session.activeStationId.value ?? "0") ?? 0;

    if (_currentStationId != 0) {
      _bloc.add(InitSpaceManageEvent(_currentStationId));
    }
  }

  Color _getColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primaryGlow;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return AppColors.primaryGlow;
    }
  }

  IconData _getIcon(String? iconCode) {
    return _iconMap[iconCode?.toUpperCase()] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: BlocConsumer<SpaceBloc, SpaceState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state.status == SpaceStatus.failure && state.message.isNotEmpty) {
            ShowSnackBar(state.message, false);
          }
          if (state.status == SpaceStatus.success && state.message.isNotEmpty) {
            ShowSnackBar(state.message, true);
          }
        },
        builder: (context, state) {
          isLoading = state.status == SpaceStatus.loading;

          if (_currentStationId == 0) {
            return const Center(
                child: Text("Vui lòng chọn Station trước",
                    style: TextStyle(color: Colors.white)));
          }

          return Material(
            color: AppColors.mainBackground,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. STATION HEADER INFO (COLLAPSIBLE)
                      _buildStationInfoSection(context, state),

                      const SizedBox(height: 32),

                      // 2. LIST HEADER & ADD BUTTON
                      _buildSpaceListHeader(context),

                      const SizedBox(height: 24),

                      // 3. GRID LIST
                      if (state.mySpaces.isEmpty)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: Text("Chưa có loại hình nào",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16))))
                      else
                        _buildGridList(context, state.mySpaces),
                    ],
                  ),
                ),

                // --- WIDGET LOADING TRONG STACK ---
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.containerBackground.withOpacity(
                          0.8,
                        ), // Màu nền mờ
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGlow,
                          ),
                        ),
                      ),
                    ),
                  ),
                // ------------------------------------
              ],
            ),
          );
        },
      ),
    );
  }

// --- SECTION 1: STATION INFO ---
  Widget _buildStationInfoSection(BuildContext context, SpaceState state) {
    final info = state.station;
    if (info == null) return const SizedBox.shrink();

    // Logic màu Status
    Color statusColor = Colors.grey;
    switch (info.statusCode?.toUpperCase()) {
      case 'ACTIVE':
      case 'ENABLE':
        statusColor = Colors.green;
        break;
      case 'PENDING':
        statusColor = Colors.orangeAccent;
        break;
      case 'INACTIVE':
      case 'DISABLE':
        statusColor = Colors.redAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGlow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Tên Station + Badge Trạng thái
          Row(
            children: [
              const Icon(Icons.store, color: AppColors.primaryGlow, size: 32),
              const SizedBox(width: 16),
              Text(info.stationName ?? "Unknown Station",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              // Badge Trạng thái
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  info.statusName ?? info.statusCode ?? "Unknown",
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white10, height: 32),

          // Row 2: Thông tin chi tiết (Luôn hiện)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _infoItem(
                      Icons.location_on, "Địa chỉ", info.address ?? "")),
              Expanded(
                  child: _infoItem(Icons.phone, "Hotline", info.hotline ?? "")),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  // --- SECTION 2: LIST HEADER ---
  Widget _buildSpaceListHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Danh sách Loại hình",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: () => _showCreateDialog(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("THÊM LOẠI HÌNH",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGlow,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // --- SECTION 3: GRID LIST ---
  Widget _buildGridList(BuildContext context, List<StationSpaceModel> spaces) {
    return LayoutBuilder(builder: (context, constraints) {
      int cols = constraints.maxWidth > 1200
          ? 4
          : (constraints.maxWidth > 800 ? 3 : 2);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.4),
        itemCount: spaces.length,
        itemBuilder: (ctx, index) => _buildSpaceCard(context, spaces[index]),
      );
    });
  }

  // --- CARD ITEM ---
  Widget _buildSpaceCard(BuildContext context, StationSpaceModel item) {
    final bool isActive = item.statusCode == 'ACTIVE';
    final colorHex = item.space?.metadata?.bgColor ?? "#CB30E0";
    final color =
        Color(int.tryParse(colorHex.replaceFirst('#', '0xff')) ?? 0xFFCB30E0);
    final iconCode = item.space?.metadata?.icon;
    final iconData = _iconMap[iconCode] ?? Icons.category;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isActive ? color.withOpacity(0.5) : Colors.white10,
            width: 1.5),
        boxShadow: [
          if (isActive)
            BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditDialog(context, item),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: isActive
                              ? color.withOpacity(0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(iconData,
                          color: isActive ? color : Colors.grey, size: 24),
                    ),
                    Switch(
                      value: isActive,
                      activeColor: color,
                      onChanged: (val) => _bloc.add(ChangeStatusEvent(
                          item.stationSpaceId!,
                          item.spaceId!,
                          item.stationId!,
                          val ? "ACTIVE" : "INACTIVE")),
                    ),
                  ],
                ),
                const Spacer(),
                Text(item.spaceName ?? "Unknown",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(item.spaceCode ?? "",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.people, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text("${item.capacity} khách",
                      style: const TextStyle(color: Colors.grey, fontSize: 12))
                ]),
                const Spacer(),
                const Divider(color: Colors.white10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // [THÊM MỚI] Status Name Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: isActive
                                ? Colors.green.withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                            width: 0.5),
                      ),
                      child: Text(
                        item.statusName ??
                            (isActive ? "Hoạt động" : "Ngừng hoạt động"),
                        style: TextStyle(
                            color: isActive ? Colors.green : Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Actions
                    Row(
                      children: [
                        InkWell(
                            onTap: () => _showEditDialog(context, item),
                            child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.edit,
                                    size: 18, color: Colors.blue))),
                        const SizedBox(width: 4),
                        InkWell(
                            onTap: () => _showDeleteConfirm(context, item),
                            child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.delete,
                                    size: 18, color: Colors.red))),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DIALOGS ---
  void _showCreateDialog(BuildContext context) {
    _bloc.add(LoadMasterListEvent());
    final nameCtrl = TextEditingController();
    final spaceCodeCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    PlatformSpaceModel? selectedPlatform;
    final formKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (ctx) {
          return BlocBuilder<SpaceBloc, SpaceState>(
            bloc: _bloc,
            builder: (context, state) {
              return AlertDialog(
                backgroundColor: AppColors.containerBackground,
                title: const Text("Thêm Loại hình mới",
                    style: TextStyle(color: Colors.white)),
                content: SizedBox(
                  width: 400,
                  child: state.isActionLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<PlatformSpaceModel>(
                                value: selectedPlatform,
                                dropdownColor: AppColors.inputBackground,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecor("Chọn Loại hình"),
                                hint: const Text("Chọn...",
                                    style: TextStyle(color: Colors.grey)),
                                items: state.platformSpaces
                                    .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(m.typeName ?? "")))
                                    .toList(),
                                onChanged: (val) {
                                  selectedPlatform = val;
                                  if (nameCtrl.text.isEmpty)
                                    nameCtrl.text = val?.typeName ?? "";
                                },
                                validator: (v) =>
                                    v == null ? "Vui lòng chọn" : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField("Loại hình (Code)", spaceCodeCtrl,
                                  toUpperCase: true),
                              const SizedBox(height: 16),
                              _buildTextField("Sức chứa", capacityCtrl,
                                  isNumber: true),
                            ],
                          ),
                        ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Hủy",
                          style: TextStyle(color: Colors.grey))),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate() &&
                          selectedPlatform != null) {
                        final newSpace = StationSpaceModel(
                          stationId: _currentStationId,
                          spaceId: selectedPlatform!.spaceId,
                          spaceCode: spaceCodeCtrl.text,
                          spaceName: nameCtrl.text,
                          capacity: int.tryParse(capacityCtrl.text),
                        );
                        _bloc.add(CreateStationSpaceEvent(newSpace));
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGlow),
                    child: const Text("Thêm",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        });
  }

  void _showEditDialog(BuildContext context, StationSpaceModel item) {
    final nameCtrl = TextEditingController(text: item.spaceName);
    final capacityCtrl =
        TextEditingController(text: item.capacity?.toString() ?? "");
    final formKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: AppColors.containerBackground,
            title:
                const Text("Cập nhật", style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Loại hình (Code): ${item.spaceCode}",
                        style: const TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 16),
                    _buildTextField("Tên hiển thị", nameCtrl),
                    const SizedBox(height: 16),
                    _buildTextField("Sức chứa", capacityCtrl, isNumber: true),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child:
                      const Text("Hủy", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final updated = item.copyWith(
                      spaceCode: item.spaceCode,
                      spaceName: nameCtrl.text,
                      capacity: int.tryParse(capacityCtrl.text),
                    );
                    _bloc.add(UpdateStationSpaceEvent(updated));
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGlow),
                child: const Text("Lưu", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
  }

  void _showDeleteConfirm(BuildContext context, StationSpaceModel item) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.inputBackground,
              title: const Text("Xác nhận xóa",
                  style: TextStyle(color: Colors.white)),
              content: Text("Bạn có chắc muốn xóa '${item.spaceName}'?",
                  style: const TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Hủy",
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                    onPressed: () {
                      _bloc.add(DeleteStationSpaceEvent(item.stationSpaceId!));
                      Navigator.pop(ctx);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Xóa",
                        style: TextStyle(color: Colors.white))),
              ],
            ));
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool isNumber = false,
    bool toUpperCase = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: toUpperCase
            ? TextCapitalization.characters
            : TextCapitalization.none,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecor(""),
        validator: (v) => v!.isEmpty ? "Vui lòng nhập" : null,
        onChanged: (value) {
          if (toUpperCase) {
            final upperCaseValue = value.toUpperCase();
            if (value != upperCaseValue) {
              ctrl.value = ctrl.value.copyWith(
                text: upperCaseValue,
                selection:
                    TextSelection.collapsed(offset: upperCaseValue.length),
              );
            }
          }
        },
      )
    ]);
  }

  InputDecoration _inputDecor(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade700),
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade800)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14));
}
