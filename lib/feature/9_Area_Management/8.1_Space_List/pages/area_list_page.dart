// ignore_for_file: type_literal_in_constant_pattern

//! Area List - DS Area !//

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/bloc/area_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/pages/area_data_source.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/services/hex_color_extension.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/widget/list_widget/build_footer.dart';

class AreaListPage extends StatefulWidget {
  const AreaListPage({super.key});

  @override
  State<AreaListPage> createState() => _AreaListPageState();
}

class _AreaListPageState extends State<AreaListPage> {
  // --- Data Table State ---
  late AreaDataSource _dataSource;
  PaginatorController? _paginatorController;
  final AreaListBloc areaListBloc = AreaListBloc();
  late int _currentStationId;

  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  bool isNoSpaceSelected = false;
  int totalRows = 0;
  int currentPage = 1;
  int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _paginatorController = PaginatorController();
    _dataSource = AreaDataSource(
        context: context, initialData: [], areaListBloc: areaListBloc);
    // Khởi tạo BLoC: Tải danh sách Spaces và Status Options
    final session = Get.find<UserSessionController>();
    _currentStationId = int.tryParse(session.activeStationId.value ?? "0") ?? 0;

    areaListBloc.add(AreaListInitialEvent(_currentStationId));
  }

  @override
  void dispose() {
    _paginatorController?.dispose();
    areaListBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  // Helper: Map icon string to Material Icon
  Widget _getIcon(String? iconName, {double size = 18, Color? color}) {
    IconData iconData;
    switch (iconName) {
      case 'PS5':
        iconData = Icons.gamepad;
        break;
      case 'PC':
        iconData = Icons.computer;
        break;
      case 'BILLIARD':
        iconData = Icons.grid_view;
        break;
      default:
        iconData = Icons.local_cafe;
    }
    return Icon(iconData, size: size, color: color ?? Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AreaListBloc, AreaListState>(
      bloc: areaListBloc,
      listener: (context, state) {
        if (state.selectedSpace != null) {
          if (state.blocState == AreaListBlocState.SelectedSpace ||
              state.blocState == AreaListBlocState.SelectedStatus ||
              state.blocState == AreaListBlocState.AppliedSearch ||
              state.blocState == AreaListBlocState.ResetFilters) {
            // Kiểm tra an toàn trước khi gọi
            if (_paginatorController != null &&
                _paginatorController!.isAttached) {
              _paginatorController!.goToFirstPage();
            }
          }
        }
      },
      builder: (context, state) {
        DebugLogger.printLog("cập nhập state");
        // --- CÁC BIẾN TỪ STATE ---
        isLoading = state.status == AreaListStatus.loading;
        _searchController.text = state.searchTerm;
        isNoSpaceSelected = state.selectedSpace == null ? true : false;
        currentPage = state.meta?.current ?? 1;
        rowsPerPage = state.meta?.pageSize ?? 10;
        totalRows = state.meta?.total ?? 0;
        final pageOffset = (currentPage - 1) * rowsPerPage;

        if (state.blocState == AreaListBlocState.AreaListSuccess) {
          _dataSource.updateData(
            state.areaList,
            totalRows,
            pageOffset,
            state.selectedSpace,
          );
        }

        // --- Logic Pagination Controller ---
        // Reset Paginator về trang 1 khi filter/sort thay đổi
        if (state.blocState == AreaListBlocState.SelectedSpace ||
            state.blocState == AreaListBlocState.SelectedStatus ||
            state.blocState == AreaListBlocState.AppliedSearch ||
            state.blocState == AreaListBlocState.ResetFilters) {
          areaListBloc.add(AreaListLoadDataEvent(
              search: _searchController.text,
              statusCodes: state.selectedStatus,
              current: 1,
              spaceId: state.selectedSpace?.spaceId.toString() ?? ""));
        }

        return Material(
          color: AppColors.mainBackground,
          child: ListView(padding: const EdgeInsets.all(0.0), children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                left: 38.0,
                right: 38.0,
                top: 38,
                bottom: 20,
              ),
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildFilterBar(context, state, areaListBloc),
                    const SizedBox(height: 24),
                    _buildDataTableContainer(
                        context,
                        state,
                        isLoading,
                        isNoSpaceSelected,
                        currentPage,
                        rowsPerPage,
                        totalRows,
                        areaListBloc),
                  ],
                ),
              ),
            ),
            const CommonFooter(),
          ]),
        );
      },
    );
  }

  // --- WIDGETS CON ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Danh sách Khu vực",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                  letterSpacing: -0.5),
            ),
            SizedBox(height: 4),
            Text(
              "Quản lý các khu vực máy/bàn chơi theo từng loại hình",
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Logic thêm khu vực
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "THÊM KHU VỰC",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGlow,
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
      BuildContext context, AreaListState state, AreaListBloc bloc) {
    // --- Lấy dữ liệu an toàn ---
    final String? selectedSpaceName = state.selectedSpace?.spaceName;
    final List<String> statusCodes = state.statusOptions;

    return Row(
      children: [
        // 1. Search Box
        Expanded(
          flex: 2,
          child: TextField(
            // SỬA: Dùng text state từ BLoC (để tránh lỗi sync giữa TextField và BLoC)
            controller: _searchController,
            onChanged: (value) {
              // Dùng onChanged tạm để cập nhật textfield ngay
              // Khi submit mới dispatch Event ApplySearch
            },
            style: const TextStyle(color: AppColors.textWhite),
            decoration: InputDecoration(
              hintText: "Tìm theo tên hoặc mã khu vực...",
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
            onSubmitted: (value) {
              // Dispatch Event Search khi submit
              bloc.add(AreaListApplySearchEvent(searchTerm: value));
            },
          ),
        ),

        Container(
            height: 32,
            width: 1,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 16)),

        // 2. Space Dropdown (Custom Highlighted)
        Expanded(
          flex: 2,
          child: _buildCustomSpaceDropdown(context, state, areaListBloc),
        ),

        const SizedBox(width: 16),

        // 3. Status Dropdown
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.selectedStatus,
                hint: const Text("Tất cả trạng thái",
                    style: TextStyle(color: AppColors.textHint, fontSize: 14)),
                dropdownColor: AppColors.inputBackground,
                icon: const Icon(Icons.filter_list,
                    color: AppColors.textHint, size: 18),
                isExpanded: true,
                style: const TextStyle(color: AppColors.textWhite),
                items: statusCodes.map((String status) {
                  return DropdownMenuItem(
                      value: status,
                      // Hiển thị tên (giả định ACTIVE/INACTIVE là Hoạt động/Bảo trì)
                      child:
                          Text(status == "ACTIVE" ? "Hoạt động" : "Bảo trì"));
                }).toList(),
                onChanged: (val) {
                  // Dispatch Event SelectStatus
                  bloc.add(AreaListSelectStatusEvent(newValue: val));
                },
              ),
            ),
          ),
        ),

        // 4. Reset Button
        if (state.selectedSpace != null ||
            state.searchTerm.isNotEmpty ||
            state.selectedStatus != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              // Dispatch Event Reset
              bloc.add(AreaListResetEvent());
            },
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            tooltip: "Đặt lại bộ lọc",
            style: IconButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomSpaceDropdown(
      BuildContext context, AreaListState state, AreaListBloc bloc) {
    // --- FIX LỖI: Tìm đối tượng khớp tham chiếu ---
    StationSpaceModel? matchingSelectedSpace;
    if (state.selectedSpace != null) {
      try {
        matchingSelectedSpace = state.allStationSpaces.firstWhere(
          (item) => item.stationSpaceId == state.selectedSpace!.stationSpaceId,
        );
      } catch (_) {
        matchingSelectedSpace = null;
      }
    }
    // ---------------------------------------------

    final bgColor = matchingSelectedSpace?.space?.metadata?.bgColor
        .toColor(fallback: AppColors.inputBackground);
    final isSelected = matchingSelectedSpace != null;

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
          // Dùng đối tượng khớp tham chiếu
          value: matchingSelectedSpace,
          hint: Row(
            children: const [
              Icon(Icons.grid_view, color: AppColors.textHint, size: 18),
              SizedBox(width: 8),
              Text("Chọn loại hình...",
                  style: TextStyle(color: AppColors.textHint, fontSize: 14)),
            ],
          ),
          isExpanded: true,
          dropdownColor: AppColors.inputBackground,
          icon: Icon(Icons.keyboard_arrow_down,
              color: isSelected ? Colors.white : AppColors.textHint),

          // Render item đã chọn (dùng matchingSelectedSpace)
          selectedItemBuilder: (BuildContext context) {
            return state.allStationSpaces.map<Widget>((StationSpaceModel item) {
              if (item.stationSpaceId ==
                  matchingSelectedSpace?.stationSpaceId) {
                return Row(
                  children: [
                    _getIcon(item.space?.metadata?.icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(item.spaceName ?? "",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                );
              }
              return Container(); // Phải trả về Widget nếu không khớp
            }).toList();
          },

          // Danh sách items (tất cả các item trong state)
          items: state.allStationSpaces.map((StationSpaceModel item) {
            final itemColor =
                item.space?.metadata?.bgColor.toColor(fallback: Colors.grey);
            return DropdownMenuItem<StationSpaceModel>(
              value: item, // Giá trị item
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: itemColor,
                        borderRadius: BorderRadius.circular(6)),
                    child: _getIcon(item.space?.metadata?.icon,
                        size: 14, color: Colors.white),
                  ),
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
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            bloc.add(AreaListSelectSpaceEvent(newValue: val));
          },
        ),
      ),
    );
  }

  Widget _buildDataTableContainer(
    BuildContext context,
    AreaListState state,
    bool isLoading,
    bool isNoSpaceSelected,
    int currentPage,
    int rowsPerPage,
    int totalRows,
    final AreaListBloc bloc,
  ) {
    final double screenHeight = MediaQuery.of(context).size.height;

    // Chiều cao đã sửa (75% màn hình)
    final double containerHeight =
        screenHeight * 0.75 - 300; // Trừ padding và header/filter

    return SizedBox(
      height: containerHeight > 450 ? containerHeight : 450, // Min height 450
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: Colors.white),
              textTheme: Theme.of(context)
                  .textTheme
                  .apply(displayColor: Colors.white, bodyColor: Colors.white),
              cardTheme: CardTheme(
                  color: AppColors.containerBackground,
                  elevation: 0,
                  margin: EdgeInsets.zero),
            ),
            child: Stack(
              children: [
                // CASE 1: Chưa chọn Space (Empty State đặc biệt)
                if (isNoSpaceSelected) _buildNoSpaceSelectedState(),

                // CASE 2: Đã chọn Space HOẶC đang tải -> Hiển thị Bảng
                if (!isNoSpaceSelected)
                  PaginatedDataTable2(
                    controller: _paginatorController,
                    columnSpacing: 12,
                    horizontalMargin: 24,
                    minWidth: 800,
                    dataRowHeight: 60,
                    headingRowHeight: 56,
                    headingRowDecoration: const BoxDecoration(
                      color: AppColors.tableHeader,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0)),
                    ),
                    headingTextStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    dataTextStyle: const TextStyle(color: AppColors.textWhite),
                    dividerThickness: 0,
                    border: TableBorder(
                        horizontalInside: BorderSide(
                            width: 0.5,
                            color: AppColors.border,
                            style: BorderStyle.solid)),

                    // Sắp xếp
                    sortColumnIndex: 0, // Hardcoded index cho demo
                    sortAscending: true, // Hardcoded cho demo
                    sortArrowIcon: Icons.arrow_drop_down,
                    sortArrowIconColor: Colors.white,

                    empty: Center(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Không tìm thấy Khu vực nào trong Space này',
                          style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 16,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                    rowsPerPage: rowsPerPage,
                    initialFirstRowIndex: (currentPage - 1) * rowsPerPage,
                    availableRowsPerPage: const [5, 10, 20],
                    hidePaginator: totalRows <= rowsPerPage,

                    onPageChanged: (pageIndex) {
                      final int newPage = (pageIndex / rowsPerPage).floor() + 1;
                      // Dispatch Event ChangePage
                      bloc.add(AreaListChangePageEvent(newPage: newPage));
                    },
                    onRowsPerPageChanged: (newRowsPerPage) {
                      // Dispatch Event ChangeRowsPerPage
                      bloc.add(AreaListChangeRowsPerPageEvent(
                          newRowsPerPage: newRowsPerPage ?? 10));
                    },

                    source: _dataSource,
                    columns: [
                      const DataColumn2(label: Text('#'), size: ColumnSize.S),
                      DataColumn2(
                        label: const Text('MÃ KHU VỰC'),
                        size: ColumnSize.L,
                        onSort: (columnIndex, ascending) {
                          // Gọi hàm sắp xếp trong Data Source
                          _dataSource.sort<String>(
                              (d) => d.areaCode ?? '', ascending);
                        },
                      ),
                      DataColumn2(
                        label: const Text('TÊN KHU VỰC'),
                        size: ColumnSize.L,
                        onSort: (columnIndex, ascending) {
                          _dataSource.sort<String>(
                              (d) => d.areaName ?? '', ascending);
                        },
                      ),
                      const DataColumn2(
                          label: Text('SPACE'), size: ColumnSize.M),
                      DataColumn2(
                        label: const Text('ĐƠN GIÁ'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) {
                          _dataSource.sort<num>((d) => d.price, ascending);
                        },
                      ),
                      DataColumn2(
                        label: const Text('TRẠNG THÁI'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          _dataSource.sort<String>(
                              (d) => d.statusCode ?? '', ascending);
                        },
                      ),
                      const DataColumn2(
                          label: Text('CHỨC NĂNG'),
                          size: ColumnSize.S,
                          numeric: true),
                    ],
                  ),

                // CASE 3: Loading Overlay
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.containerBackground.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryBlue)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoSpaceSelectedState() {
    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
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
                    color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: const Center(
                child: Icon(Icons.grid_view_rounded,
                    size: 40, color: AppColors.textHint)),
          ),
          const SizedBox(height: 24),
          const Text("Chưa chọn Loại hình dịch vụ",
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
              children: [
                TextSpan(text: "Vui lòng chọn một "),
                TextSpan(
                    text: "Loại hình",
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold)),
                TextSpan(text: " để tải dữ liệu."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
