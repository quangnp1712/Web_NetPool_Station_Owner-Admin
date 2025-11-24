// ignore_for_file: type_literal_in_constant_pattern

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/bloc/station_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/model/station_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/pages/station_data_source.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/menu_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/widget/list_widget/build_filter_bar.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/widget/list_widget/build_footer.dart';

//! Station List - DS Station Station !//

class StationListPage extends StatefulWidget {
  const StationListPage({super.key});

  @override
  State<StationListPage> createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  final StationListBloc stationListBloc = StationListBloc();

  bool _sortAscending = true;
  int? _sortColumnIndex;

  // --- THÊM: Biến cho phân trang và Data Source ---
  late StationDataSource _dataSource;
  PaginatorController? _paginatorController;
  int _totalRows = 0;
  int _currentPage = 1;
  int _rowsPerPage = 10;
  bool isLoading = true;

  //$ --- SỬA: State cho Filter (Bộ lọc) ---
  final _searchController = TextEditingController();

  // 1. Danh sách Master (Lấy từ BLoC, không bao giờ thay đổi)
  List<StationListModel> _allOwnedStations = [];
  List<String> _statusNames = [];

  // 2. Danh sách Động cho Dropdowns (Dùng để lọc)
  List<String> _provinceDropdownList = [];
  List<String> _districtDropdownList = [];

  // 3. Giá trị đang chọn
  String? _selectedStatus;
  String? _selectedProvince;
  String? _selectedDistrict;
  //$ ------------------------------------

  @override
  void initState() {
    super.initState();
    // Khởi tạo Data Source với dữ liệu rỗng
    _paginatorController = PaginatorController();

    stationListBloc.add(StationListInitialEvent());
    _dataSource = StationDataSource(
        context: context, initialData: [], stationListBloc: stationListBloc);
  }

