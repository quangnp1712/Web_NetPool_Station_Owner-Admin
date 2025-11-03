import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:data_table_2/data_table_2.dart';
//! Test !//

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // --- THÊM: BIẾN STATE CHO SẮP XẾP VÀ DỮ LIỆU ---
  bool _sortAscending = true;
  int? _sortColumnIndex;
  List<Map<String, dynamic>> _dataList = []; // Dữ liệu cho bảng
  // ------------------------------------------

  @override
  void initState() {
    super.initState();
    _dataList = _generateMockData();
  }

  // --- THÊM: HÀM TẠO DỮ LIỆU GIẢ ---
  List<Map<String, dynamic>> _generateMockData() {
    return List.generate(
        4,
        (index) => {
              "name": "NGUYỄN PHƯƠNG QUANG ${index + 1}", // Thêm số để Sắp xếp
              "phone": "090xxxxxx${4 - index}", // Thêm số để Sắp xếp
              "isActive": index % 2 == 0, // Thêm thay đổi để Sắp xếp
              "avatar": "https://i.pravatar.cc/150?img=${index + 1}"
            });
  }
  // ----------------------------------

  // --- THÊM: HÀM SẮP XẾP (SORT) ---
  // (Đã chỉnh sửa từ code mẫu để sắp xếp List<Map<String, dynamic>>)
  void _sort<T extends Comparable>(
    T Function(Map<String, dynamic> d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dataList.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
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
    return Material(
      color: AppColors.mainBackground, // Màu nền tối bên ngoài
      child: ListView(
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
              _buildDropdown("Tình trạng", ["Hoạt động", "Bị khóa"]),

              // Dropdown "Chức vụ"
              _buildDropdown("Chức vụ", ["Admin", "Station Owner", "Player"]),
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
          500, // <-- GÁN CHIỀU CAO CỐ ĐỊNH (giống như SizedBox(height: 400) cũ)
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
                      (d) => d["name"] as String, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: Text('SĐT'),
                size: ColumnSize.M, // Tương đương flex: 2
                // THÊM: onSort cho cột SĐT
                onSort: (columnIndex, ascending) {
                  _sort<String>(
                      (d) => d["phone"] as String, columnIndex, ascending);
                },
              ),
              DataColumn2(
                label: Text('TRẠNG THÁI'),
                size: ColumnSize.M, // Tương đương flex: 2
                // THÊM: onSort cho cột TRẠNG THÁI
                onSort: (columnIndex, ascending) {
                  _sort<int>(
                      (d) => (d["isActive"]) ? 1 : 0, columnIndex, ascending);
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
            rows: _dataList
                .map(
                  (data) => DataRow(
                    cells: [
                      // Cell 1: Tên
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(data["avatar"]),
                            radius: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(data["name"]),
                        ],
                      )),
                      // Cell 2: SĐT
                      DataCell(Text(data["phone"])),
                      // Cell 3: Trạng thái (Dùng lại hàm _buildStatusChip)
                      DataCell(_buildStatusChip(data["isActive"])),
                      // Cell 4: Chức năng (Các nút bấm)
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
  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isActive ? AppColors.activeStatus : Colors.grey,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        isActive ? "HOẠT ĐỘNG" : "BỊ KHÓA",
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

  // --- WIDGET CON: FOOTER (Vẫn giữ lại) ---
  Widget _buildFooter() {
    return Center(
      child: Text(
        'Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }
}
