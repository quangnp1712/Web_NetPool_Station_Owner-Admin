// ignore_for_file: type_literal_in_constant_pattern

import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/bloc/station_detail_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/shared_preferences/station_detail_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/widgets/get_icon_widget.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/widgets/station_edit_dialog.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';

//! Station Detail - Xem Sửa Station !//

class StationDetailPage extends StatefulWidget {
  const StationDetailPage({super.key});

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  StationDetailBloc bloc = StationDetailBloc();
  final UserSessionController sessionController = Get.find();

  String _activeTab = 'overview';
  late final String _userRole;
  late final String stationId;

// --- HELPER MỚI: CHỌN MÀU THEO TRẠNG THÁI ---
  Color _getStatusColor(String? code) {
    switch (code?.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green; // Xanh lá cho Active
      case 'REJECT':
      case 'REJECTED':
        return Colors.redAccent; // Đỏ cho Reject
      case 'PENDING':
        return Colors.orangeAccent; // Vàng/Cam cho Pending
      default:
        return Colors.grey; // Xám cho các trạng thái khác
    }
  }

  // Tách 2 trạng thái loading
  bool _isHeaderLoading = true; // Loading toàn màn hình (cho Header)
  bool _isContentLoading = false; // Loading riêng cho Content (Skeleton)

  @override
  void initState() {
    super.initState();
    //$ get userrole
    _userRole = AuthenticationPref.getRoleCode();
    DebugLogger.printLog(_userRole);
    //$ get stationID
    if (StationDetailSharedPref.getStationId() != "") {
      stationId = StationDetailSharedPref.getStationId();
    } else {
      stationId = sessionController.activeStationId.value ?? "";
    }
    bloc.add(StationDetailInitialEvent(stationId: stationId));
  }

