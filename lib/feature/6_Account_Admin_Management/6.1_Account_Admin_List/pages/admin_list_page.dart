import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/bloc/admin_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/model/admin_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/pages/admin_data_source.dart';
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
  // List<AdminListModel> AdminList = [];
  List<String> statusNames = [];
  bool _sortAscending = true;
  int? _sortColumnIndex;
  bool isLoading = true;

  // --- THÊM: Controllers và State cho Filter ---
  final _searchController = TextEditingController();
  String? _selectedStatus;
  // String? _selectedRole; // (Tùy chọn cho "Chức vụ")
  // ------------------------------------------

  // --- THÊM: Biến cho phân trang và Data Source ---
  late AdminDataSource _dataSource;
  PaginatorController? _paginatorController;
  int _totalRows = 0;
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Data Source với dữ liệu rỗng
    _dataSource = AdminDataSource(context: context, initialData: []);
    _paginatorController = PaginatorController();
    adminListBloc.add(AdminListInitialEvent());
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminListBloc, AdminListState>(
      bloc: adminListBloc,
      listenWhen: (previous, current) => current is AdminListActionState,
      buildWhen: (previous, current) => current is! AdminListActionState,
      listener: (context, state) {
        switch (state.runtimeType) {}
      },
      builder: (context, state) {
        if (state is AdminListSuccessState) {
          _totalRows = state.meta.total ?? 10;
          _rowsPerPage = state.meta.pageSize ?? 10;
          _currentPage = state.meta.current ?? 1;
          statusNames = state.statusNames;
          isLoading = false;

          // Tính toán offset (vị trí bắt đầu) của trang hiện tại
          final pageOffset = (_currentPage - 1) * _rowsPerPage;

          _dataSource.updateData(state.AdminList, _totalRows, pageOffset);
        } else if (state is AdminListEmptyState) {
          _totalRows = 0;
          _dataSource.updateData([], 0, 0);
          statusNames = [];
          isLoading = false;
        }
        if (state is AdminList_LoadingState) {
          isLoading = state.isLoading;
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
                      CommonFilterBar(
                        searchController: _searchController,
                        searchHintText: "Tìm kiếm tên tài khoản", // Text động
                        onSearchSubmitted: (searchText) {
                          // Gọi BLoC
                          // accountListBloc.add(AccountListLoadEvent(
                          //   current: "1", // Luôn reset về trang 1
                          //   pageSize: _rowsPerPage,
                          //   search: searchText,
                          //   statusCodes: _selectedStatus,
                          // ));
                        },

                        // Cấu hình Dropdowns
                        // dropdowns: [
                        //   FilterDropdownConfig(
                        //     hint: "Tình trạng",
                        //     selectedValue: _selectedStatus,
                        //     items: statusNames, // Từ BLoC state
                        //     onChanged: (newValue) {
                        //       // setState(() {
                        //       //   _selectedStatus = newValue;
                        //       // });
                        //       // Gọi BLoC
                        //       // accountListBloc.add(AccountListLoadEvent(
                        //       //   current: 1, // Luôn reset về trang 1
                        //       //   pageSize: _rowsPerPage,
                        //       //   search: _searchController.text,
                        //       //   statusCodes: newValue,
                        //       // ));
                        //     },
                        //   ),
                        //   // TODO: Thêm Dropdown "Chức vụ" nếu cần
                        //   // FilterDropdownConfig(
                        //   //   hint: "Chức vụ",
                        //   //   ...
                        //   // ),
                        // ],

                        // Cấu hình Nút Tạo
                        createButtonConfig: CreateButtonConfig(
                          text: "TẠO TÀI KHOẢN", // Text động
                          onPressed: () {
                            // TODO: Xử lý sự kiện Tạo tài khoản
                            print("Bấm nút Tạo tài khoản");
                          },
                        ),
                      ),

                      // 2. Bảng Dữ liệu (ĐÃ THAY THẾ)
                      _buildDataTable(),
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

  // --- WIDGET CON: BẢNG DỮ LIỆU (DATATABLE2 THAY THẾ BẰNG PAGINATEDDATATABLE2) ---
  Widget _buildDataTable() {
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
              textTheme: Theme.of(context)
                  .textTheme
                  .apply(displayColor: Colors.white, bodyColor: Colors.white),

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
                      color: Colors.white, fontWeight: FontWeight.bold),
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

                    // Gọi BLoC để tải trang mới
                    adminListBloc.add(AdminListLoadEvent(
                      current: newPage.toString(),
                      // TODO: Thêm các giá trị filter (search, status...)
                    ));
                  },

                  // Xử lý khi người dùng đổi số hàng/trang
                  onRowsPerPageChanged: (newRowsPerPage) {
                    setState(() {
                      _rowsPerPage = newRowsPerPage ?? 10;
                    });
                    // Gọi BLoC để tải lại từ trang 1
                    adminListBloc.add(AdminListLoadEvent(
                      current: "1", // Luôn reset về trang 1
                      // TODO: Thêm các giá trị filter
                    ));
                  },
                  // ------------------------------------

                  source: _dataSource, // Gán Data Source

                  // --- SỬA: Columns (Thêm cột Email) ---
                  columns: [
                    DataColumn2(
                      label: Text('TÊN'),
                      size: ColumnSize.L, // Tương đương flex: 3
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                            (d) => d.username ?? '', columnIndex, ascending);
                      },
                    ),
                    // THÊM: Cột Email (theo gợi ý trước)
                    DataColumn2(
                      label: Text('EMAIL'),
                      size: ColumnSize.L,
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                            (d) => d.email ?? '', columnIndex, ascending);
                      },
                    ),
                    DataColumn2(
                      label: Text('TRẠNG THÁI'),
                      size: ColumnSize.M, // Tương đương flex: 2
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                            (d) => d.statusCode ?? '', columnIndex, ascending);
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
