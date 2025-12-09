// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';

import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/bloc/station_resource_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_spec_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/services/hex_color_extension.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/widget/create_resource_dialog.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/widget/edit_resource_dialog.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/widget/get_icon_widget.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/widget/list_widget/build_footer.dart';

class StationResourcePage extends StatefulWidget {
  const StationResourcePage({super.key});

  @override
  State<StationResourcePage> createState() => _StationResourcePageState();
}

class _StationResourcePageState extends State<StationResourcePage> {
  final StationResourceBloc _bloc = StationResourceBloc();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc.add(InitResourcePageEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _showEditDialog(
      BuildContext context, StationResourceModel resource, String? spaceName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EditResourceDialog(
        resource: resource,
        spaceName: spaceName ?? "NET",
        onSave: (updated) => _bloc.add(UpdateResourceEvent(updated)),
        onToggleStatus: (res) => _bloc.add(ToggleResourceStatusEvent(res)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StationResourceBloc, StationResourceState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state.status == ResourceStatus.success && state.message != "") {
          ShowSnackBar(state.message, true);
        }
        if (state.status == ResourceStatus.failure && state.message != "") {
          ShowSnackBar(state.message, false);
        }
        if (state.blocState == ResourceBlocState.ResourceLoadDataState) {
          _bloc.add(ResourceLoadDataEvent(
              areaId: state.selectedArea?.areaId.toString(),
              current: state.meta.current,
              search: state.searchTerm,
              statusCodes: state.selectedStatus));
        }
      },
      builder: (context, state) {
        final bool isLoading = state.status == ResourceStatus.loading;

        if (state.searchTerm.isEmpty && _searchController.text.isNotEmpty) {
          _searchController.clear();
        }

        int totalPages =
            ((state.meta.total ?? 0) / (state.meta.pageSize ?? 12)).ceil();
        if (totalPages == 0) totalPages = 1;
        int currentPage = state.meta.current ?? 1;

        return Scaffold(
          backgroundColor: AppColors.mainBackground,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                    horizontal: 38.0, vertical: 38.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryGlow.withOpacity(0.15),
                          blurRadius: 20.0,
                          spreadRadius: 0.5,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      if (state.selectedArea != null)
                        _buildAreaInfoDashboard(
                            state.selectedArea!, state.meta.total ?? 0),
                      const SizedBox(height: 32),
                      _buildFilterBar(context, state, _bloc),
                      const SizedBox(height: 24),
                      _buildResourceGrid(context, state.resourceList, isLoading,
                          state.selectedSpace?.spaceName),
                      const SizedBox(height: 24),
                      _buildPagination(context, currentPage, totalPages, _bloc),
                    ],
                  ),
                ),
              ),
              CommonFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text("Quản lý Tài nguyên Station",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
                letterSpacing: -0.5)),
        SizedBox(height: 4),
        Text("Danh sách máy trạm và thiết bị trong từng khu vực",
            style: TextStyle(fontSize: 14, color: AppColors.textHint)),
      ])
    ]);
  }

  Widget _buildAreaInfoDashboard(AreaModel area, int totalMachine) {
    StationSpaceModel? space = _bloc.state.selectedSpace;

    final iconName = space?.metadata?.icon ?? area.spaceName;
    final bgColor =
        space?.metadata?.bgColor.toColor(fallback: AppColors.primaryBlue);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.inputBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: bgColor?.withOpacity(0.3) ??
                  AppColors.primaryBlue.withOpacity(0.3))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: bgColor?.withOpacity(0.1) ??
                    AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: getIcon(iconName, size: 30, color: bgColor)),
        const SizedBox(width: 20),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
                child: Text(area.areaName ?? "",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            _buildStatusChip(area.statusCode ?? "ACTIVE")
          ]),
          const SizedBox(height: 6),
          Text(area.spaceName ?? "",
              style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
        ])),
        _buildInfoMetric("Mã Khu vực", area.areaCode ?? ""),
        Container(
            width: 1,
            height: 40,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 24)),
        _buildInfoMetric("Đơn giá", "${area.price?.toStringAsFixed(0)} đ/h",
            valueColor: Colors.yellowAccent),
        Container(
            width: 1,
            height: 40,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 24)),
        _buildInfoMetric("Tổng số máy", "$totalMachine",
            valueColor: AppColors.primaryBlue),
      ]),
    );
  }

  Widget _buildInfoMetric(String label, String value,
      {Color valueColor = Colors.white}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              color: valueColor, fontSize: 16, fontWeight: FontWeight.bold))
    ]);
  }

  Widget _buildStatusChip(String status) {
    bool isActive = status == "ACTIVE";
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: isActive
                ? AppColors.statusActiveBg.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isActive ? AppColors.statusActiveText : Colors.orange)),
        child: Text(isActive ? "Hoạt động" : "Bảo trì",
            style: TextStyle(
                color: isActive ? AppColors.statusActiveText : Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold)));
  }

  Widget _buildFilterBar(BuildContext context, StationResourceState state,
      StationResourceBloc bloc) {
    Color spaceColor =
        state.selectedSpace?.metadata?.bgColor.toColor() ?? Colors.transparent;
    String? spaceIcon = state.selectedSpace?.metadata?.icon;
    bool isSpaceSelected = state.selectedSpace != null;

    return Row(children: [
      Expanded(
          flex: 2,
          child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                  hintText: "Tìm kiếm...",
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.inputBackground,
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
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              onChanged: (val) => bloc.add(SearchResourceEvent(val)))),
      Container(
          height: 32,
          width: 1,
          color: AppColors.border,
          margin: const EdgeInsets.symmetric(horizontal: 16)),
      Expanded(
          flex: 3,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color:
                      isSpaceSelected ? spaceColor : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isSpaceSelected
                          ? Colors.transparent
                          : AppColors.border),
                  boxShadow: isSpaceSelected
                      ? [
                          BoxShadow(
                              color: spaceColor.withOpacity(0.4), blurRadius: 8)
                        ]
                      : []),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<StationSpaceModel>(
                      value: state.selectedSpace,
                      dropdownColor: AppColors.inputBackground,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: isSpaceSelected
                              ? Colors.white
                              : AppColors.textHint),
                      isExpanded: true,
                      selectedItemBuilder: (ctx) => state.spaceOptions
                          .map((e) => Row(children: [
                                getIcon(e.metadata?.icon,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(e.spaceName ?? "",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis))
                              ]))
                          .toList(),
                      items: state.spaceOptions
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Row(children: [
                                Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        color: e.metadata?.bgColor.toColor(),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: getIcon(e.metadata?.icon,
                                        size: 14, color: Colors.white)),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(e.spaceName ?? "",
                                        style: const TextStyle(
                                            color: AppColors.textWhite),
                                        overflow: TextOverflow.ellipsis))
                              ])))
                          .toList(),
                      onChanged: (val) => bloc.add(SelectSpaceEvent(val)))))),
      const SizedBox(width: 16),
      Expanded(
          flex: 1,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<AreaModel>(
                      value: state.areaOptions.contains(state.selectedArea)
                          ? state.selectedArea
                          : null,
                      dropdownColor: AppColors.inputBackground,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textHint),
                      isExpanded: true,
                      hint: const Text("Chọn Khu vực",
                          style: TextStyle(color: AppColors.textHint),
                          overflow: TextOverflow.ellipsis),
                      selectedItemBuilder: (ctx) => state.areaOptions
                          .map((e) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(e.areaName ?? "",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis)))
                          .toList(),
                      items: state.areaOptions
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Row(children: [
                                const Icon(Icons.meeting_room,
                                    color: AppColors.textHint, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(e.areaName ?? "",
                                        style: const TextStyle(
                                            color: AppColors.textWhite),
                                        overflow: TextOverflow.ellipsis))
                              ])))
                          .toList(),
                      onChanged: (val) => bloc.add(SelectAreaEvent(val)))))),
      const SizedBox(width: 16),
      Expanded(
          flex: 1,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                      value: state.selectedStatus,
                      hint: const Text("Trạng thái",
                          style: TextStyle(color: AppColors.textHint),
                          overflow: TextOverflow.ellipsis),
                      dropdownColor: AppColors.inputBackground,
                      icon: const Icon(Icons.filter_list,
                          color: AppColors.textHint, size: 18),
                      isExpanded: true,
                      style: const TextStyle(color: AppColors.textWhite),
                      items: const [
                        DropdownMenuItem(value: null, child: Text("Tất cả")),
                        DropdownMenuItem(
                            value: "ENABLE", child: Text("Hoạt động")),
                        DropdownMenuItem(
                            value: "MAINTENANCE", child: Text("Bảo trì"))
                      ],
                      onChanged: (val) => bloc.add(SelectStatusEvent(val)))))),
      const SizedBox(width: 16),
      ElevatedButton.icon(
          onPressed: state.selectedArea == null
              ? null
              : () {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => BulkCreateResourceDialog(
                          areaId: state.selectedArea!.areaId!,
                          onSave: (newResources) =>
                              bloc.add(CreateResourcesEvent(newResources)),
                          selectedSpace: state.selectedSpace!
                          // spaceName: state.selectedSpace!.spaceName!,
                          ));
                },
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: Text(
              "THÊM ${state.selectedSpace?.spaceName.toString().toUpperCase() ?? "MÁY"}",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.menuActive,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)))),
    ]);
  }

  Widget _buildResourceGrid(BuildContext context,
      List<StationResourceModel> resources, bool isLoading, String? spaceName) {
    final space = _bloc.state.selectedSpace;
    final iconName = space?.metadata?.icon ?? spaceName;
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    double ratio = 1.3;

    if (screenWidth < 600) {
      crossAxisCount = 1;
      ratio = 1.8; // Thẻ thấp hơn trên mobile
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
      ratio = 1.5;
    } else if (screenWidth < 1300) {
      crossAxisCount = 3;
      ratio = 1.1; // Thẻ cao hơn chút để chứa đủ text
    } else {
      crossAxisCount = 4;
      ratio = 1; // Trên màn hình rộng, cho thẻ cao hơn để tránh overflow
    }
    if (isLoading)
      return SizedBox(
          height: 300,
          child: Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.btnPrimary))));
    if (resources.isEmpty)
      return Container(
          height: 300,
          alignment: Alignment.center,
          child: const Text("Không tìm thấy máy nào",
              style: TextStyle(color: AppColors.textHint, fontSize: 16)));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: ratio),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final item = resources[index];
        bool isActive = item.statusCode == "ENABLE";
        return Container(
          decoration: BoxDecoration(boxShadow: [
            if (isActive)
              BoxShadow(
                  color: AppColors.statusActiveText.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2)),
            if (!isActive)
              BoxShadow(
                  color: Colors.orange.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))
          ]),
          child: Material(
            color: AppColors.containerBackground,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: isActive
                        ? AppColors.statusActiveText.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3))),
            child: InkWell(
              onTap: () => _showEditDialog(context, item, spaceName),
              child: Stack(children: [
                Container(
                    width: 6,
                    decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.statusActiveText
                            : Colors.orange,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12)))),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                getIcon(iconName,
                                    color: AppColors.textMain, size: 20),
                                Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: AppColors.inputBackground,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: const Icon(Icons.edit,
                                        size: 16, color: Colors.white70))
                              ]),
                          const SizedBox(height: 12),
                          Text(item.resourceName ?? "",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                              overflow: TextOverflow.ellipsis),
                          Text(item.resourceCode ?? "",
                              style: const TextStyle(
                                  color: AppColors.textHint, fontSize: 12)),
                          const Spacer(),
                          Container(height: 1, color: AppColors.border),
                          const SizedBox(height: 8),
                          _buildSpecPreview(item.spec, spaceName),
                          const SizedBox(height: 8),
                          Align(
                              alignment: Alignment.centerRight,
                              child:
                                  _buildStatusChip(item.statusCode ?? "ENABLE"))
                        ]))
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 12, color: AppColors.textHint),
        const SizedBox(width: 4),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis))
      ]),
    );
  }

  // Render spec info based on space
  Widget _buildSpecPreview(ResourceSpecModel? spec, String? spaceName) {
    if (spec == null)
      return const Text("Chưa cấu hình",
          style: TextStyle(color: AppColors.textHint, fontSize: 11));

    List<Widget> rows = [];
    if (spaceName == "NET") {
      rows.add(_buildIconText(Icons.memory, "${spec.pcCpu}"));
      rows.add(_buildIconText(Icons.developer_board, "${spec.pcGpuModel}"));
      rows.add(_buildIconText(Icons.tv, "${spec.pcMonitor}"));
    } else if (spaceName == "BIDA") {
      rows.add(_buildIconText(Icons.table_restaurant, "${spec.btTableDetail}"));
      rows.add(
          _buildIconText(Icons.sports_baseball, "Bi: ${spec.btBallDetail}"));
    } else if (spaceName == "PLAYSTATION") {
      rows.add(_buildIconText(Icons.gamepad, "${spec.csConsoleModel}"));
      rows.add(_buildIconText(Icons.tv, "${spec.csTvModel}"));
    } else {
      // Default fallback
      rows.add(Text("Spec ID: ${spec.hashCode}",
          style: const TextStyle(color: AppColors.textHint)));
    }
    return Column(children: rows);
  }

  Widget _buildPagination(BuildContext context, int currentPage, int totalPages,
      StationResourceBloc bloc) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(
          onPressed: currentPage > 1
              ? () => bloc.add(ChangePageEvent(currentPage - 1))
              : null,
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          disabledColor: AppColors.border),
      const SizedBox(width: 10),
      Text("Trang $currentPage / $totalPages",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      const SizedBox(width: 10),
      IconButton(
          onPressed: currentPage < totalPages
              ? () => bloc.add(ChangePageEvent(currentPage + 1))
              : null,
          icon: const Icon(Icons.chevron_right, color: Colors.white),
          disabledColor: AppColors.border),
    ]);
  }
}