  @override
  void dispose() {
    _paginatorController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- THÊM: HÀM SẮP XẾP (SORT) ---
  void _sort<T extends Comparable>(
    T? Function(StationListModel d) getField,
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

  void _fetchData() {
    stationListBloc.add(StationListLoadEvent(
      current: _currentPage,
      search: _searchController.text,
      statusName: _selectedStatus,
      province: _selectedProvince,
      district: _selectedDistrict,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StationListBloc, StationListState>(
      bloc: stationListBloc,
      listenWhen: (previous, current) => current is StationListActionState,
      buildWhen: (previous, current) => current is! StationListActionState,
      listener: (context, state) {
        switch (state.runtimeType) {
          case ShowCreateStationPageState:
            if (!menuController.isActive(stationCreatePageName)) {
              menuController.changeActiveItemTo(stationCreatePageName,
                  parentName: stationParentName);
              if (ResponsiveWidget.isSmallScreen(context)) Get.back();
              navigationController.navigateAndSyncURL(stationCreatePageRoute);
            }
            break;
          case ShowStationDetailPageState:
            if (!menuController.isActive(stationUpdatePageName)) {
              menuController.changeActiveItemTo(stationUpdatePageName,
                  parentName: stationParentName);
              if (ResponsiveWidget.isSmallScreen(context)) Get.back();
              navigationController.navigateAndSyncURL(stationUpdatePageRoute);
            }
            break;
        }
      },
      builder: (context, state) {
        if (state is StationListSuccessState) {
          _totalRows = state.meta.total ?? 10;
          _rowsPerPage = state.meta.pageSize ?? 10;
          _currentPage = state.meta.current ?? 1;
          isLoading = false;

          // Tính toán offset (vị trí bắt đầu) của trang hiện tại
          final pageOffset = (_currentPage - 1) * _rowsPerPage;
          _dataSource.updateData(state.stationList, _totalRows, pageOffset);

          if (_allOwnedStations.isEmpty) {
            _allOwnedStations = state.allOwnedStations; // Lấy danh sách đầy đủ
            _statusNames = state.statusNames;

            // Tạo list Tỉnh/TP
            _provinceDropdownList = _allOwnedStations
                .map((s) => s.province)
                .whereType<String>()
                .toSet()
                .toList()
              ..sort(); // Sắp xếp

            // Tạo list Quận/Huyện (ban đầu là tất cả)
            _districtDropdownList = _allOwnedStations
                .map((s) => s.district)
                .whereType<String>()
                .toSet()
                .toList()
              ..sort();
          }
        }
        if (state is StationListEmptyState) {
          _totalRows = 0;
          _dataSource.updateData([], 0, 0);
          isLoading = false;
        }
        if (state is StationList_LoadingState) {
          isLoading = state.isLoading;
        }
        if (state is SelectedProvinceState) {
          _selectedProvince = state.selectedProvince;
          _selectedDistrict = null; // Reset Quận/Huyện

          // LỌC LẠI DANH SÁCH QUẬN/HUYỆN (Logic Cascading)
          if (_selectedProvince == null) {
            // Nếu reset Tỉnh -> Hiển thị TẤT CẢ Quận/Huyện
            _districtDropdownList = _allOwnedStations
                .map((s) => s.district)
                .whereType<String>()
                .toSet()
                .toList()
              ..sort();
          } else {
            // Nếu chọn Tỉnh -> Chỉ hiển thị Quận/Huyện của Tỉnh đó
            _districtDropdownList = _allOwnedStations
                .where((s) => s.province == _selectedProvince) // Lọc theo Tỉnh
                .map((s) => s.district)
                .whereType<String>()
                .toSet()
                .toList()
              ..sort();
          }
          _currentPage = 1;
          _fetchData();
        }
        if (state is SelectedStatusState) {
          _selectedStatus = state.selectedStatus;
          _currentPage = 1;
          _fetchData();
        }
        if (state is SelectedDistrictState) {
          _selectedDistrict = state.selectedDistrict;
          _currentPage = 1;
          _fetchData();
        }
        return Material(
          color: AppColors.mainBackground, // Màu nền tối bên ngoài
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0.0),
            children: [
              Container(
                // Thêm padding cho toàn bộ body
                padding: const EdgeInsets.all(40.0),
                // color: AppColors.mainBackground, // Đã chuyển lên Material
                alignment: Alignment.center,
                child: Container(
                  // Đây là Container chính với hiệu ứng glow
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      // Áp dụng chính xác thông số Drop Shadow bạn đã cung cấp
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
                      // 1. Hàng Filter (Tìm kiếm, Dropdown, Button)
                      _buildFilterBar(),

                      // 2. Bảng Dữ liệu (ĐÃ THAY THẾ)
                      _buildDataTable(isLoading),
                    ],
                  ),
                ),
              ),
              // 3. Footer (Copyright)
              const CommonFooter(),
            ],
          ),
        );
      },
    );
  }

// --- SỬA: WIDGET CON: HÀNG FILTER ---
  Widget _buildFilterBar() {
    return CommonFilterBar(
      searchController: _searchController,
      searchHintText: "Tìm kiếm tên Station",
      onSearchSubmitted: (searchText) {
        _currentPage = 1; // Reset về trang 1
        _fetchData();
      },
      // --- THÊM: NÚT RESET ---
      onResetPressed: () {
        setState(() {
          _searchController.clear();
          _selectedStatus = null;
          _selectedProvince = null;
          _selectedDistrict = null;

          // Reset danh sách Quận/Huyện về trạng thái ban đầu (tất cả)
          _districtDropdownList = _allOwnedStations
              .map((s) => s.district)
              .whereType<String>()
              .toSet()
              .toList()
            ..sort();
        });
        _currentPage = 1;
        _fetchData(); // Gọi BLoC với filter rỗng
      },
      // -------------------------

      // --- SỬA: Cấu hình Dropdowns (Cascading) ---
      dropdowns: [
        // Dropdown 1: Tình trạng
        FilterDropdownConfig(
          hint: "Tình trạng",
          selectedValue: _selectedStatus,
          items: _statusNames, // (Lấy từ BLoC state)
          onChanged: (newValue) {
            stationListBloc.add(SelectedStatusEvent(newValue: newValue));
          },
        ),

        // Dropdown 2: Tỉnh/Thành phố
        FilterDropdownConfig(
          hint: "Tỉnh/Thành phố",
          selectedValue: _selectedProvince,
          items: _provinceDropdownList, // (List động)
          onChanged: (newValue) {
            stationListBloc.add(SelectedProvinceEvent(newValue: newValue));
          },
        ),

        // Dropdown 3: Quận/Huyện
        FilterDropdownConfig(
          hint: "Quận/Huyện",
          selectedValue: _selectedDistrict,
          items: _districtDropdownList, // (List động, phụ thuộc Tỉnh)
          onChanged: (newValue) {
            stationListBloc.add(SelectedDistrictEvent(newValue: newValue));
          },
        ),
      ],
      // ------------------------------------

      // Cấu hình Nút Tạo
      createButtonConfig: CreateButtonConfig(
        text: "TẠO STATION",
        onPressed: () {
          stationListBloc.add(ShowCreateStationPageEvent());
        },
      ),
    );
  }