  void _showEditModal(BuildContext context, StationDetailState state) {
    // Mở Dialog Edit - Nơi chứa Logic Form cũ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: bloc, // Reuse existing BLoC
        child: StationEditDialog(bloc: bloc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocConsumer<StationDetailBloc, StationDetailState>(
      bloc: bloc,
      listener: (context, state) {
        if (state.blocState ==
            StationDetailBlocState.StationUpdateSuccessState) {
          bloc.add(StationDetailInitialEvent(stationId: stationId));
        }
      },
      builder: (context, state) {
        _isHeaderLoading =
            state.stationDetailStatus == StationDetailStatus.loadingHeader
                ? true
                : false;
        _isContentLoading =
            state.stationDetailStatus == StationDetailStatus.loadingContent
                ? true
                : false;
        if (_isHeaderLoading) {
          return const Scaffold(
              backgroundColor: AppColors.mainBackground,
              body: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGlow)));
        }

        return Scaffold(
          backgroundColor: AppColors.mainBackground,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context, state, isDesktop),
                    const SizedBox(height: 24),
                    _buildMainContent(isDesktop, state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(
      BuildContext context, StationDetailState state, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryGlow.withOpacity(0.05),
              blurRadius: 30,
              spreadRadius: 0),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          isDesktop
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: _buildCoverImage(state)),
                      Expanded(
                          flex: 7, child: _buildHeaderInfo(context, state)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    SizedBox(height: 200, child: _buildCoverImage(state)),
                    _buildHeaderInfo(context, state),
                  ],
                ),
          Container(
            color: AppColors.containerBackground,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabItem('overview', 'Dashboard', Icons.dashboard),
                  const SizedBox(width: 12),
                  _buildTabItem(
                      'spaces', 'Loại hình (Spaces)', Icons.videogame_asset),
                  const SizedBox(width: 12),
                  _buildTabItem('areas', 'Khu vực', Icons.layers),
                  const SizedBox(width: 12),
                  _buildTabItem('resources', 'Tài nguyên', Icons.memory),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(StationDetailState state) {
    final images = state.base64Images;
    final displayImage = images.isNotEmpty ? images.first : '';
    // Status logic removed from here to move next to Station Code

    return Stack(
      fit: StackFit.expand,
      children: [
        displayImage.isNotEmpty
            ? (displayImage.startsWith('http')
                ? Image.network(displayImage, fit: BoxFit.cover)
                : Image.memory(base64Decode(displayImage.split(',').last),
                    fit: BoxFit.cover))
            : Container(
                color: AppColors.inputBackground,
                child: const Icon(Icons.image, color: AppColors.textHint)),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.bgCard, AppColors.bgCard.withOpacity(0.0)],
            ),
          ),
        ),
        // Removed Positioned status widget from here
      ],
    );
  }

  Widget _buildHeaderInfo(BuildContext context, StationDetailState state) {
    final status = state.station?.statusName;
    // Cập nhật: Sử dụng _getStatusColor
    final statusColor = _getStatusColor(state.station?.statusCode);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.station?.stationName ?? "",
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite)),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Station Code Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tag,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(state.station?.stationCode ?? "ST-00",
                            style: const TextStyle(
                                fontFamily: 'Monospace',
                                fontSize: 12,
                                color: AppColors.textHint)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status Badge (Moved here) & Updated Color Logic
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(status ?? "Vô hiệu",
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.location_on,
                    size: 16, color: AppColors.btnPrimary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(state.station?.address ?? "",
                        style: const TextStyle(
                            color: AppColors.textMain,
                            overflow: TextOverflow.ellipsis)))
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.phone,
                    size: 16, color: AppColors.activeStatus),
                const SizedBox(width: 8),
                Text(state.station?.hotline ?? "",
                    style: const TextStyle(color: AppColors.textMain))
              ]),
            ],
          ),
          const SizedBox(height: 24),
          // Logic hiển thị Button hoặc Skeleton Loading
          _userRole == 'STATION_OWNER'
              ? (_isContentLoading
                  // Hiển thị Skeleton khi đang loading
                  ? _buildSkeleton(
                      width: 200, // Chiều rộng ước lượng của nút
                      height:
                          52, // Chiều cao tương đương nút (padding vertical 16*2 + icon/text)
                      radius: 8,
                    )
                  // Hiển thị Nút bấm khi đã load xong
                  : ElevatedButton.icon(
                      onPressed: () {
                        bloc.add(ToggleEditModeEvent(true));
                        _showEditModal(context, state);
                      },
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Cấu hình Station'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.btnPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 8,
                        shadowColor: AppColors.btnPrimary.withOpacity(0.5),
                      ),
                    ))
              : Container(),
        ],
      ),
    );
  }

  Widget _buildTabItem(String id, String label, IconData icon) {
    final isActive = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.btnPrimary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isActive
                  ? AppColors.btnPrimary.withOpacity(0.5)
                  : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isActive ? AppColors.menuActive : AppColors.textHint),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: isActive ? AppColors.menuActive : AppColors.textHint,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop, StationDetailState state) {
    // [LOADING 2] Hiển thị Skeleton nếu đang load content (7s)
    // Các hàm _build... sẽ tự check _isContentLoading để hiển thị Skeleton
    if (_activeTab == 'overview') {
      return _buildOverviewContent(isDesktop, state);
    } else if (_activeTab == 'spaces') {
      return _buildSpaceTypesList(state);
    } else if (_activeTab == 'areas') {
      return _buildFullAreasList(state);
    } else if (_activeTab == 'resources') {
      // return _buildResourcesList(state);
      // Placeholder content cho các tab khác
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => bloc.add(ShowResourceManageEvent()),
                icon: const Icon(Icons.arrow_forward, size: 16),
                iconAlignment: IconAlignment.end,
                label: const Text('Quản lý Tài nguyên'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeStatus,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Placeholder content cho các tab khác
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 48, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text("Nội dung tab $_activeTab đang cập nhật...",
                style: TextStyle(color: AppColors.textMain)),
          ],
        ),
      ),
    );
  }

