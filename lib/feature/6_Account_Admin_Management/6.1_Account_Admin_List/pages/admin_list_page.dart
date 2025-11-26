import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_stations_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/bloc/admin_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/model/admin_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/pages/admin_data_source.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/menu_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/widget/list_widget/build_filter_bar.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/widget/list_widget/build_footer.dart';

//! Admin List - DS Station Admin !//

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  final AdminListBloc adminListBloc = AdminListBloc();

  // --- State cho Table ---
  late AdminDataSource _dataSource;
  PaginatorController? _paginatorController;

  int _totalRows = 0;
  int _currentPage = 1;
  int _rowsPerPage = 10;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  bool isLoading = true;

  // --- State cho Filter ---
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedStationId;

  // Dữ liệu Dropdown (Giả lập hoặc lấy từ Bloc)
  List<String> _statusList = [];
  // List Station nên lấy từ API, ở đây giả lập
  List<AuthStationsModel> _stationList = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo Data Source với dữ liệu rỗng
    _dataSource = AdminDataSource(
        context: context, initialData: [], adminListBloc: adminListBloc);
    _paginatorController = PaginatorController();
    adminListBloc.add(AdminListInitialEvent());
    // _loadData(resetPage: true);
  }

  @override
  void dispose() {
    _paginatorController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- THÊM: HÀM SẮP XẾP (SORT) ---
  void _sort<T extends Comparable>(
    T? Function(AdminListModel d) getField,
    int columnIndex,
    bool ascending,
  ) {
    // Yêu cầu Data Source tự sắp xếp
    _dataSource.sort(getField, ascending);

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
  // ----------------------------------

  // Hàm gọi Bloc load dữ liệu
  void _loadData({bool resetPage = false}) {
    if (resetPage) {
      _currentPage = 1;
      _paginatorController?.goToFirstPage();
    }

    // Gọi Bloc
    adminListBloc.add(AdminListLoadEvent(
      search: _searchController.text,
      statusCodes: _selectedStatus,
      current: _currentPage.toString(),
      stationId: _selectedStationId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminListBloc, AdminListState>(
      bloc: adminListBloc,
      listener: (context, state) {
        if (state.blocState == AdminListBlocState.ShowCreateAdminState) {
          if (!menuController.isActive(adminCreatePageName)) {
            menuController.changeActiveItemTo(adminCreatePageName,
                parentName: adminParentName);
            if (ResponsiveWidget.isSmallScreen(context)) Get.back();
            navigationController.navigateAndSyncURL(adminCreatePageRoute);
          }
        }
        if (state.blocState == AdminListBlocState.ShowDetailAdminState) {
          if (!menuController.isActive(adminUpdatePageName)) {
            menuController.changeActiveItemTo(adminUpdatePageName,
                parentName: adminParentName);
            if (ResponsiveWidget.isSmallScreen(context)) Get.back();
            navigationController.navigateAndSyncURL(adminUpdatePageRoute);
          }
        }
      },
      builder: (context, state) {
        isLoading = state.status == AdminListStatus.loading;

        _totalRows = state.meta?.total ?? 10;
        _rowsPerPage = state.meta?.pageSize ?? 10;
        _currentPage = state.meta?.current ?? 1;
        _statusList = state.statusNames;
        _stationList = state.stationList;
        _selectedStatus = state.selectedStatus;
        _selectedStationId = state.selectedStationId;

        // Tính toán offset (vị trí bắt đầu) của trang hiện tại
        final pageOffset = (_currentPage - 1) * _rowsPerPage;

        if (state.blocState == AdminListBlocState.AdminListSuccessState) {
          _dataSource.updateData(state.adminList, _totalRows, pageOffset);
        }
        if (state.blocState == AdminListBlocState.AdminListEmptyState) {
          _totalRows = 0;
          _dataSource.updateData([], 0, 0);
          _statusList = [];
        }
        if (state.blocState == AdminListBlocState.SelectedStatusState) {
          _loadData(resetPage: true);
        }
        if (state.blocState == AdminListBlocState.SelectedStationState) {
          _loadData(resetPage: true);
        }
        if (state.blocState == AdminListBlocState.ResetPressedState) {
          adminListBloc.add(AdminListInitialEvent());

          _searchController.clear();
        }

        return Material(
          color: AppColors.mainBackground,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.all(40.0),
                alignment: Alignment.center,
                child: Container(
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
                      // 1. Filter Bar
                      _buildFilterBar(state),

                      // 2. Data Table
                      _buildDataTable(state),
                    ],
                  ),
                ),
              ),

              // Footer
              const CommonFooter(),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // WIDGET: FILTER BAR (Search, Dropdowns, Buttons)
  // ============================================================
  Widget _buildFilterBar(AdminListState state) {
    String? getSelectedStationName() {
      if (_selectedStationId == null) return null;
      try {
        return _stationList
            .firstWhere(
                (e) => e.stationId.toString() == _selectedStationId.toString())
            .stationName;
      } catch (_) {
        return null;
      }
    }

    return CommonFilterBar(
      searchController: _searchController,
      searchHintText: "Tìm kiếm Tên/Email...",
      onSearchSubmitted: (searchText) {
        _loadData(resetPage: true);
      },

      // --- NÚT RESET ---
      onResetPressed: () {
        adminListBloc.add(ResetPressedEvent());
      },

      // --- DROPDOWNS ---
      dropdowns: [
        // Dropdown 1: Station quản lý
        FilterDropdownConfig(
          hint: "Station quản lý",
          // Hiển thị Tên Station tương ứng với ID đang chọn
          selectedValue: getSelectedStationName(),
          // Truyền List<String> thay vì DropdownMenuItem
          items: _stationList.map((e) => e.stationName ?? "").toList(),
          onChanged: (newName) {
            adminListBloc.add(SelectedStationEvent(newValue: newName));
            // Map từ Tên -> ID
          },
        ),

        // Dropdown 2: Trạng thái
        FilterDropdownConfig(
          hint: "Trạng thái",
          selectedValue: _selectedStatus,
          items: _statusList,
          onChanged: (newValue) {
            adminListBloc.add(SelectedStatusEvent(newValue: newValue));
          },
        ),
      ],

      // --- NÚT TẠO MỚI ---
      createButtonConfig: CreateButtonConfig(
        text: "TẠO QUẢN TRỊ VIÊN",
        onPressed: () {
          adminListBloc.add(ShowCreateAdminEvent());
        },
      ),
    );
  }

  // ============================================================
  // WIDGET: DATA TABLE
  // ============================================================
  Widget _buildDataTable(AdminListState state) {
    return SizedBox(
      height: 450, // Chiều cao cố định cho bảng
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Theme(
            // Ép Theme cho bảng (màu chữ, icon, paginator)
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: Colors.white),
              textTheme: Theme.of(context).textTheme.apply(
                    displayColor: Colors.white,
                    bodyColor: Colors.white,
                  ),
              cardTheme: CardTheme(
                  color: AppColors.containerBackground,
                  elevation: 0,
                  margin: EdgeInsets.zero),
            ),
            child: Stack(
              children: [
                PaginatedDataTable2(
                  controller: _paginatorController,
                  source: _dataSource,

                  // --- CẤU HÌNH BẢNG ---
                  columnSpacing: 12,
                  horizontalMargin: 24,
                  minWidth: 600,
                  dataRowHeight: 60,
                  headingRowHeight: 56,

                  headingRowDecoration: BoxDecoration(
                    color: AppColors.tableHeader, // Màu header khác màu nền
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0), // Khớp với ClipRRect cha
                      topRight: Radius.circular(12.0), // Khớp với ClipRRect cha
                    ),
                  ),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  dataTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  dividerThickness: 0,

                  // Đường kẻ mờ giữa các dòng
                  border: TableBorder(
                      horizontalInside: BorderSide(
                    width: 0.5,
                    color: Colors.grey[800]!,
                    style: BorderStyle.solid,
                  )),

                  // --- SORTING ---
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  sortArrowIcon: Icons.arrow_drop_down,
                  sortArrowIconColor: Colors.white,

// --- WIDGET KHI RỖNG (EMPTY) ---
                  empty: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: isLoading
                          ? const SizedBox.shrink()
                          : Text(
                              'Không tìm thấy dữ liệu',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ),

                  // --- PAGINATION ---
                  rowsPerPage: _rowsPerPage,
                  initialFirstRowIndex: (_currentPage - 1) * _rowsPerPage,
                  availableRowsPerPage: const [10, 20, 50],
                  hidePaginator:
                      _totalRows <= _rowsPerPage, // Ẩn nếu ít dữ liệu

                  onPageChanged: (rowIndex) {
                    int newPage = (rowIndex / _rowsPerPage).floor() + 1;
                    _currentPage = newPage;
                    _loadData();
                  },
                  onRowsPerPageChanged: (newRows) {
                    setState(() => _rowsPerPage = newRows ?? 10);
                    _loadData(resetPage: true);
                  },

                  // --- CÁC CỘT (6 CỘT) ---
                  columns: [
                    DataColumn2(
                      label: const Text('QUẢN TRỊ VIÊN'),
                      size: ColumnSize.L, // Cột chính, rộng nhất
                      onSort: (idx, asc) => _sort<String>(
                        (d) => d.username,
                        idx,
                        asc,
                      ),
                    ),
                    DataColumn2(
                      label: const Text('EMAIL'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: const Text('SỐ ĐIỆN THOẠI'),
                      fixedWidth: 130,
                    ),
                    DataColumn2(
                      label: const Text('STATION QUẢN LÝ'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                          (d) => d.stationName ?? '',
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    DataColumn2(
                      label: const Text('TRẠNG THÁI'),
                      fixedWidth: 120,
                      onSort: (idx, asc) =>
                          _sort((d) => d.statusName, idx, asc),
                    ),
                    DataColumn2(
                      label: const Text('CHỨC NĂNG'),
                      fixedWidth: 100,
                    ),
                  ],
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
          ),
        ),
      ),
    );
  }
}
