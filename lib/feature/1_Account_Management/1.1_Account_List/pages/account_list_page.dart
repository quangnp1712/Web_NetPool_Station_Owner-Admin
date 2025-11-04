import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/bloc/account_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/model/account_list_model.dart';

//! Account List - DS người chơi !//

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  final AccountListBloc accountListBloc = AccountListBloc();
  List<AccountListModel> accountList = [];
  List<String> statusNames = [];
  bool _sortAscending = true;
  int? _sortColumnIndex;

  @override
  void initState() {
    accountListBloc.add(AccountListInitialEvent());
    super.initState();
  }

  // --- THÊM: HÀM SẮP XẾP (SORT) ---
  void _sort<T extends Comparable>(
    T? Function(AccountListModel d) getField, // Sửa: Chấp nhận AccountListModel
    int columnIndex,
    bool ascending,
  ) {
    accountList.sort((a, b) {
      // Sửa: Sắp xếp `accountList`
      final aValue = getField(a);
      final bValue = getField(b);

      // Xử lý null an toàn
      if (aValue == null && bValue == null) return 0;
      if (aValue == null)
        return ascending ? -1 : 1; // Đẩy null xuống dưới (hoặc trên)
      if (bValue == null) return ascending ? 1 : -1;

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    // Gọi setState để rebuild lại bảng với dữ liệu đã sắp xếp
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
  // ----------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountListBloc, AccountListState>(
      bloc: accountListBloc,
      listenWhen: (previous, current) => current is AccountListActionState,
      buildWhen: (previous, current) => current is! AccountListActionState,
      listener: (context, state) {
        switch (state.runtimeType) {}
      },
      builder: (context, state) {
        if (state is AccountListSuccessState) {
          accountList = state.accountList;
          statusNames = state.statusNames;
        } else if (state is AccountListEmptyState) {
          accountList = [];
          statusNames = [];
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
                      _buildDataTable(),
                    ],
                  ),
                ),
              ),
              // 3. Footer (Copyright)
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET CON: HÀNG FILTER ---
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      // SỬA: Dùng Row để đẩy 2 nhóm (filter và button) ra xa nhau
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Căn trên khi bị xuống hàng
        children: [
          // Nhóm bên trái: Các bộ lọc
          // Dùng Wrap để tự xuống hàng khi không đủ chỗ
          Wrap(
            spacing: 16.0, // Khoảng cách ngang
            runSpacing: 16.0, // Khoảng cách dọc khi xuống hàng
            children: [
              // Ô tìm kiếm
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: TextField(
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm tên tài khoản",
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textHint),
                  ),
                ),
              ),

              // Dropdown "Tình trạng"
              statusNames.isNotEmpty
                  ? _buildDropdown("Tình trạng", statusNames)
                  : Container(),

              // Dropdown "Chức vụ"
              // _buildDropdown("Chức vụ", ["Admin", "Station Owner", "Player"]),
            ],
          ),

          // Nhóm bên phải: Button
          // Thêm Padding để giữ khoảng cách khi Wrap xuống hàng
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "TẠO TÀI KHOẢN",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGlow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: BẢNG DỮ LIỆU (ĐÃ THAY THẾ BẰNG DATATABLE2) ---
  Widget _buildDataTable() {
    // SỬA LỖI 1: Bọc `Padding` trong `SizedBox` có chiều cao cố định
    return SizedBox(
      height:
          450, // <-- GÁN CHIỀU CAO CỐ ĐỊNH (giống như SizedBox(height: 400) cũ)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        // Dùng ClipRRect để bo góc cho DataTable
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: DataTable2(
            // --- Styling (Quan trọng) ---
            columnSpacing: 12, // Khoảng cách giữa các cột
            horizontalMargin: 24, // Padding ngang (trái/phải) của bảng
            minWidth: 600, // Chiều rộng tối thiểu
            dataRowHeight: 60, // Chiều cao của hàng
            headingRowHeight: 56, // Chiều cao của header

            // Màu Header (Màu tím)
            headingRowColor: MaterialStateProperty.all(AppColors.tableHeader),
            headingTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),

            // Màu Data Row (Màu nền)
            dataRowColor:
                MaterialStateProperty.all(AppColors.containerBackground),
            dataTextStyle: const TextStyle(color: AppColors.textWhite),

            // Đường viền (Border)
            dividerThickness: 0, // Tắt viền dọc mặc định

            // SỬA LỖI 2: Sửa lại logic `border`
            border: TableBorder(
              // Giữ viền ngang bên trong (giống code cũ)
              horizontalInside: BorderSide(
                width: 0.5,
                color: Colors.grey[800]!,
                style: BorderStyle.solid,
              ),
            ),

            // --- THÊM: LOGIC SẮP XẾP ---
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            // -------------------------
            // --- THÊM: TÙY CHỈNH ICON SORT THEO YÊU CẦU ---
            sortArrowIcon:
                Icons.arrow_drop_down, // Icon đi xuống (sẽ tự động đảo ngược)
            sortArrowIconColor: Colors.white, // Đảm bảo màu trắng
            // ---------------------------------------------

            // --- THÊM: WIDGET KHI RỖNG (EMPTY) ---
            empty: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Không tìm thấy dữ liệu',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            // --------------------------------

            // --- Columns (Định nghĩa các cột) ---
            columns: [
              DataColumn2(
                label: Text('TÊN'),
                size: ColumnSize.L, // Tương đương flex: 3
                // THÊM: onSort cho cột TÊN
                onSort: (columnIndex, ascending) {
                  _sort<String>(
                      (d) => d.username as String, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: Text('EMAIL'),
                size: ColumnSize.M, // Tương đương flex: 2
                // THÊM: onSort cho cột SĐT
                onSort: (columnIndex, ascending) {
                  _sort<String>(
                      (d) => d.email as String, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: Text('SĐT'),
                size: ColumnSize.M, // Tương đương flex: 2
                // THÊM: onSort cho cột SĐT
                onSort: (columnIndex, ascending) {
                  _sort<String>(
                      (d) => d.phone as String, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: Text('TRẠNG THÁI'),
                size: ColumnSize.M, // Tương đương flex: 2
                // THÊM: onSort cho cột TRẠNG THÁI
                onSort: (columnIndex, ascending) {
                  _sort<String>(
                      (d) => d.statusCode ?? '', columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: Text('CHỨC NĂNG'),
                size: ColumnSize.M, // Tương đương flex: 2
                // Cột Chức năng thường không có Sắp xếp
              ),
            ],

            // --- Rows (Dữ liệu) ---
            // SỬA: Dùng `_dataList` (biến state) thay vì `mockData`
            rows: accountList
                .map(
                  (data) => DataRow(
                    cells: [
                      // Cell 1: Tên
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(data.avatar.toString()),
                            radius: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(data.username.toString()),
                        ],
                      )),

                      // Cell 2: Email
                      DataCell(Text(data.email.toString())),

                      // Cell 3: SĐT
                      DataCell(Text(data.phone.toString())),

                      // Cell 4: Trạng thái (Dùng lại hàm _buildStatusChip)
                      DataCell(_buildStatusChip(
                          data.statusCode ?? "", data.statusName ?? "")),

                      // Cell 5: Chức năng (Các nút bấm)
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.blueAccent),
                            onPressed: () {
                              // TODO: Xử lý sự kiện sửa
                            },
                            tooltip: "Chỉnh sửa",
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () {
                              // TODO: Xử lý sự kiện xóa
                            },
                            tooltip: "Xóa",
                          ),
                        ],
                      )),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // --- WIDGET CON: CHIP "HOẠT ĐỘNG" (Vẫn giữ lại) ---
  Widget _buildStatusChip(String statusCode, String statusName) {
    bool isActive = false;
    if (statusCode == "ENABLE") {
      isActive = true;
    } else {
      isActive = false;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isActive ? AppColors.activeStatus : Colors.grey,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        statusName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // --- WIDGET CON: TẠO DROPDOWN (Vẫn giữ lại) ---
  Widget _buildDropdown(String hint, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: const TextStyle(color: AppColors.textWhite)),
          dropdownColor: AppColors.inputBackground,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textWhite),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: const TextStyle(color: AppColors.textWhite)),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  // --- WIDGET CON: FOOTER ---
  Widget _buildFooter() {
    return Center(
      child: Text(
        'Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }
}