  // --- WIDGET CON: BẢNG DỮ LIỆU (DATATABLE2 THAY THẾ BẰNG PAGINATEDDATATABLE2) ---
  Widget _buildDataTable(bool isLoading) {
    // SỬA LỖI 1: Bọc `Padding` trong `SizedBox` có chiều cao cố định
    return SizedBox(
      height:
          450, // <-- GÁN CHIỀU CAO CỐ ĐỊNH (giống như SizedBox(height: 400) cũ)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),

          // SỬA: Dùng PaginatedDataTable2
          child: Theme(
            data: Theme.of(context).copyWith(
              // Giữ icon và text màu trắng
              iconTheme: const IconThemeData(color: Colors.white),
              textTheme: Theme.of(context).textTheme.apply(
                    displayColor: Colors.white,
                    bodyColor: Colors.white,
                  ),

              // --- SỬA LỖI: DÙNG 'cardTheme' thay vì 'cardColor' ---
              // 'cardColor' bị PaginatedDataTable2 bỏ qua,
              // 'cardTheme' sẽ ép màu nền cho Card Paginator
              cardTheme: CardTheme(
                color: AppColors.containerBackground, // Màu nền đen
                elevation: 0, // Tắt shadow của card
                margin: EdgeInsets.zero, // Tắt margin của card
              ),
              // --------------------------------------------------

              // Set nền của dropdown (10, 20, 50) thành màu đen (inputBackground)
            ),
            child: Stack(
              children: [
                PaginatedDataTable2(
                  controller: _paginatorController, // Gán controller
                  // --- Styling (Giữ nguyên) ---
                  columnSpacing: 12,
                  horizontalMargin: 24,
                  minWidth: 600,
                  dataRowHeight: 60,
                  headingRowHeight: 56,

                  headingRowDecoration: BoxDecoration(
                    color: AppColors.tableHeader,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0), // Khớp với ClipRRect cha
                      topRight: Radius.circular(12.0), // Khớp với ClipRRect cha
                    ),
                  ),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  dataTextStyle: const TextStyle(color: AppColors.textWhite),
                  dividerThickness: 0,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      width: 0.5,
                      color: Colors.grey[800]!,
                      style: BorderStyle.solid,
                    ),
                  ),

                  // --- LOGIC SẮP XẾP (Giữ nguyên) ---
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

                  // --- THÊM: LOGIC PHÂN TRANG ---
                  rowsPerPage: _rowsPerPage,
                  initialFirstRowIndex: (_currentPage - 1) * _rowsPerPage,
                  availableRowsPerPage: const [10, 20, 50],
                  // --- THÊM TÍNH NĂNG: ẨN PAGINATOR ---
                  hidePaginator: _totalRows <= _rowsPerPage,

                  // Xử lý khi người dùng chọn trang khác
                  onPageChanged: (pageIndex) {
                    // pageIndex là chỉ số hàng bắt đầu (vd: 0, 10, 20)
                    int newPage = (pageIndex / _rowsPerPage).floor() + 1;

                    _currentPage = newPage; // SỬA: Cập nhật state
                    _fetchData();
                  },

                  // Xử lý khi người dùng đổi số hàng/trang
                  onRowsPerPageChanged: (newRowsPerPage) {
                    _rowsPerPage = newRowsPerPage ?? 10;

                    _currentPage = 1; // SỬA: Cập nhật state
                    _fetchData(); // Gọi BLoC
                  },

                  // ------------------------------------
                  source: _dataSource, // Gán Data Source

                  columns: [
                    DataColumn2(
                      label: Text('TÊN STATION'),
                      size: ColumnSize.L, // Tương đương flex: 3
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                          (d) => d.stationName ?? '',
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    DataColumn2(
                      label: Text('HOTLINE'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                          (d) => d.hotline ?? '',
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    DataColumn2(
                      label: Text('QUẬN/HUYỆN'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                          (d) => d.district ?? '',
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    DataColumn2(
                      label: Text('THÀNH PHỐ/TỈNH'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                          (d) => d.province ?? '',
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    DataColumn2(
                      label: Text('TRẠNG THÁI'),
                      size: ColumnSize.S, // Tương đương flex: 2
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                          (d) => d.statusCode ?? '',
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    DataColumn2(
                      label: Text('CHỨC NĂNG'),
                      size: ColumnSize.M, // Tương đương flex: 2
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
