// ignore_for_file: type_literal_in_constant_pattern

//! Area List - DS Khu vực !//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/bloc/area_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/services/hex_color_extension.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/widget/create_area_dialog.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/widget/edit_area_dialog.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/widget/get_icon_widget.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';

class AreaListPage extends StatefulWidget {
  const AreaListPage({super.key});

  @override
  State<AreaListPage> createState() => _AreaListPageState();
}

class _AreaListPageState extends State<AreaListPage> {
  final AreaListBloc _areaListBloc = AreaListBloc();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final session = Get.find<UserSessionController>();
    final _currentStationId =
        int.tryParse(session.activeStationId.value ?? "0") ?? 0;

    if (_currentStationId != 0) {
      _areaListBloc.add(AreaListInitialEvent(_currentStationId));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _areaListBloc.close();
    super.dispose();
  }

  void _showCreateAreaDialog(
      BuildContext context, List<StationSpaceModel> spaces) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => CreateAreaDialog(
            availableSpaces: spaces,
            onSubmit: (event) => _areaListBloc.add(event)));
  }

  // Show Edit/Detail Dialog with Callback
  void _showEditAreaDialog(BuildContext context, AreaModel area) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => EditAreaDialog(
            area: area, onEvent: (event) => _areaListBloc.add(event)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AreaListBloc, AreaListState>(
      bloc: _areaListBloc,
      listener: (context, state) {
        if (state.createStatus == CreateStatus.success ||
            state.updateStatus == UpdateStatus.success) {
          ShowSnackBar(state.message, true);
        }
        if (state.createStatus == CreateStatus.failure ||
            state.updateStatus == UpdateStatus.failure) {
          ShowSnackBar(state.message, false);
        }
      },
      builder: (context, state) {
        final bool isLoading = state.status == AreaListStatus.loading ||
            state.updateStatus == UpdateStatus.loading;
        final bool isNoSpaceSelected = state.selectedSpace == null;

        if (_searchController.text != state.searchTerm &&
            state.searchTerm.isEmpty) {
          _searchController.text = state.searchTerm;
        }

        return Material(
          color: AppColors.mainBackground,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                    horizontal: 38.0, vertical: 38.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryGlow,
                          blurRadius: 20.0,
                          spreadRadius: 0.5,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildHeader(context, state),
                      const SizedBox(height: 24),
                      _buildFilterBar(context, state, _areaListBloc),
                      const SizedBox(height: 24),
                      _buildAreaCardGrid(context, state, isLoading,
                          isNoSpaceSelected, _areaListBloc),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                child: const Text(
                    "Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.",
                    style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Sub-Widgets ---

  Widget _buildHeader(BuildContext context, AreaListState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Danh sách Khu vực",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                    letterSpacing: -0.5)),
            SizedBox(height: 4),
            Text("Quản lý các khu vực máy/bàn chơi theo từng loại hình",
                style: TextStyle(fontSize: 14, color: AppColors.textHint)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () =>
              _showCreateAreaDialog(context, state.allStationSpaces),
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text("THÊM KHU VỰC",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.menuActive,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 4,
            shadowColor: AppColors.primaryBlue.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    AreaListState state,
    AreaListBloc bloc,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textWhite),
            decoration: InputDecoration(
              hintText: "Tìm theo tên hoặc mã...",
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
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
                  borderSide: const BorderSide(color: AppColors.primaryBlue)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onSubmitted: (value) =>
                bloc.add(AreaListApplySearchEvent(searchTerm: value)),
          ),
        ),
        Container(
            height: 32,
            width: 1,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
        Expanded(
            flex: 2,
            child: _buildCustomSpaceDropdown(context, state, _areaListBloc)),
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
                    style: TextStyle(color: AppColors.textHint, fontSize: 14)),
                dropdownColor: AppColors.inputBackground,
                icon: const Icon(Icons.filter_list,
                    color: AppColors.textHint, size: 18),
                isExpanded: true,
                style: const TextStyle(color: AppColors.textWhite),
                items: state.statusOptions
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                            e == "ACTIVE" ? "Hoạt động" : "Không hoạt động")))
                    .toList(),
                onChanged: (val) =>
                    bloc.add(AreaListSelectStatusEvent(newValue: val)),
              ),
            ),
          ),
        ),
        if (state.selectedSpace != null ||
            state.searchTerm.isNotEmpty ||
            state.selectedStatus != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              _searchController.clear();
              bloc.add(AreaListResetEvent());
            },
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            style: IconButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
        ]
      ],
    );
  }

  Widget _buildCustomSpaceDropdown(
      BuildContext context, AreaListState state, AreaListBloc bloc) {
    StationSpaceModel? displaySpace;
    if (state.selectedSpace != null && state.allStationSpaces.isNotEmpty) {
      try {
        displaySpace = state.allStationSpaces.firstWhere(
            (e) => e.stationSpaceId == state.selectedSpace!.stationSpaceId);
      } catch (_) {}
    }
    final bgColor = displaySpace?.space?.metadata?.bgColor
        .toColor(fallback: AppColors.inputBackground);
    final isSelected = displaySpace != null;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: bgColor!.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StationSpaceModel>(
          value: displaySpace,
          hint: Row(children: const [
            Icon(Icons.grid_view, color: AppColors.textHint, size: 18),
            SizedBox(width: 8),
            Text("Chọn loại hình...",
                style: TextStyle(color: AppColors.textHint, fontSize: 14))
          ]),
          isExpanded: true,
          dropdownColor: AppColors.inputBackground,
          icon: Icon(Icons.keyboard_arrow_down,
              color: isSelected ? Colors.white : AppColors.textHint),
          selectedItemBuilder: (BuildContext context) {
            return state.allStationSpaces.map<Widget>((item) {
              return Row(children: [
                getIcon(item.space?.metadata?.icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(item.spaceName ?? "",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ]);
            }).toList();
          },
          items: state.allStationSpaces.map((item) {
            final itemColor =
                item.space?.metadata?.bgColor.toColor(fallback: Colors.grey);
            return DropdownMenuItem<StationSpaceModel>(
              value: item,
              child: Row(children: [
                Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: itemColor,
                        borderRadius: BorderRadius.circular(6)),
                    child: getIcon(item.space?.metadata?.icon,
                        size: 14, color: Colors.white)),
                const SizedBox(width: 10),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.spaceName ?? "",
                          style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w500)),
                      Text(item.spaceCode ?? "",
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 10)),
                    ]),
              ]),
            );
          }).toList(),
          onChanged: (val) => bloc.add(AreaListSelectSpaceEvent(newValue: val)),
        ),
      ),
    );
  }

  Widget _buildAreaCardGrid(
    BuildContext context,
    AreaListState state,
    bool isLoading,
    bool isNoSpaceSelected,
    AreaListBloc bloc,
  ) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double containerHeight = screenHeight * 0.75 - 300;
    final double minHeight = containerHeight > 450 ? containerHeight : 450;

    if (isLoading) {
      return SizedBox(
          height: minHeight,
          child: Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryBlue))));
    }

    if (isNoSpaceSelected) {
      return SizedBox(
          height: minHeight,
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4))
                        ]),
                    child: const Center(
                        child: Icon(Icons.grid_view_rounded,
                            size: 40, color: AppColors.textHint))),
                const SizedBox(height: 24),
                const Text("Chưa chọn Loại hình dịch vụ",
                    style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ])));
    }

    if (state.areaList.isEmpty) {
      return SizedBox(
          height: minHeight,
          child: Center(
              child: Text('Không tìm thấy Khu vực nào phù hợp',
                  style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 16,
                      fontStyle: FontStyle.italic))));
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Use SliverGridDelegateWithFixedCrossAxisCount for a fixed number of columns
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Set to 3 columns as requested
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 3, // Adjusted aspect ratio to prevent overflow
          ),
          itemCount: state.areaList.length,
          itemBuilder: (context, index) {
            final area = state.areaList[index];
            return _buildAreaCard(context, area);
          },
        ),
        if ((state.meta.total ?? 0) > (state.meta.pageSize ?? 10))
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageButton(
                    context,
                    Icons.chevron_left,
                    (state.meta.current ?? 1) > 1,
                    () => bloc.add(AreaListChangePageEvent(
                        newPage: (state.meta.current ?? 2) - 1))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Trang ${state.meta.current}",
                      style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold)),
                ),
                _buildPageButton(
                    context,
                    Icons.chevron_right,
                    (state.meta.current ?? 1) * (state.meta.pageSize ?? 10) <
                        (state.meta.total ?? 0),
                    () => bloc.add(AreaListChangePageEvent(
                        newPage: (state.meta.current ?? 0) + 1))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAreaCard(BuildContext context, AreaModel area) {
    final bool isUsing = area.statusCode == "USING";
    final bool isFree = area.statusCode == "ACTIVE";
    final Color statusColor = isUsing
        ? AppColors.statusUsing
        : (isFree ? AppColors.statusFree : AppColors.statusInactiveBg);

    return InkWell(
      // --- CLICK CARD TO OPEN DETAIL ---
      onTap: () => _showEditAreaDialog(context, area),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.containerBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: statusColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Stack(
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12))),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.videogame_asset,
                        color: statusColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(area.areaName ?? area.areaCode ?? "Khu vực mới",
                            style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            overflow: TextOverflow.ellipsis),
                        Text("Mã: ${area.areaCode}",
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 12)),
                        const Spacer(),
                        Text("${area.price?.toStringAsFixed(0)} đ / giờ",
                            style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                            area.statusName ?? area.statusCode ?? "Unknown",
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                      const Spacer(),
                      // --- EDIT ICON ONLY ---
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.edit,
                            color: AppColors.textHint, size: 18),
                        padding: const EdgeInsets.all(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton(BuildContext context, IconData icon, bool enabled,
      VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      color: AppColors.textWhite,
      disabledColor: AppColors.border,
      onPressed: enabled ? onPressed : null,
      splashRadius: 20,
    );
  }
}