// --- HELPER: SKELETON (LOADING BAR) ---
  // Sử dụng LinearProgressIndicator để tạo hiệu ứng loading bar chạy vô tận
  Widget _buildSkeleton({double? width, double? height, double radius = 4}) {
    return SizedBox(
      width: width,
      height: height ?? 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: LinearProgressIndicator(
          // Màu của thanh chạy (foreground)
          color: AppColors.textHint.withOpacity(0.3),
          // Màu nền (background)
          backgroundColor: AppColors.inputBackground,
          minHeight: height ?? 16,
        ),
      ),
    );
  }

  Widget _buildOverviewContent(bool isDesktop, StationDetailState state) {
    final totalResources = 10;
    // state.resources.fold<int>(0, (p, e) => p + e.quantity);

    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(
                  flex: isWide ? 1 : 0,
                  child: _buildStatCard(
                      'Loại hình (Spaces)',
                      _isContentLoading ? null : '${state.spaces.length}',
                      Icons.videogame_asset,
                      AppColors.primaryBlue)),
              SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
              Expanded(
                  flex: isWide ? 1 : 0,
                  child: _buildStatCard(
                      'Khu vực (Areas)',
                      _isContentLoading ? null : '${state.areas.length}',
                      Icons.layers,
                      AppColors.btnPrimary)),
              SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
              Expanded(
                  flex: isWide ? 1 : 0,
                  child: _buildStatCard(
                      'Tài nguyên (Res)',
                      _isContentLoading ? null : '$totalResources',
                      Icons.memory,
                      AppColors.activeStatus)),
            ],
          );
        }),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isWide ? 2 : 0,
                child: _buildRecentAreasCard(state),
              ),
              SizedBox(width: isWide ? 24 : 0, height: isWide ? 0 : 24),
              Expanded(
                flex: isWide ? 1 : 0,
                child: _buildQuickActionsCard(),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String? value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(color: AppColors.textHint, fontSize: 14)),
              const SizedBox(
                  height: 12), // Tăng khoảng cách chút để bar không bị dính
              // Nếu value null (loading), hiện LinearProgressIndicator
              value == null
                  ? SizedBox(
                      width: 60, // Độ dài của thanh loading
                      height: 4, // Độ dày của thanh
                      child: LinearProgressIndicator(
                        color: color, // Màu chạy (foreground)
                        backgroundColor:
                            color.withOpacity(0.2), // Màu nền mờ (background)
                        borderRadius: BorderRadius.circular(
                            2), // Bo tròn góc thanh loading
                      ),
                    )
                  : Text(value,
                      style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách khu vực (Areas) ở Dashboard
  Widget _buildRecentAreasCard(StationDetailState state) {
    // Hàm helper nhỏ để format tiền tệ (Ví dụ: 10000 -> 10.000 đ)
    String formatCurrency(dynamic price) {
      if (price == null) return "0 đ";
      return "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.layers, color: AppColors.btnPrimary, size: 20),
                    SizedBox(width: 8),
                    Text('Trạng thái Khu vực (Top 5)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textWhite)),
                  ],
                ),

                //! chuyển sang menu ql areas
                TextButton.icon(
                  onPressed: () => bloc.add(ShowAreaManageEvent()),
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Chi tiết'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.menuActive,
                    backgroundColor: AppColors.menuActive.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Container(
            color: AppColors.tableHeader.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Tên khu vực',
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Loại hình',
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Giá khu vực',
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 13))),
              ],
            ),
          ),
          // List Body
          _isContentLoading
              // Loading: Show fake list of skeletons
              ? ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero, // <-- (1) Xóa khoảng cách thừa
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5, // 5 skeleton items
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    return Container(
                      color: AppColors.containerBackground,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: _buildSkeleton(width: 100, height: 16)),
                          Expanded(
                              flex: 2,
                              child: _buildSkeleton(width: 80, height: 14)),
                          Expanded(
                              flex: 2,
                              child: _buildSkeleton(width: 60, height: 14)),
                        ],
                      ),
                    );
                  },
                )
              // Loaded: Show real data
              : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero, // <-- (1) Xóa khoảng cách thừa
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: min(state.areas.length, 5),
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final area = state.areas[index];

                    return Container(
                      color: AppColors.containerBackground,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.activeStatus,
                                      boxShadow: [
                                        BoxShadow(
                                            color: AppColors.activeStatus
                                                .withOpacity(0.6),
                                            blurRadius: 6)
                                      ]),
                                ),
                                const SizedBox(width: 12),
                                //! Tên khu vực
                                Text(area.areaName ?? "",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMain)),
                              ],
                            ),
                          ),
                          //! Loại hình
                          Expanded(
                              flex: 2,
                              child: Text(area.spaceName ?? "",
                                  style: const TextStyle(
                                      color: AppColors.textHint))),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        AppColors.activeStatus.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color:
                                      AppColors.activeStatus.withOpacity(0.1),
                                ),
                                //! trạng thái -> giá (Đã format)
                                child: Text(
                                  formatCurrency(area
                                      .price), // <-- (2) Áp dụng format tiền
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.activeStatus,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.btnPrimary, size: 20),
              SizedBox(width: 8),
              Text('Thao tác nhanh',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textWhite)),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionBtn('QL Loại hình', 'NET, Billiards, PS5, ...', Icons.add,
              AppColors.primaryBlue, () => bloc.add(ShowSpaceManageEvent())),
          const SizedBox(height: 12),
          _buildActionBtn(
              'QL Tài nguyên',
              'Xem, thêm, cập nhập tài nguyên, ...',
              Icons.memory,
              AppColors.activeStatus,
              () => bloc.add(ShowResourceManageEvent())),
          const SizedBox(height: 12),
          if (_userRole == 'STATION_OWNER')
            _buildActionBtn(
                'QL Nhân sự',
                'Xem, thêm, nhân viên, ...',
                Icons.manage_accounts,
                Colors.orangeAccent,
                () => bloc.add(ShowAdminManageEvent())),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.containerBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- FULL LIST BUILDERS FOR TABS ---

  Widget _buildSpaceTypesList(StationDetailState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Loại hình',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite)),
                ElevatedButton.icon(
                  onPressed: () => bloc.add(ShowSpaceManageEvent()),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Quản lý Loại hình'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // List Body with Loading Check
          _isContentLoading
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: _buildSkeleton(width: 44, height: 44, radius: 8),
                      title: _buildSkeleton(width: 150, height: 16),
                      subtitle: _buildSkeleton(width: 200, height: 12),
                      trailing:
                          _buildSkeleton(width: 60, height: 24, radius: 12),
                    );
                  },
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.spaces.length,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final type = state.spaces[index];
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(8)),
                        child: getIcon(type.metadata?.icon,
                            size: 24, color: AppColors.btnPrimary),
                      ),
                      title: Text(type.spaceName ?? "",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite)),
                      subtitle: Text(type.spaceCode ?? "",
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12)),
                      trailing: Text(type.statusName ?? "",
                          style: TextStyle(
                              color: type.statusCode == 'ACTIVE'
                                  ? AppColors.activeStatus
                                  : Colors.orange,
                              fontWeight: FontWeight.bold)),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFullAreasList(StationDetailState state) {
    // Hàm helper nhỏ để format tiền tệ (Ví dụ: 10000 -> 10.000 đ)
    String formatCurrency(dynamic price) {
      if (price == null) return "0 đ";
      return "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Khu vực',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite)),
                ElevatedButton.icon(
                  onPressed: () => bloc.add(ShowAreaManageEvent()),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Quản lý Khu vực'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _isContentLoading
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading:
                          _buildSkeleton(width: 40, height: 40, radius: 20),
                      title: _buildSkeleton(width: 120, height: 16),
                      subtitle: _buildSkeleton(width: 180, height: 12),
                      trailing: _buildSkeleton(width: 50, height: 14),
                    );
                  },
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.areas.length,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final area = state.areas[index];
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.inputBackground,
                        child: Text(area.areaId.toString(),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textWhite)),
                      ),
                      title: Text(area.areaName ?? "",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite)),
                      subtitle: Text(
                          "Loại hình: ${area.spaceName} • Giá: ${formatCurrency(area.price)}",
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12)),
                      trailing: Text(area.statusName ?? "",
                          style: TextStyle(
                              color: area.statusCode == "ACTIVE"
                                  ? AppColors.activeStatus
                                  : Colors.orange,
                              fontWeight: FontWeight.bold)),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildResourcesList(StationDetailState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Tài nguyên',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite)),
                ElevatedButton.icon(
                  onPressed: () => bloc.add(ShowResourceManageEvent()),
                  icon: const Icon(Icons.add_box, size: 16),
                  label: const Text('Nhập kho'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeStatus,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _isContentLoading
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: _buildSkeleton(width: 24, height: 24, radius: 4),
                      title: _buildSkeleton(width: 130, height: 16),
                      subtitle: _buildSkeleton(width: 100, height: 12),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSkeleton(width: 40, height: 14),
                          const SizedBox(height: 4),
                          _buildSkeleton(width: 30, height: 10),
                        ],
                      ),
                    );
                  },
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.resources.length,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final res = state.resources[index];
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: const Icon(Icons.inventory_2_outlined,
                          color: AppColors.textHint),
                      title: Text(res.resourceName ?? "",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite)),
                      subtitle: Text(
                          "Loại: ${res.typeName} • ID: ${res.resourceCode}",
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("SL: 10",
                              style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.bold)),
                          Text('Good',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: res.statusCode == 'Good'
                                      ? AppColors.activeStatus
                                      : Colors.red)),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
